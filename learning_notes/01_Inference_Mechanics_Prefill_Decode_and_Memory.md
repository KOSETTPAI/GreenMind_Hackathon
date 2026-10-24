# Module 01: Inference Mechanics — Prefill, Decode, and Memory

> *"Everyone optimizes accuracy, throughput, and latency. Almost no one optimizes power."*

---

## 1. Local vs. Production Inference: Two Different Worlds

When running an LLM on your local laptop versus deploying a production-grade inference server, the hardware bottlenecks, constraints, and optimization targets are fundamentally inverted:

| Metric / Dimension | Local Inference (Laptop / Desktop) | Production Serving (Datacenter / Cloud) |
|:---|:---|:---|
| **Typical Tools** | `llama.cpp`, Ollama, LM Studio, MLX | `vLLM`, `SGLang`, `TensorRT-LLM` |
| **Concurrency & Batching**| 1 single user, Batch size = 1 | Many concurrent users ($B = 10 \sim 150+$) |
| **Primary Bottleneck** | Memory capacity (fitting weights into RAM/VRAM) | Compute saturation, memory bandwidth, tail latency ($p_{95}/p_{99}$) |
| **Primary Cost Metric** | Tokens per second for one stream | **Joules per request**, Dollar cost per token, SLA compliance |
| **Optimization Levers** | Aggressive 4-bit/3-bit quantization, CPU offload | Continuous batching, PagedAttention, chunked prefill, power limits |

---

## 2. The Two Phases of LLM Generation

Every autoregressive Large Language Model request consists of two distinct mathematical execution phases:

```
[User Prompt] 
      │
      ▼
┌────────────────────────────────┐
│      1. PREFILL PHASE          │  ──► Process entire prompt in PARALLEL
│      (Compute-Bound)           │  ──► Determines TTFT (Time-To-First-Token)
└────────────────────────────────┘
      │
      ▼
┌────────────────────────────────┐
│      2. DECODE PHASE           │  ──► Autoregressive Loop (1 token per step)
│   (Memory-Bandwidth-Bound)     │  ──► Determines TPOT (Time-Per-Output-Token)
└────────────────────────────────┘
      │
      ▼
[Completed Generation]
```

### A. The Prefill Phase (Prompt Processing)
* **What happens**: The entire input prompt of length $L_{\text{prompt}}$ is projected into query, key, and value vectors simultaneously in one matrix multiplication (GEMM).
* **Execution Regime**: **Compute-Bound**.
* **Why**: The GPU computes attention and feed-forward operations across all $L_{\text{prompt}}$ tokens concurrently. Arithmetic intensity is very high ($\approx \mathcal{O}(L_{\text{prompt}})$ FLOPs per byte loaded from VRAM).
* **Key Metric Determined**: **Time to First Token (TTFT)**.
* **SLO Standard**: $\text{TTFT} \le 0.5\text{s} + 0.25\text{s} \times \frac{\text{Prompt Tokens}}{1000}$.

### B. The Decode Phase (Token Generation)
* **What happens**: For each newly generated token, the model executes a forward pass. It reads the model's entire weight matrix (e.g., 9 billion parameters) from High Bandwidth Memory (HBM) into on-chip SRAM just to compute **one single token**.
* **Execution Regime**: **Memory-Bandwidth-Bound** (at small to moderate batch sizes).
* **Arithmetic Intensity**: Extremely low ($\approx 1\sim 2$ FLOPs per byte transferred).
* **Key Metric Determined**: **Time Per Output Token (TPOT)**.
* **SLO Standard**: $\text{TPOT} \le 50\text{ ms}$ (20 tokens/sec minimum).

> 💡 **The Reasoning Shift**: Modern reasoning models (e.g., Qwen-Thinking, DeepSeek-R1) generate thousands of reasoning/chain-of-thought tokens before returning the final response. In reasoning workloads, **the decode phase accounts for $>90\%$ of total GPU execution time and energy**.

---

## 3. The Arithmetic Intensity & Roofline Model

The **Roofline Model** defines whether an operation is limited by the GPU's compute capability (TFLOPS) or memory bandwidth (GB/s):

$$\text{Arithmetic Intensity (AI)} = \frac{\text{Total Operations (FLOPs)}}{\text{Total Memory Transferred (Bytes)}}$$

On an **NVIDIA A100-SXM4 (40 GB)**:
* **Peak Tensor Core Compute (BF16)**: $312 \times 10^{12}\text{ FLOPs/sec}$ (312 TFLOPS)
* **Peak Memory Bandwidth**: $1,555 \times 10^9\text{ Bytes/sec}$ (1.555 TB/s)
* **Machine Balance Point**:
  $$\text{Balance} = \frac{312 \times 10^{12}\text{ FLOPs/s}}{1.555 \times 10^{12}\text{ Bytes/s}} \approx \mathbf{200.6\text{ FLOPs/Byte}}$$

### The Consequence:
1. **If $\text{AI} < 200.6$**: The GPU is **memory-bandwidth bound**. Compute units are idle, starved waiting for weights to arrive over the memory bus. Increasing clock speed or compute power wastes electricity with zero speedup.
2. **If $\text{AI} > 200.6$**: The GPU is **compute bound**. Memory bandwidth is saturated; execution speed is determined by Tensor Core clock frequency.

```
Execution Speed
(TFLOPS)
   ▲
312│                     ┌─────────────────────────── Compute-Bound (Prefill Phase)
   │                    /
   │                   / 
   │                  /  
   │                 /   Slope = Peak Memory Bandwidth (1.555 TB/s)
   │                /    
   │               /     Memory-Bandwidth Bound (Decode Phase)
   │              /      
   └─────────────┴─────────────────────────────────────► Arithmetic Intensity (FLOPs/Byte)
                200.6
```

---

## 4. Open-Loop Bursts & Little's Law

In production LLM deployments, users do not wait for the previous user's request to complete before sending their prompt. This is an **Open-Loop Arrival System**.

### Little's Law in LLM Queues:
$$L = \lambda \cdot W$$
* $L$ = Average number of concurrent requests inside the server.
* $\lambda$ = Arrival rate (e.g., 4 requests/second).
* $W$ = Average time a request stays in the server (Queue time + Prefill time + Decode time).

### The Dangerous Feedback Loop:
1. When traffic surges to $\lambda = 4\text{ req/s}$, requests pile up.
2. If decode steps become slower (e.g., TPOT rises from 20 ms $\to$ 80 ms), $W$ increases.
3. Because $W$ increases, $L$ (concurrent running requests) explodes from $35 \to 111$ requests.
4. With 111 requests sharing the GPU memory bus, TPOT degrades further, locking the server in an unrecoverable queue collapse!

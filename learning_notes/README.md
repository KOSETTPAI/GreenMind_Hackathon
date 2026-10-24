# AI Systems Engineering: LLM Inference Optimization Masterclass

> A comprehensive, production-grade guide to high-throughput, low-latency, and energy-efficient LLM serving on modern GPU architectures.  
> Derived from real-world benchmarks, theoretical physics of silicon, and empirical teardowns from the **GreenMind LLM Inference Optimization Hackathon (CMKL University & ExxonMobil)**.

---

## 🧭 Curriculum Map & Navigation

This curriculum covers the complete knowledge stack every **AI Systems Engineer**, **LLM Infrastructure Architect**, and **Performance Engineer** must master:

| Chapter | Title | Key Engineering Concepts |
|:---:|:---|:---|
| **[01](01_Inference_Mechanics_Prefill_Decode_and_Memory.md)** | **Inference Mechanics: Prefill vs. Decode** | Compute-bound vs Memory-bound regimes, Roofline Model, TTFT vs TPOT, Arithmetic Intensity, Open-Loop Little's Law |
| **[02](02_KV_Cache_Formulas_and_Hybrid_Architectures.md)** | **KV Cache Engineering & Hybrid Models** | Exact memory byte formulas, MHA vs GQA vs MQA, PagedAttention, Gated DeltaNet & Mamba recurrent state dynamics |
| **[03](03_Quantization_Kernels_and_GPU_Architectures.md)** | **Quantization, Fast Kernels & GPU Generations** | W4A16 AWQ/GPTQ, Marlin GEMM kernel, FlashAttention vs FlashInfer, GPU Tensor Core dtypes (Turing → Blackwell) |
| **[04](04_Prefix_Caching_and_RadixAttention.md)** | **Prefix Caching & Agentic Workloads** | Radix tree KV reuse, multi-turn agentic tool calling (15 turns), prompt block hashing, why MTP broke caching |
| **[05](05_Scheduling_Continuous_Batching_and_Chunked_Prefill.md)** | **Scheduling & Continuous Batching Knobs** | Continuous batching, `max_num_seqs`, `max_num_batched_tokens`, chunked prefill, mixed-step concurrency collapse |
| **[06](06_GPU_Power_Energy_Tuning_and_Physics.md)** | **GPU Power, Energy Physics & Frequency Tuning** | Cubic power law ($P \propto V^2 f$), static TDP clamping (`-pl 250`), graphics clock locking (`-lgc`), idle Joules tax |
| **[07](07_Production_Lessons_The_95_Score_Illusion_and_The_100_Formula.md)** | **Forensic Case Study: The 95.6 Illusion to 100.0** | Forensic post-mortem of Validation vs Final, cold vs warm cache, and the exact mathematical formula to reach 100.0 |

---

## 🎯 The Core Philosophy: "Measure. Change One Thing. Explain."

In AI Systems Engineering, **never guess**. Every optimization must follow the scientific method:
$$\text{Baseline Measurement} \longrightarrow \text{Physical Hypothesis} \longrightarrow \text{Single Variable Change} \longrightarrow \text{Verification} \longrightarrow \text{Trade-off Analysis}$$

### The Universal Technical Score Function:
$$S = 100 \cdot A \cdot s_E^{0.6} \cdot s_T^{0.2} \cdot s_L^{0.2}$$

* **$A$ (Accuracy Gate)**: You cannot sacrifice model intelligence. Dropping $>2\%$ accuracy begins penalizing everything; dropping $>15\%$ zeros the score.
* **$s_E$ (Energy Efficiency, Weight 60%)**: Defined by $\eta = \frac{\text{SLO-met Requests}}{\text{Total GPU Joules}}$. Energy dominates the evaluation.
* **$s_T$ (Throughput, Weight 20%)**: Percentage of peak burst requests that successfully met their Service Level Objectives.
* **$s_L$ (Latency, Weight 20%)**: Geometric mean of Time-To-First-Token ($\text{TTFT}$) and Time-Per-Output-Token ($\text{TPOT} \le 50\text{ms}$).

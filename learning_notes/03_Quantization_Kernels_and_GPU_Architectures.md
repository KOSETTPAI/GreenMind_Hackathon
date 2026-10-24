# Module 03: Quantization, Fast Kernels, and GPU Generations

---

## 1. The Three Families of LLM Quantization

Quantization reduces numerical precision to shrink memory footprint and accelerate inference:

| Quantization Type | Example Schemes | What is Quantized? | What is Kept in High Precision? | Primary Hardware Win |
|:---|:---|:---|:---|:---|
| **Weight-Only (W4A16 / W8A16)** | AWQ, GPTQ | Model Weights (4-bit or 8-bit INT) | Activations kept in FP16 / BF16 | **4x less HBM memory traffic**; massive speedup on memory-bound decodes |
| **Weight & Activation (W8A8 / FP8)** | FP8 (E4M3), SmoothQuant | Weights AND Activations in 8-bit | Matrix multiplications run directly on INT8/FP8 Tensor Cores | **2x compute TFLOPS**; requires native hardware support (Ada/Hopper) |
| **KV Cache Quantization** | FP8 KV, INT4 KV | Keys and Values in PagedAttention | Weights remain unchanged | **Doubles KV cache capacity**; fits 2x larger concurrent batches |

---

## 2. Why AWQ W4A16 + Marlin is the Gold Standard on NVIDIA A100 (Ampere)

An essential insight for AI Systems Engineers: **Match your compression scheme to your GPU architecture generation!**

```
NVIDIA A100 (Ampere, SM 8.0) Architecture:
┌────────────────────────────────────────────────────────┐
│  • FP16 / BF16 Tensor Cores: 312 TFLOPS (Native Support)│
│  • INT8 Tensor Cores:        624 TOPS   (Native Support)│
│  • FP8 Tensor Cores:         NONE!      (Introduced in Hopper H100)│
└────────────────────────────────────────────────────────┘
```

Because the **A100 has NO native FP8 Tensor Cores**, attempting to serve native FP8 models on A100 results in slow emulation.

### The AWQ + Marlin Breakthrough:
1. **Activation-Aware Weight Quantization (AWQ)**: Protects the salient 1% of channels that contain critical activation outliers, quantizing the remaining 99% of weights to 4-bit without quality loss.
2. **Marlin Kernel**:
   * Instead of slow dequantization on shared memory, Marlin streams packed 4-bit weights directly into registers.
   * Weights are unpacked on-the-fly to BF16 inside the register file and fed directly to native BF16 Tensor Cores.
   * Cuts weight memory bandwidth by **4x** (from 18 GB down to 8.1 GB for a 9B model), driving decode TPOT down from 50 ms to sub-18 ms.

---

## 3. Attention Kernels: FlashAttention vs. FlashInfer

Standard attention writes an intermediate $N \times N$ attention matrix to HBM. For large sequence lengths, this requires enormous memory traffic ($O(N^2)$).

```
Standard Attention:   HBM ──(Read Q,K)──► SRAM ──(Write N×N Matrix)──► HBM ──(Read Matrix, V)──► SRAM
FlashAttention:      HBM ──(Tile Q,K,V)─────────────────────────────► SRAM (Compute Online Softmax) ──► HBM
```

* **FlashAttention-2**: Tiles computation across SRAM using online softmax scaling, avoiding writing the $N \times N$ matrix to HBM. Ideal for training and long-prompt prefill.
* **FlashInfer**: A specialized kernel library developed specifically for **LLM serving and continuous batching**:
  * Implements split-KV and ragged tensor layouts.
  * Highly optimized for variable-length batch decode steps and paged KV layouts.
  * **Flag in vLLM**: `--attention-backend FLASHINFER`.

---

## 4. Tensor Core Dtype Support Across GPU Generations

| Tensor-Core Dtype | Turing (SM 7.5)<br>T4 / RTX 2080 | Ampere (SM 8.0)<br>**A100** / RTX 3090 | Ada (SM 8.9)<br>L40S / RTX 4090 | Hopper (SM 9.0)<br>H100 / H200 | Blackwell (SM 10.0)<br>B200 / GB200 |
|:---|:---:|:---:|:---:|:---:|:---:|
| **FP16** | Yes | Yes | Yes | Yes | Yes |
| **BF16** | ❌ No | **Yes** | Yes | Yes | Yes |
| **INT8** | Yes | **Yes** | Yes | Yes | Yes |
| **INT4 (Native)** | Yes | **Yes** | Yes | ❌ No | Yes |
| **FP8 (E4M3/E5M2)** | ❌ No | ❌ **No** | Yes | **Yes (Native)**| **Yes (Native)**|
| **FP4 / FP6** | ❌ No | ❌ No | ❌ No | ❌ No | **Yes (Native)**|

> 📌 **Rule of Thumb**:
> * **On Ampere (A100)**: Use **W4A16 AWQ with Marlin** or BF16.
> * **On Hopper (H100) & Ada (L40S)**: Use **FP8 (W8A8)** or FP8 KV Cache.
> * **On Blackwell (B200)**: Use **FP4 (NVFP4)**.

---

## 5. CUDA Graphs: Eliminating CPU Dispatch Latency

In high-concurrency decoding, GPU kernels execute in fractions of a millisecond (e.g., $0.2\text{ ms}$ per layer). 
If the CPU host has to launch 32 separate kernels sequentially over the PCIe bus on every single decode step:
* Host CPU dispatch overhead: $\approx 5\text{ to }15\text{ ms}$ of pure idle bubble!
* **CUDA Graphs Solution**:
  * Records the entire forward pass execution graph into GPU memory during startup warmup.
  * Replays the entire multi-layer graph with a **single hardware trigger**, reducing launch latency to $< 10\ \mu\text{s}$.
  * **Cost**: 1–2 minutes longer server startup. **Gain**: Deterministic, ultra-fast steady-state TPOT.

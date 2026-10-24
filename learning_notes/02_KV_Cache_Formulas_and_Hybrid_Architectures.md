# Module 02: KV Cache Engineering & Hybrid Architectures

---

## 1. Why Do We Need a KV Cache?

In standard Transformer attention, calculating the next token requires computing attention scores between the current query $Q_t$ and **all previous tokens'** Keys ($K_{1 \dots t}$) and Values ($V_{1 \dots t}$):

$$\text{Attention}(Q_t, K, V) = \text{softmax}\left(\frac{Q_t K^T}{\sqrt{d_k}}\right) V$$

Without caching, generating token 1,000 would require recomputing the Keys and Values of tokens $1 \dots 999$ from scratch on every step ($\mathcal{O}(N^2)$ computation).
To prevent this, engines store the computed Key and Value vectors in GPU memory: this is the **KV Cache**.

---

## 2. The Exact KV Cache Memory Formula

Every AI Systems Engineer must be able to calculate the exact VRAM footprint of the KV cache:

$$\text{Bytes Per Token} = 2 \times N_{\text{layers}} \times N_{\text{KV\_heads}} \times d_{\text{head}} \times \text{BytesPerValue}$$

* The factor of **$2$**: Accounts for storing both **Key ($K$)** and **Value ($V$)** tensors.
* **$N_{\text{layers}}$**: Number of attention layers in the model.
* **$N_{\text{KV\_heads}}$**: Number of Key/Value attention heads.
* **$d_{\text{head}}$**: Hidden dimension per head ($\frac{d_{\text{model}}}{N_{\text{Q\_heads}}}$).
* **$\text{BytesPerValue}$**: Precision of the cache ($2\text{ bytes}$ for FP16/BF16, $1\text{ byte}$ for FP8).

### Total Memory Footprint:
$$\text{Total KV VRAM} = \text{Bytes Per Token} \times \text{Context Length} \times \text{Concurrent Batch Size}$$

---

## 3. Attention Evolution: MHA vs. GQA vs. MQA

To reduce the massive memory appetite of the KV cache, modern architectures evolved attention head sharing:

```
Multi-Head Attention (MHA)       Grouped-Query Attention (GQA)       Multi-Query Attention (MQA)
    [Q][Q][Q][Q][Q][Q][Q][Q]          [Q][Q][Q][Q]   [Q][Q][Q][Q]         [Q][Q][Q][Q][Q][Q][Q][Q]
    [K][K][K][K][K][K][K][K]              [K]             [K]                       [K]
    [V][V][V][V][V][V][V][V]              [V]             [V]                       [V]
     (1 KV head per Q head)            (1 KV head per 4 Q heads)             (1 KV head for ALL Q)
   Largest Cache Footprint             Balanced: 75% Cache Cut              Smallest Cache Footprint
```

* **MHA** (e.g., LLaMA-1, GPT-3): Every query head has its own dedicated KV head. Cache memory scales linearly with head count.
* **GQA** (e.g., LLaMA-3, Qwen-2.5): Multiple query heads share a single KV head (e.g., 32 Q heads, 8 KV heads). Cuts KV cache size by **4x to 8x** with negligible accuracy degradation.
* **MQA**: All query heads share a single KV head. Maximum memory savings, but slight quality trade-off on complex reasoning.

---

## 4. PagedAttention: Virtual Memory for LLMs

Before vLLM invented **PagedAttention** (inspired by OS virtual memory paging), serving systems had to pre-allocate contiguous memory buffers for each request based on `max_model_len` (e.g., allocating a 32K token buffer upfront for a request that might only generate 50 tokens).
* **Memory Fragmentation**: In traditional engines, **60% to 80% of VRAM was wasted** due to internal and external memory fragmentation.
* **PagedAttention Solution**:
  * Chunks the KV cache into fixed-size physical blocks (e.g., 16 tokens per block).
  * Uses a block table to map non-contiguous physical GPU memory pages to logical token sequences.
  * Eliminates fragmentation, boosting achievable concurrency by **2x to 4x** on identical hardware.

---

## 5. Hybrid Models: Gated DeltaNet + Transformer (MANGO1.5 / Qwen3.5)

Our hackathon model (`MANGO1.5-Qwen3.5-9B`) is NOT a pure standard Transformer; it uses a **hybrid state-space / linear-attention architecture**:

```
Layer 01 - 03:  Gated DeltaNet (Linear Attention - Fixed Recurrent State)
Layer 04:       Full Self-Attention (Standard Transformer KV Cache)
Layer 05 - 07:  Gated DeltaNet (Linear Attention - Fixed Recurrent State)
Layer 08:       Full Self-Attention (Standard Transformer KV Cache)
...
(Repeats across 32 layers: 24 Gated DeltaNet + 8 Full Attention)
```

### Why This is Revolutionary for AI Systems Engineers:
1. **Constant-Sized Memory ($O(1)$) in 75% of Layers**:
   * For the 24 Gated DeltaNet layers, memory does **not** grow linearly with context length! They maintain a fixed-size recurrent state matrix updated in-place via causal convolutions and recurrent scans.
2. **Only 8 Layers Keep a KV Cache**:
   * Out of 32 layers, only **8 layers** store Key-Value pairs in the PagedAttention cache.
   * A 32,000-token context in this hybrid architecture consumes **~75% less KV cache memory** than an equivalent 32-layer dense Transformer.
3. **Serving Knobs for Hybrid Models**:
   * `--mamba-cache-mode align`: Aligns the recurrent state snapshots with prefix cache block boundaries, enabling fast state recovery for multi-turn conversations.

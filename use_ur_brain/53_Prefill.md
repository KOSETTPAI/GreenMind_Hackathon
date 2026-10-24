# 53. Prefill

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Autoregressive Generation](25_Autoregressive_Generation.md), [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md)

## In one sentence
Prefill is the phase that processes all prompt tokens in parallel to build the model's state (KV cache / recurrent state) and produce the first output token's distribution.

## Plain-English explanation
Before the model can write anything, it must "read" the whole prompt. Since all prompt tokens are known, they're processed together in big matrix operations — efficient use of the GPU. Prefill time is the main component of **TTFT** (along with queueing).

## Technical depth
- Work ≈ `2 × N_params × n_prompt` FLOPs + attention cost (`O(n²)` for attention layers).
- Usually **compute-bound** for prompts beyond a few hundred tokens (high arithmetic intensity).
- **Hybrid model specifics:** recurrent layers (Mamba/Gated DeltaNet) use chunked parallel scan kernels in prefill; they write a fixed-size final state rather than a growing cache. Attention layers write K/V for every prompt token.
- **Interference:** a long prefill occupies the GPU for many ms; decode steps for other requests wait → TPOT spikes. [Chunked Prefill](95_Chunked_Prefill.md) splits long prompts into pieces that are mixed with decode steps.
- **Prefix caching** can skip prefill for shared prompt prefixes.

## Backend-engineer analogy
Like loading and indexing a large request payload before you can start responding — bulk, parallel, CPU-heavy work before the first byte goes out.

## Why it matters for GreenMind
RAG and long-context requests are prefill-heavy → TTFT risk. Prefill also competes with decode for the GPU, affecting everyone's TPOT.

## Common mistakes
- Assuming prefill and decode have the same bottleneck.
- Ignoring that one 30k-token prompt can stall many decode streams.

## Related concepts
[Decode](54_Decode.md) · [TTFT](62_TTFT.md) · [Chunked Prefill](95_Chunked_Prefill.md) · [Prefix Caching](96_Prefix_Caching.md) · [Batch Token Budget](93_Batch_Token_Budget.md)

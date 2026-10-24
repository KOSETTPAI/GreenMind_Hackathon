# 86. Hybrid Cache Management and Architecture-Specific Kernels

**Stage:** 4 / 6 | **Priority:** Should know | **Prerequisites:** [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md), [Kernels](36_Kernels.md)

## In one sentence
Serving a hybrid model requires a cache manager that handles both growing KV blocks and fixed-size recurrent state slots, plus dedicated kernels for each layer type in both prefill and decode.

## Plain-English explanation
A standard engine only knows "KV cache blocks per token." A hybrid model also needs "one state slot per sequence per recurrent layer." The engine must allocate, update, free, and (optionally) cache both kinds consistently — and must have fast GPU kernels for Mamba/DeltaNet math, or it falls back to slow paths.

## Technical depth
- **vLLM hybrid support:** newer vLLM versions have a hybrid KV cache manager that groups layers by type and manages attention blocks and Mamba-style states in a unified pool; details, flags, and maturity differ by version — read your version's docs and startup logs.
- **Things to check in logs:** chosen attention backend, Mamba/linear-attention kernel path, cache block size, number of blocks, max concurrency for `max-model-len`, whether prefix caching / CUDA graphs / chunked prefill are enabled or auto-disabled for this architecture.
- **State dtype:** recurrent state may be FP32 (more memory) or configurable — affects slots per GB.
- **Kernel paths:** prefill = chunked scan/chunked delta-rule kernels; decode = single-step state update kernels; plus causal-conv1d kernels. Typically Triton, so first-use JIT compile → warmup matters.
- **Fallbacks:** unsupported combos (e.g., a quantization method on a layer type) may silently run unquantized or slower.

## Backend-engineer analogy
A storage engine that must manage both variable-length logs and fixed-size records with different allocators — and one bug in either corrupts sessions.

## Why it matters for GreenMind
Low-risk serving tuning (memory utilization, max sequences, prefix caching) behaves differently for hybrid state. Architecture mismatches can cause unsupported paths, memory inefficiency, or wrong outputs.

## Common mistakes
- Turning on a feature (prefix caching, FP8 KV, speculative decoding) without checking it's actually active and correct for hybrid layers.
- Not reading startup logs.

## Related concepts
[Recurrent State](79_Recurrent_State.md) · [KV Cache](77_KV_Cache.md) · [Prefix Caching](96_Prefix_Caching.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md) · [vLLM](113_vLLM.md)

# 101. GPU Memory Allocation (`gpu_memory_utilization`)

**Stage:** 6 | **Priority:** Must know | **Prerequisites:** [VRAM and HBM](33_VRAM_and_HBM.md), [KV Cache](77_KV_Cache.md)

## In one sentence
GPU memory allocation settings decide how much VRAM the engine claims and how it's split between weights, activations, CUDA graphs, and the KV/state cache pool.

## Plain-English explanation
vLLM grabs a fixed fraction of GPU memory at startup. After weights and a measured activation peak, the rest becomes the cache pool. A bigger pool → more concurrent sequences and longer contexts before preemption. Too aggressive → out-of-memory crashes during peaks or graph capture.

## Technical depth
- `--gpu-memory-utilization 0.90` (typical default) → engine may use 90% of 40 GB = 36 GB.
- Cache pool ≈ `util × total − weights − activation_peak − graph_memory − overhead`.
- `--max-model-len` affects activation profiling and per-sequence max blocks.
- Hybrid models: pool holds both attention KV blocks and recurrent state; startup logs report number of blocks/slots and max concurrency.
- Other knobs: `--kv-cache-dtype` (fp8 halves attention cache — verify support/accuracy), `--swap-space` (CPU swap, legacy), block size.
- Raising util from 0.90 → 0.95 adds ~2 GB of cache — worthwhile if no other process uses the GPU and stability holds.

## Backend-engineer analogy
JVM heap sizing or database buffer-pool sizing: more cache improves hit rate and concurrency until you starve the rest of the process and crash.

## Why it matters for GreenMind
Directly controls concurrency and preemption, which control throughput, p95, and wasted energy.

## Common mistakes
- Setting util too high → OOM under peak or during CUDA graph capture.
- Forgetting other GPU processes (e.g., a monitoring tool) when sizing.

## Related concepts
[Preemption](97_Preemption.md) · [Max Active Sequences](94_Max_Active_Sequences.md) · [Context Window](26_Context_Window.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md)

# 33. VRAM and HBM

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [GPU Fundamentals](29_GPU_Fundamentals.md)

## In one sentence
VRAM is the GPU's own memory (capacity); on the A100 it's HBM2 (High-Bandwidth Memory) — 40 GB with ~1.555 TB/s bandwidth.

## Plain-English explanation
Everything the GPU computes on must live in VRAM: weights, KV cache/recurrent state, activations, and workspace. Capacity decides **what fits** (how many concurrent requests); bandwidth decides **how fast you can read it** (see [Memory Bandwidth](34_Memory_Bandwidth.md)). These are different properties.

## Technical depth
Rough A100 40 GB budget for a 9B BF16 model:

| Item | Approx. |
|---|---|
| Weights (BF16) | ~18 GB |
| CUDA context, libraries | ~0.5–1 GB |
| Activations / workspace / CUDA graphs | ~1–3 GB |
| KV cache + recurrent state pool | remainder (~15+ GB at `gpu_memory_utilization=0.9`) |

- vLLM pre-allocates the cache pool using `--gpu-memory-utilization` (fraction of total VRAM it may use).
- More cache pool → more concurrent sequences/longer contexts before [Preemption](97_Preemption.md).
- Quantizing weights to 4-bit frees ~13 GB for cache → more concurrency.
- Check with `nvidia-smi --query-gpu=memory.used,memory.total --format=csv`.

## Backend-engineer analogy
RAM size of a database server: determines how much of the working set (and how many concurrent sessions) fits before spilling or evicting.

## Why it matters for GreenMind
Memory capacity caps concurrency, which caps throughput. Out-of-memory errors or preemption storms come from overcommitting it.

## Common mistakes
- Confusing capacity (GB) with bandwidth (GB/s).
- Running another process on the GPU during benchmarks, stealing VRAM.

## Related concepts
[Memory Bandwidth](34_Memory_Bandwidth.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md) · [KV Cache](77_KV_Cache.md) · [Max Active Sequences](94_Max_Active_Sequences.md)

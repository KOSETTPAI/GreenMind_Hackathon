# 39. Compute-Bound vs Memory-Bound

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [Arithmetic Intensity](38_Arithmetic_Intensity.md)

## In one sentence
Compute-bound means arithmetic throughput is the limit; memory-bound means data movement is the limit — and an LLM workload shifts between them by phase and batch size.

## Plain-English explanation
- **Compute-bound:** the math units are saturated; faster memory wouldn't help. Typical for **prefill** of long prompts and large-batch decode.
- **Memory-bound:** math units wait for data; more FLOPS wouldn't help. Typical for **small-batch decode**, normalization, elementwise ops, and attention over long KV caches.

The fix differs:
| Bound | What helps |
|---|---|
| Memory | fewer bytes (quantization), more reuse (batching, fusion), better caching |
| Compute | better kernels/Tensor Core use, less wasted work (no padding), lower-precision compute (INT8 on A100) |
| Neither (overhead-bound) | CUDA graphs, fewer launches, less CPU work, bigger batches |

## Technical depth
- Roofline: achievable FLOPS = `min(peak FLOPS, AI × bandwidth)`.
- There's a third regime: **overhead/latency-bound** — tiny kernels where launch time and CPU scheduling dominate (common in small-batch decode without CUDA graphs).
- Diagnose with profilers: DRAM throughput % near peak → memory-bound; Tensor pipe utilization near peak → compute-bound; GPU idle gaps → overhead/CPU-bound.

## Backend-engineer analogy
CPU-bound vs I/O-bound services. Adding cores to an I/O-bound service doesn't help; adding faster disks to a CPU-bound one doesn't either.

## Why it matters for GreenMind
You must know which regime you're in before choosing an optimization. Example: quantization helps memory-bound decode; it may not help compute-bound prefill (and dequant overhead can make it slower).

## Common mistakes
- Assuming GPU utilization alone identifies the bottleneck.
- Treating the whole workload as one regime.

## Related concepts
[Prefill](53_Prefill.md) · [Decode](54_Decode.md) · [Launch Overhead](41_Launch_Overhead.md) · [Profiling](92_Profiling.md) · [Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md)

# 41. Launch Overhead

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [Kernels](36_Kernels.md)

## In one sentence
Launch overhead is the fixed CPU and driver cost (a few microseconds) of starting each GPU kernel — negligible for big kernels, dominant for many tiny ones.

## Plain-English explanation
Every kernel launch needs the CPU to tell the GPU what to run. That takes roughly 3–10 µs. In decode, one step of a 9B model might launch several hundred small kernels; at small batch sizes many of them run for only a few microseconds each. The CPU can't issue launches fast enough, so the GPU sits idle between kernels.

## Technical depth
- Symptom: profiler timeline shows gaps between kernels; GPU-Util looks OK but per-step time exceeds the bandwidth estimate.
- Python overhead in the engine's model runner and scheduler adds to this.
- Remedies:
  - **CUDA graphs:** record the whole decode step once, replay with a single launch (vLLM does this by default for common batch sizes; `--enforce-eager` disables it).
  - **Kernel fusion:** fewer, larger kernels.
  - **torch.compile** (vLLM compilation config) to fuse and reduce Python overhead.
  - Larger batches: more work per kernel, same number of launches.

## Backend-engineer analogy
Per-request overhead (TLS handshake, connection setup) vs payload time. With tiny payloads, overhead dominates — so you batch or keep connections alive.

## Why it matters for GreenMind
Small-batch decode during quiet load phases can be overhead-bound. CUDA graphs and compilation trade startup time and memory for lower per-step overhead.

## Common mistakes
- Running with `--enforce-eager` for debugging and forgetting to turn it off.
- Assuming slow decode is always bandwidth-bound without checking for idle gaps.

## Related concepts
[CUDA Graphs and Compilation](100_CUDA_Graphs_and_Compilation.md) · [Kernel Fusion](109_Kernel_Fusion.md) · [Host System](42_Host_System_CPU_RAM_Storage_Network.md) · [Profiling](92_Profiling.md)

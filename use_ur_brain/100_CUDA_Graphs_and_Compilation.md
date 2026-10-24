# 100. CUDA Graphs and Compilation

**Stage:** 6 | **Priority:** Should know | **Prerequisites:** [Launch Overhead](41_Launch_Overhead.md)

## In one sentence
A CUDA graph records a sequence of GPU kernel launches once and replays it with a single launch; compilation (`torch.compile`) fuses operations and removes Python overhead — both cut per-step overhead at the cost of startup time and memory.

## Plain-English explanation
A decode step launches hundreds of small kernels. CUDA graphs say: "record this exact sequence for batch size 32 once; next time just press play." Compilation rewrites the model's Python into fused, optimized kernels. Together they make small-batch decode much faster — but capturing graphs for many batch sizes takes time at startup and reserves memory.

## Technical depth
- vLLM captures CUDA graphs for a list of decode batch sizes by default; `--enforce-eager` disables graphs (debug only).
- Batches are padded up to the nearest captured size; batch sizes above the largest captured size run eagerly.
- vLLM's compilation config (`-O` level / `--compilation-config`) controls `torch.compile` and graph capture modes (e.g., piecewise vs full graphs); options differ by version.
- Hybrid layers: graph capture must support Mamba/DeltaNet kernels and state updates; check logs for whether graphs are actually used for this model.
- Trade-offs: longer startup (compile + capture), extra memory for graph buffers, first-run compile caching.

## Backend-engineer analogy
Prepared statements / query plan caching — parse and plan once, execute many times cheaply. Also like JIT compilation.

## Why it matters for GreenMind
Big wins for TPOT during low-to-moderate load; startup cost matters only if startup is inside the scored window or time-limited.

## Common mistakes
- Leaving `--enforce-eager` on after debugging.
- Not checking whether graphs were captured for your actual batch-size range.

## Related concepts
[Kernel Fusion](109_Kernel_Fusion.md) · [Model Loading and Warmup](52_Model_Loading_and_Warmup.md) · [Max Active Sequences](94_Max_Active_Sequences.md) · [Launch Overhead](41_Launch_Overhead.md)

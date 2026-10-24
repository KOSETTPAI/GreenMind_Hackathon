# 36. Kernels

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [CUDA](30_CUDA.md)

## In one sentence
A kernel is a function that runs on the GPU in parallel across many threads — every GPU operation (matmul, softmax, norm, attention) is one or more kernel launches.

## Plain-English explanation
When the model runs one layer, the CPU tells the GPU "run the matmul kernel, then the norm kernel, then the attention kernel..." Each kernel reads inputs from memory, computes, and writes outputs. A forward pass of a 9B model may launch hundreds of kernels per step.

Which kernel implementation runs for a given op (e.g., which attention backend, which quantized GEMM) can make a big difference — and engines pick them based on model architecture, dtype, and hardware.

## Technical depth
- Sources of kernels: cuBLAS/CUTLASS (GEMMs), FlashAttention/FlashInfer (attention), Triton kernels (common for Mamba/Gated-DeltaNet, fused ops), Marlin/Machete/AWQ kernels (quantized GEMMs), custom CUDA ops in vLLM.
- **Fallback paths:** if a fast kernel doesn't support your dtype/shape/arch, the engine may silently use a slow generic one. Check startup logs for the selected backend.
- **Architecture-specific kernels:** recurrent layers (Mamba selective scan, Gated DeltaNet chunked recurrence) need dedicated kernels for prefill (chunked/parallel scan) and decode (single-step state update).
- Profiling (Nsight Systems, PyTorch profiler) shows which kernels dominate time.

## Backend-engineer analogy
A kernel is like a single stored procedure or a compiled hot loop. The query planner (engine) picks which implementation to call; a bad plan silently uses a slow path.

## Why it matters for GreenMind
Unsupported or fallback kernels are a top cause of "lower precision but slower" and "new engine but wrong outputs." Always verify the kernel path.

## Common mistakes
- Not reading engine logs about chosen backends.
- Writing a custom kernel before confirming it's the bottleneck.

## Related concepts
[Launch Overhead](41_Launch_Overhead.md) · [Kernel Fusion](109_Kernel_Fusion.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Profiling](92_Profiling.md)

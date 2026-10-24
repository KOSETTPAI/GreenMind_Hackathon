# 109. Kernel Fusion

**Stage:** 8 — Kernels & advanced | **Priority:** Should know | **Prerequisites:** [Kernels](36_Kernels.md), [GPU Memory Hierarchy](35_GPU_Memory_Hierarchy_Cache_Registers_Shared_Memory.md)

## In one sentence
Kernel fusion combines several GPU operations into one kernel so intermediate results stay on-chip instead of round-tripping through HBM, and fewer launches are needed.

## Plain-English explanation
Unfused: kernel A reads x from memory, writes y; kernel B reads y, writes z; kernel C reads z, writes out. Fused: one kernel reads x, computes y and z in registers, writes out once. Fewer memory trips and fewer launches → faster and more energy-efficient, especially for memory-bound elementwise ops.

## Technical depth
- Common LLM fusions: residual add + RMSNorm; QKV projection into one GEMM; SiLU-and-multiply (SwiGLU activation); rotary embedding + KV-cache write; dequantize + GEMM (quantized kernels); softmax + sampling pieces.
- Recurrent layers: fused selective scan (Mamba), fused chunked delta-rule kernels (Gated DeltaNet) — already fused in good implementations.
- Sources: hand-written CUDA/Triton kernels in vLLM; `torch.compile` (Inductor) automatic fusion via vLLM's compilation config.
- Custom fusion requires correctness tests (compare against reference outputs) and is hardware-specific.

## Backend-engineer analogy
Combining multiple DB queries into one round trip, or stream-processing in a single pass instead of writing intermediate files between pipeline stages.

## Why it matters for GreenMind
Explains part of why optimized engines and compilation modes are faster. Writing new fused kernels is the high-risk end of the experiment queue (#10).

## Common mistakes
- Writing custom fused kernels before confirming the target op is a bottleneck.
- Skipping numerical correctness tests.

## Related concepts
[CUDA Graphs and Compilation](100_CUDA_Graphs_and_Compilation.md) · [FlashAttention](110_FlashAttention.md) · [Launch Overhead](41_Launch_Overhead.md) · [Normalization](20_Normalization.md)

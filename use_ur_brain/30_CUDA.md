# 30. CUDA

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [GPU Fundamentals](29_GPU_Fundamentals.md)

## In one sentence
CUDA is NVIDIA's programming platform and execution model for writing and running code on NVIDIA GPUs.

## Plain-English explanation
CUDA is the layer between your Python (PyTorch, vLLM) and the GPU hardware. It includes a programming language extension (CUDA C++), a driver, runtime libraries (cuBLAS for matrix math, cuDNN, NCCL), and tools (Nsight profilers). When PyTorch multiplies two tensors on the GPU, it ends up launching a CUDA kernel.

## Technical depth
- **Programming model:** kernels launched over a grid of thread blocks; threads in a block share fast shared memory and can synchronize.
- **Streams:** ordered queues of GPU work; different streams can overlap.
- **Versions matter:** GPU driver version ≥ CUDA toolkit requirement; PyTorch and vLLM wheels are built against specific CUDA versions (e.g., cu121, cu124, cu128). Mismatches → import errors or fallback paths.
- **Compute capability:** A100 = sm_80. Some kernels (e.g., native FP8 Tensor Core paths) need sm_89/sm_90 and won't run on A100.
- Other kernel sources: **Triton** (Python-like GPU kernel language heavily used by vLLM and by Mamba/linear-attention implementations), CUTLASS (C++ templates for GEMMs).

## Backend-engineer analogy
CUDA is like the OS + runtime + standard library for the GPU; Triton is like a higher-level language that compiles down to it.

## Why it matters for GreenMind
Record CUDA, driver, PyTorch, and vLLM versions for reproducibility. Kernel availability for your dtype/architecture on sm_80 determines whether an optimization is even possible.

## Common mistakes
- Assuming an optimization from H100 blog posts works on A100 (sm_80 lacks FP8 Tensor Cores and some Hopper-only features).

## Related concepts
[Kernels](36_Kernels.md) · [CUDA Graphs and Compilation](100_CUDA_Graphs_and_Compilation.md) · [NVIDIA A100](43_NVIDIA_A100.md) · [Reproducibility](87_Reproducibility.md)

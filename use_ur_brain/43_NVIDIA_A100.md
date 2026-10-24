# 43. NVIDIA A100 (40 GB)

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [GPU Fundamentals](29_GPU_Fundamentals.md), [CUDA Cores and Tensor Cores](32_CUDA_Cores_and_Tensor_Cores.md)

## In one sentence
The A100 is NVIDIA's Ampere-generation data-center GPU; the hackathon hardware is the 40 GB variant.

## Plain-English explanation
Key facts to remember (verify on the actual machine with `nvidia-smi -q`):

| Property | A100 40 GB (approx.) |
|---|---|
| Architecture / compute capability | Ampere, sm_80 |
| SMs / Tensor Cores | 108 / 432 (3rd gen) |
| Memory | 40 GB HBM2 |
| Bandwidth | ~1.555 TB/s |
| L2 cache | 40 MB |
| BF16/FP16 Tensor (dense) | ~312 TFLOPS |
| TF32 Tensor (dense) | ~156 TFLOPS |
| INT8 Tensor (dense) | ~624 TOPS |
| FP32 (non-tensor) | ~19.5 TFLOPS |
| Max power | ~400 W (SXM4) / ~250 W (PCIe) |
| Native FP8 | **No** |

## Technical depth
- **SXM vs PCIe:** same chip, different power limits and cooling → PCIe variant may sustain lower clocks under load. Know which one you have.
- **Ridge point** (BF16) ≈ 200 FLOPs/byte → most decode is memory-bound.
- **MIG** (Multi-Instance GPU) can partition the A100; make sure it's disabled for full-GPU serving.
- Default power limit and clocks can be queried: `nvidia-smi -q -d POWER,CLOCK`.
- Supports 2:4 structured sparsity in Tensor Cores (rarely usable for LLM serving in practice).

## Backend-engineer analogy
Know your instance type: like knowing the exact vCPU count, memory, and disk IOPS of the production host before capacity planning.

## Why it matters for GreenMind
All back-of-envelope math (decode ceiling, concurrency budget, ridge point) uses these numbers. The lack of native FP8 shapes which quantization options are useful.

## Common mistakes
- Applying H100 (Hopper) advice — FP8 compute, FlashAttention-3, etc. — to the A100.
- Comparing runs between PCIe and SXM machines.

## Related concepts
[VRAM and HBM](33_VRAM_and_HBM.md) · [Memory Bandwidth](34_Memory_Bandwidth.md) · [FP8](48_FP8.md) · [GPU Power Caps and Clocks](122_GPU_Power_Caps_and_Clocks.md)

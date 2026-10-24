# 31. Streaming Multiprocessor (SM)

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [CUDA](30_CUDA.md)

## In one sentence
An SM is the GPU's main building block — a cluster of execution units, registers, and on-chip memory that runs thread blocks; the A100 has 108 of them enabled.

## Plain-English explanation
Think of the GPU as a factory with 108 workshops (SMs). Each workshop has its own workers (CUDA cores), special matrix machines (Tensor Cores), a small fast scratchpad (shared memory/L1), and lockers (registers). A kernel's work is split into blocks and handed out to workshops. If there aren't enough blocks to keep all 108 busy, some workshops sit idle.

## Technical depth
- A100 SM (Ampere GA100): 64 FP32 CUDA cores, 4 third-gen Tensor Cores, 64K 32-bit registers, up to 192 KB combined L1/shared memory.
- 108 SMs × 4 = 432 Tensor Cores total.
- Warps of 32 threads are scheduled by 4 warp schedulers per SM; while one warp waits on memory, others run — this is how GPUs hide latency.
- **Wave quantization:** a kernel with 120 blocks on 108 SMs runs one full wave + a 12-block tail, wasting most of the second wave — small-batch decode kernels can suffer this.

## Backend-engineer analogy
SMs are like worker nodes in a cluster; thread blocks are tasks. Too few tasks → idle nodes; badly sized tasks → stragglers.

## Why it matters for GreenMind
Small decode batches may not produce enough parallel work to fill 108 SMs — one reason batching improves efficiency. Profilers report "SM active %" and "SM occupancy," which are better signals than `nvidia-smi` utilization.

## Common mistakes
- Equating "GPU utilization 100%" with "all SMs fully busy" — it only means some kernel was running during the sample period.

## Related concepts
[CUDA Cores and Tensor Cores](32_CUDA_Cores_and_Tensor_Cores.md) · [GPU Memory Hierarchy](35_GPU_Memory_Hierarchy_Cache_Registers_Shared_Memory.md) · [Occupancy](40_Occupancy.md) · [Kernels](36_Kernels.md)

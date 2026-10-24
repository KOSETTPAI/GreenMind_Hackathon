# 29. GPU Fundamentals

**Stage:** 2 — GPU, numerics, energy | **Priority:** Must know | **Prerequisites:** [Parameters and Weights](13_Parameters_and_Weights.md)

## In one sentence
A GPU is a processor with thousands of simple parallel execution units and very high memory bandwidth, built for doing the same operation on lots of data at once.

## Plain-English explanation
A CPU has a few powerful cores good at complex, branchy tasks. A GPU has many small cores that are great at "do this multiply-add on millions of numbers." Neural networks are mostly giant matrix multiplications, so GPUs fit perfectly.

Four separate resources matter — don't mix them up:
1. **Compute capacity** — how many math operations per second (FLOPS).
2. **Memory capacity** — how much fits (VRAM, 40 GB here).
3. **Memory bandwidth** — how fast data moves from VRAM to compute (~1.555 TB/s on A100 40 GB).
4. **Power** — how much energy per second it draws (watts).

## Technical depth
- Hierarchy: GPU → many **SMs** → each SM has CUDA cores, Tensor Cores, registers, shared memory/L1.
- Work is launched as **kernels**: grids of thread blocks; each block runs on one SM; threads execute in groups of 32 (**warps**).
- The CPU (host) orchestrates: it launches kernels and moves data; the GPU (device) executes.
- Performance depends on whether a kernel is limited by compute or memory — see [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md).

## Backend-engineer analogy
CPU = a few senior engineers who can do anything; GPU = a huge team doing the same simple task in lockstep. Memory bandwidth is the conveyor belt feeding them — if it's slow, the team sits idle.

## Why it matters for GreenMind
Every optimization targets one of these four resources. Decode is usually bandwidth-limited; prefill is more compute-limited; concurrency is memory-capacity-limited; the score includes power/energy.

## Common mistakes
- Using GPU utilization % as a measure of how busy the compute units are (it isn't — see [Occupancy](40_Occupancy.md)).

## Related concepts
[CUDA](30_CUDA.md) · [Streaming Multiprocessor](31_Streaming_Multiprocessor_SM.md) · [VRAM and HBM](33_VRAM_and_HBM.md) · [Memory Bandwidth](34_Memory_Bandwidth.md) · [NVIDIA A100](43_NVIDIA_A100.md)

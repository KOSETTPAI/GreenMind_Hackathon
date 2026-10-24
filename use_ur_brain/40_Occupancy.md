# 40. Occupancy

**Stage:** 2 | **Priority:** Should know (profiling detail) | **Prerequisites:** [Streaming Multiprocessor](31_Streaming_Multiprocessor_SM.md)

## In one sentence
Occupancy is the fraction of an SM's maximum resident warps that are actually active — it measures how much parallel work is available to hide latency, not how fast you're going.

## Plain-English explanation
GPUs hide slow memory reads by switching between many warps: while one waits, another computes. If too few warps are resident (low occupancy), the SM sits idle during waits. But high occupancy doesn't guarantee speed — a well-tuned kernel can be fast at modest occupancy.

Separately, `nvidia-smi`'s "GPU-Util" is **not** occupancy: it's the percentage of time *any* kernel was running. A GPU can show 100% util while using a small fraction of its compute.

## Technical depth
- Limited by registers per thread, shared memory per block, and block size.
- Theoretical occupancy (from resource usage) vs achieved occupancy (measured by Nsight Compute).
- Better signals: **SM Active %**, **SM Occupancy**, **Tensor pipe active %**, **DRAM bandwidth %** — available in DCGM profiling metrics (`DCGM_FI_PROF_SM_ACTIVE`, `DCGM_FI_PROF_SM_OCCUPANCY`, `DCGM_FI_PROF_PIPE_TENSOR_ACTIVE`, `DCGM_FI_PROF_DRAM_ACTIVE`).

## Backend-engineer analogy
Like thread-pool utilization vs actual CPU work: a pool can show all threads "busy" while they're mostly blocked on I/O.

## Why it matters for GreenMind
Don't use `nvidia-smi` utilization to declare the GPU saturated. Use DRAM-active and tensor-active metrics to decide if there's headroom for bigger batches.

## Common mistakes
- Treating occupancy as a score to maximize.
- Treating GPU-Util 100% as "nothing left to gain."

## Related concepts
[Profiling](92_Profiling.md) · [Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md) · [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md) · [Kernels](36_Kernels.md)

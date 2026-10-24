# 92. Profiling

**Stage:** 2 / 5 / 8 | **Priority:** Should know | **Prerequisites:** [Kernels](36_Kernels.md), [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md)

## In one sentence
Profiling measures where time and resources are actually spent — which kernels, which phases, CPU vs GPU, memory vs compute.

## Plain-English explanation
Metrics tell you *that* something is slow; profiling tells you *why*. Is the GPU idle waiting for the CPU? Is one kernel dominating? Is decode hitting the bandwidth limit? Profile before optimizing.

## Technical depth
**Tool ladder (cheap → deep):**
1. **Engine metrics** (`/metrics`, logs): queue length, running seqs, cache usage, preemptions, TTFT/TPOT histograms.
2. **nvidia-smi / DCGM**: power, clocks, memory; DCGM profiling fields (SM active, tensor active, DRAM active).
3. **CPU tools**: `top`/`htop`, `py-spy` on API server and engine processes.
4. **PyTorch profiler / vLLM profiling hooks** (vLLM supports a torch profiler output dir via env var/config — check your version): kernel-level timeline per step.
5. **Nsight Systems** (`nsys profile`): full CPU+GPU timeline — find idle gaps, launch overhead, sync points.
6. **Nsight Compute** (`ncu`): single-kernel deep dive — achieved bandwidth, occupancy, roofline position.

**Key questions:** GPU idle gaps? Which kernels take most time in prefill vs decode? Achieved bandwidth vs 1.555 TB/s in decode? Recurrent-layer kernels vs attention vs GEMMs share?

## Backend-engineer analogy
APM traces + flame graphs + DB query plans.

## Why it matters for GreenMind
Each optimization should target the measured bottleneck. Profiling also produces the "bottleneck evidence" the pitch needs.

## Common mistakes
- Optimizing by intuition.
- Profiling a single prompt instead of the realistic mixed workload.
- Leaving profilers on during scored runs (overhead).

## Related concepts
[Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md) · [Occupancy](40_Occupancy.md) · [Launch Overhead](41_Launch_Overhead.md) · [Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md)

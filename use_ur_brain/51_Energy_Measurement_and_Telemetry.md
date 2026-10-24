# 51. Energy Measurement and Telemetry

**Stage:** 2 / 5 / 9 | **Priority:** Must know | **Prerequisites:** [Watts vs Joules](50_Watts_vs_Joules.md)

## In one sentence
Telemetry is the recorded stream of operational measurements (power, energy counters, clocks, temperature, utilization, memory) used to compute energy and diagnose behavior.

## Plain-English explanation
You can't optimize what you don't measure. During every benchmark, record GPU power and energy alongside request logs so you can compute joules per useful request and see *when* power spikes (prefill? idle? warmup?).

## Technical depth
**nvidia-smi (NVML):**
```bash
nvidia-smi --query-gpu=timestamp,power.draw,total_energy_consumption,clocks.sm,clocks.mem,temperature.gpu,utilization.gpu,memory.used --format=csv -lms 100 > gpu_telemetry.csv
```
- `total_energy_consumption` is a cumulative counter in **millijoules** since driver load → energy = end − start. Usually more accurate than integrating sampled `power.draw`.
- `power.draw` may be averaged over a window by the driver; sampling too slowly misses spikes.

**DCGM:** `dcgmi dmon -e 155,156,...` or DCGM exporter for Prometheus. Fields: `DCGM_FI_DEV_POWER_USAGE` (W), `DCGM_FI_DEV_TOTAL_ENERGY_CONSUMPTION` (mJ), plus profiling metrics (SM active, tensor active, DRAM active).

**Engine metrics:** vLLM exposes Prometheus `/metrics` (running/waiting requests, cache usage, preemptions, TTFT/TPOT histograms).

**Practice:**
- Record idle, load, warmup, prefill-heavy, decode-heavy, and full benchmark phases separately.
- Align telemetry timestamps with request logs.
- Control for temperature and clocks (thermal throttling changes results).

## Backend-engineer analogy
Observability stack: metrics (Prometheus), traces (per-request timings), and resource monitoring — joined by timestamp.

## Why it matters for GreenMind
Energy is a scored component. Your measurements must match the grader's source, window, and boundary — or your tuning decisions will be wrong.

## Common mistakes
- Integrating coarse power samples instead of using the energy counter.
- Running benchmarks while another process uses the GPU.
- Different thermal states between runs.

## Related concepts
[Energy Boundary](8_Energy_Boundary.md) · [Measurement Window](7_Measurement_Window.md) · [Measurement Harness](89_Measurement_Harness.md) · [Profiling](92_Profiling.md) · [Occupancy](40_Occupancy.md)

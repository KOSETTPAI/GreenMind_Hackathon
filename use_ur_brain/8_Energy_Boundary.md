# 8. Energy Boundary

**Stage:** 0 / 9 | **Priority:** Must know | **Prerequisites:** [Measurement Window](7_Measurement_Window.md)

## In one sentence
The energy boundary defines *which hardware's* energy is counted — GPU only, GPU + CPU, or the whole system — and from which telemetry source.

## Plain-English explanation
A server draws power from the GPU, CPU, RAM, fans, disks, and power supply losses. The grader probably counts only some of these. The roadmap describes the goal as minimizing **GPU energy**, but the exact boundary must come from the briefing.

This matters because some optimizations move work between components: e.g., shifting tokenization to more CPU processes, or offloading to CPU RAM, may lower GPU joules while raising system joules.

## Technical depth
- **GPU-only:** typically read from NVML (`nvidia-smi --query-gpu=power.draw` or `total_energy_consumption`) or DCGM (`DCGM_FI_DEV_POWER_USAGE`, `DCGM_FI_DEV_TOTAL_ENERGY_CONSUMPTION`, in millijoules).
- **System:** would require RAPL for CPU, PDU/IPMI for wall power.
- Different sources sample differently (averaging windows, update rates). Use the **same source as the grader**.

## Backend-engineer analogy
Like cost allocation: is the "cost of the service" just the compute instance, or does it include the database, network egress, and load balancer?

## Why it matters for GreenMind
If only GPU energy counts, GPU efficiency (SLO-met requests per GPU joule) is king. The confirmed baseline is 0.00154 SLO-met requests/J, with full marks at 3× (0.00462). Your measured η is only comparable to those numbers if you use the grader's exact boundary. Also, GPU idle power (~50–60 W on an A100) during quiet periods may be counted, which sets an energy floor that limits how close to 3× you can get.

## Common mistakes
- Substituting total-system energy for GPU energy, or vice versa.
- Using `nvidia-smi` instantaneous watts while the grader integrates DCGM energy counters.

## Related concepts
[Watts vs Joules](50_Watts_vs_Joules.md) · [Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md) · [Energy per Useful Request](121_Energy_per_Useful_Request.md) · [Host System](42_Host_System_CPU_RAM_Storage_Network.md)

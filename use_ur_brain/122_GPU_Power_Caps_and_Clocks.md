# 122. GPU Power Caps and Clock Settings

**Stage:** 9 | **Priority:** Advanced | **Prerequisites:** [Watts vs Joules](50_Watts_vs_Joules.md), [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md)

## In one sentence
Power caps and clock limits lower the GPU's instantaneous power draw, which can reduce total energy if runtime doesn't grow much — or increase it if work slows too much.

## Plain-English explanation
GPUs are less efficient at their highest clocks: the last 10–20% of performance costs a disproportionate amount of power. For memory-bound decode, lowering the SM clock often barely changes speed (memory is the limit) but saves power → fewer joules. For compute-bound prefill, lower clocks directly slow things down.

## Technical depth
- Query: `nvidia-smi -q -d POWER,CLOCK`.
- Set power limit (needs admin): `sudo nvidia-smi -pl 250` (watts, within min/max limits).
- Lock clocks: `sudo nvidia-smi -lgc <min>,<max>` (graphics), reset with `-rgc`. Memory clocks on A100 HBM are generally fixed.
- Energy trade-off: `E = P × T`. If a cap lowers P by 20% and raises T by 5% → E drops ~16%. If T rises 30% → E rises.
- Risks: TPOT/TTFT SLO violations, lower peak throughput → more queueing at peak → fewer useful requests.
- **Permission:** likely restricted or impossible in the evaluation environment — check the rules.

## Backend-engineer analogy
Running servers in a power-saving CPU governor: fine for I/O-bound workloads, harmful for CPU-bound ones.

## Why it matters for GreenMind
Roadmap experiment #9 — only if permitted. Test end-to-end J/useful request under the real workload, not watts alone.

## Common mistakes
- Celebrating lower watts while joules went up.
- Applying caps that push p95 past SLO limits.

## Related concepts
[Energy per Useful Request](121_Energy_per_Useful_Request.md) · [NVIDIA A100](43_NVIDIA_A100.md) · [Allowed Artifacts](9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [SLO](11_SLO.md)

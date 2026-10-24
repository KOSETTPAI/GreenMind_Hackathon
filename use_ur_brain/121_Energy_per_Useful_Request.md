# 121. Energy per Useful Request (and Useful Requests per Joule)

**Stage:** 9 — Energy-aware optimization | **Priority:** Must know | **Prerequisites:** [Watts vs Joules](50_Watts_vs_Joules.md), [Useful Requests](12_Useful_Requests.md)

## In one sentence
Energy per useful request is total energy over the official window divided by the number of requests that met the useful-work definition; its inverse is useful requests per joule.

## Plain-English explanation
This is the efficiency metric that matters: how many joules does it cost to deliver one *good* answer? Failed or late requests add energy but don't count, so they make this worse twice.

## Technical depth
- `J_per_useful = E_J / N_useful`.
- `Efficiency = N_useful / E_J` (useful requests per joule).
- Example: 250 W × 40 s = 10,000 J; 800 useful → 12.5 J/request, or 0.08 useful requests/J.
- Not interchangeable with tokens/s or tokens/J — a config that produces longer outputs may look better per token and worse per request.
- **Levers:** bigger batches (more work per weight read), quantization (fewer bytes moved), fewer wasted tokens (preemption recompute, timed-out requests not cancelled), prefix caching (skip prefill), power/clock tuning, avoiding idle burn (if idle counted).
- Denominator definition (all, successful, or on-time requests) comes from the briefing.

## Backend-engineer analogy
Cost per successful transaction — the unit economics of the service.

## Why it matters for GreenMind
Likely the basis of the logarithmic energy score `s_E`. Every experiment row should include this number.

## Common mistakes
- Using total completed requests as the denominator.
- Using tokens/s as a proxy for energy efficiency.

## Related concepts
[Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md) · [GPU Power Caps and Clocks](122_GPU_Power_Caps_and_Clocks.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Energy Boundary](8_Energy_Boundary.md)

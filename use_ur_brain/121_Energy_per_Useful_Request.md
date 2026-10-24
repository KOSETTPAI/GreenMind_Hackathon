# 121. Energy per Useful Request (and SLO-Met Requests per Joule)

**Stage:** 9 — Energy-aware optimization | **Priority:** Must know | **Prerequisites:** [Watts vs Joules](50_Watts_vs_Joules.md), [Useful Requests](12_Useful_Requests.md)

## In one sentence
Energy efficiency η is the number of SLO-met requests divided by the energy consumed over the official window; its inverse is the energy cost of one SLO-met request.

## Confirmed scoring constants
Only the Final counts, and its baseline is stricter. The worked numbers further down use the Validation baseline (0.00154).

| Constant | Validation (practice) | **Final (graded)** |
|---|---|---|
| `η_base` | 0.00154 SLO-met requests/J (≈ 649 J per request) | **0.00163 SLO-met requests/J (≈ 613 J per request)** |
| `K` | 3× | 3× |
| Full-marks target | η ≥ 0.00462 (≈ 216 J per request) | **η ≥ 0.00489 (≈ 204 J per request)** |

`s_E = clip(ln(η / η_base) / ln 3, 0, 1)` is confirmed on the grader page.

## Plain-English explanation
This is the efficiency metric that matters: how many joules does it cost to deliver one request that met its SLOs? Requests that miss an SLO, error, or time out still burn energy but add nothing to the numerator, so they hurt twice.

At baseline the server spends about 649 J per SLO-met request. To earn full energy marks you must bring that down to about 216 J, which means delivering three times as many SLO-met requests per joule.

## Technical depth
- `η = N_SLO-met / E_J` and `J_per_SLO-met = E_J / N_SLO-met = 1/η`.
- **Score curve:** the briefing describes the energy score as logarithmic, with baseline, clipping, and saturation. Combined with the confirmed constants, the natural reading is:
  `s_E = clip( ln(η / η_base) / ln(K), 0, 1 )`, with `K = 3`.
  The log base doesn't matter because it cancels in the ratio. **Treat this exact expression as inferred** until you confirm it against the briefing text, especially whether values below baseline clip to 0.

| η / η_base | η (SLO-met req/J) | J per SLO-met request | s_E (inferred log form) |
|---:|---:|---:|---:|
| 1.00 | 0.00154 | 649 | 0.000 |
| 1.25 | 0.00193 | 519 | 0.203 |
| 1.50 | 0.00231 | 433 | 0.369 |
| 2.00 | 0.00308 | 325 | 0.631 |
| 2.50 | 0.00385 | 260 | 0.834 |
| 3.00 | 0.00462 | 216 | 1.000 (saturated) |

- **Diminishing returns:** on a log curve, every multiplicative gain is worth the same. Going 1× → 1.5× earns about 0.37; going 2× → 3× (also 1.5×) earns the same 0.37. Early gains are cheap; the last ones are expensive.
- **Fixed workload implication:** the grader sends a fixed set of requests, so the numerator is capped at the total sent. If the baseline already meets SLO on most requests, reaching 3× means cutting **window energy to roughly one third** of baseline, not just running faster.
- **Idle floor:** if idle time is inside the measurement window, `E ≥ P_idle × T_window` no matter how efficient the active work is. An A100 idles at very roughly 50–60 W, so check whether this floor alone limits your achievable η.
- **Worked example:** 250 W average for 3,600 s = 900 kJ. With 1,386 SLO-met requests, η = 0.00154 (exactly baseline, s_E = 0). The same requests at 300 kJ give η = 0.00462 (full marks).
- **Levers:** bigger batches (more work per weight read), quantization (fewer bytes moved), fewer wasted tokens (preemption recompute, timed-out requests that weren't cancelled), prefix caching (skips prefill), power/clock tuning, and avoiding idle burn if idle time counts.
- Not interchangeable with tokens/s or tokens/J: a config that produces longer outputs can look better per token and worse per request.

## Backend-engineer analogy
Cost per successful transaction, the unit economics of the service, with a target of cutting it to one third of the reference cost.

## Why it matters for GreenMind
η is the input to the energy score `s_E`. Every experiment row should record `η`, `η / η_base`, and the resulting `s_E`.

## Common mistakes
- Using total completed requests instead of SLO-met requests as the numerator.
- Using tokens/s as a proxy for energy efficiency.
- Continuing to optimize energy once `η ≥ 0.00462`, where the score is already saturated.

## Related concepts
[Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md) · [Clipping and Saturation](123_Clipping_and_Saturation.md) · [GPU Power Caps and Clocks](122_GPU_Power_Caps_and_Clocks.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Energy Boundary](8_Energy_Boundary.md)

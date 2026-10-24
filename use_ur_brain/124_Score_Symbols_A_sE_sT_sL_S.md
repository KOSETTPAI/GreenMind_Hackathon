# 124. Score Symbols: A, s_E, s_T, s_L, S

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md), [Clipping and Saturation](123_Clipping_and_Saturation.md)

## In one sentence
These are the event-specific score symbols — accuracy factor (A), energy score (s_E), throughput score (s_T), latency score (s_L), and final technical score (S) — whose exact formulas must come from the official briefing.

## Plain-English explanation
| Symbol | Meaning | What to verify |
|---|---|---|
| `A` | Accuracy factor from accuracy/retention | formula, floors, thresholds, clipping |
| `s_E` | Energy score (reportedly logarithmic) | baseline, log base, scale, clipping, saturation |
| `s_T` | Throughput score | normalizer, cap, whether SLO failures count |
| `s_L` | Latency score | how TTFT/TPOT/p95 combine, normalization |
| `S` | Final technical score | equation, weights, gates, rounding order |
| Pitch/final ranking | weighted technical + pitch criteria | criteria, weights, tie-breaks, eligibility |

**The roadmap is explicit: do not infer formulas from notation alone.**

## Technical depth
Once you have the official equations:
1. Implement them exactly in your analyzer.
2. Compute partial derivatives / sensitivities: how much does S change for a 10% energy cut vs a 10% p95 improvement vs a 1-point accuracy drop?
3. Use that to prioritize experiments.
4. Rank candidates by S (with variance), not by any single metric.

## Backend-engineer analogy
A weighted KPI scorecard — you need the exact weights and formulas before you can optimize toward it.

## Why it matters for GreenMind
These define the optimization objective. Everything else is a proxy.

## Common mistakes
- Guessing the formula and tuning to the guess.
- Ranking candidates by raw speed.

## Related concepts
[Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Hard Gates](2_Hard_Gates_and_Eligibility.md) · [Continuous Score Components](3_Continuous_Score_Components.md) · [Final Pitch](129_Final_Pitch.md)

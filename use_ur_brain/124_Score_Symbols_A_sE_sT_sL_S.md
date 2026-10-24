# 124. Score Symbols: A, s_E, s_T, s_L, S

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md), [Clipping and Saturation](123_Clipping_and_Saturation.md)

## In one sentence
These are the event-specific score symbols: accuracy factor (A), energy score (s_E), throughput score (s_T), latency score (s_L), and final technical score (S). Some constants are now confirmed; the rest must still come from the official briefing.

## Confirmed scoring constants
Only the Final counts, and it has its own baseline.

| Constant | Validation (practice) | **Final (graded)** | Used by |
|---|---|---|---|
| `η_base` | 0.00154 SLO-met requests/J | **0.00163 SLO-met requests/J** | `s_E` (baseline efficiency) |
| `K` | 3× (full marks at `η ≥ 0.00462`) | **3× (full marks at `η ≥ 0.00489`)** | `s_E` (saturation point) |
| Reference macro-accuracy | 87.2% | **87.8%** | `A` (accuracy retention reference) |

All five formulas are now confirmed on the grader page; see [`scoring_criteria.md`](../scoring_criteria.md). The "still to verify" column below predates that.

## Status of each symbol
| Symbol | Meaning | Confirmed | Still to verify |
|---|---|---|---|
| `A` | Accuracy factor from macro-accuracy retention | reference = 87.2% macro-accuracy | retention cutoff, formula shape, floors, clipping |
| `s_E` | Energy score (logarithmic) | `η_base` = 0.00163 Final / 0.00154 Validation, `K = 3`, efficiency measured in SLO-met requests/J | exact expression (inferred below), behavior below baseline |
| `s_T` | Throughput score | — | normalizer, cap, whether SLO failures count |
| `s_L` | Latency score | — | how TTFT/TPOT/p95 combine, normalization |
| `S` | Final technical score | — | equation, weights, gates, rounding order |
| Pitch/final ranking | Weighted technical + pitch criteria | — | criteria, weights, tie-breaks, eligibility |

## Technical depth
**Energy score (confirmed on the grader page):**
```
η   = N_SLO-met / E_J
s_E = clip( ln(η / η_base) / ln(3), 0, 1 )     η_base = 0.00163 Final, 0.00154 Validation
```
- `s_E = 0` at baseline efficiency and `s_E = 1` at 3× baseline (Final: 0.00489 SLO-met req/J ≈ 204 J per request; Validation: 0.00462 ≈ 216 J).
- Each doubling of η is worth `ln 2 / ln 3 ≈ 0.63` of the component, until it saturates.

**Accuracy:**
```
Retention = MacroAcc_candidate / 0.872
```
- Each 1-point drop in macro-accuracy costs about 1.15% of relative retention.
- The retention cutoff and how retention maps to `A` are still unknown.

**Process once the remaining equations are known:**
1. Implement them exactly in your analyzer, keeping the inferred `s_E` form clearly marked until you confirm it.
2. Compute sensitivities: how much does S change for a 10% energy cut vs a 10% p95 improvement vs a 1-point accuracy drop?
3. Use those sensitivities to prioritize experiments.
4. Rank candidates by S (with variance), not by any single metric.

## Backend-engineer analogy
A weighted KPI scorecard where some targets are now published (the energy reference and its full-marks point, and the accuracy reference) and the weights are still pending.

## Why it matters for GreenMind
These define the optimization objective; everything else is a proxy. With `η_base` and `K` known, you can already compute your energy score position from your own measurements.

## Common mistakes
- Treating the inferred `s_E` expression as confirmed without checking the briefing text.
- Measuring η with all completed requests instead of SLO-met requests.
- Ranking candidates by raw speed.

## Related concepts
[Energy per Useful Request](121_Energy_per_Useful_Request.md) · [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Hard Gates](2_Hard_Gates_and_Eligibility.md) · [Continuous Score Components](3_Continuous_Score_Components.md) · [Final Pitch](129_Final_Pitch.md)

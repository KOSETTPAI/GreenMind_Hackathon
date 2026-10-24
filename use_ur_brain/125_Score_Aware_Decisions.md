# 125. Score-Aware Decisions (Why Faster Can Score Worse)

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md), [Energy per Useful Request](121_Energy_per_Useful_Request.md)

## In one sentence
Score-aware decision making means choosing configurations by their effect on the official score — including gates, useful requests, and energy — not by a single speed metric.

## Plain-English explanation
Worked example using the Validation energy constants (`η_base = 0.00154` SLO-met req/J, `K = 3`). For a graded decision use the Final baseline, `η_base = 0.00163`, and judge on Final results: Validation scores do not predict the Final. The workload numbers are invented, scaled to be realistic for one A100: the same 1,000-request workload in both runs.

| Metric | Candidate X | Candidate Y |
|---|---:|---:|
| Wall time | 1,500 s | 1,300 s |
| Average GPU power | 267 W | 323 W |
| GPU energy | 400 kJ | 420 kJ |
| SLO-met requests | 980 | 900 |
| η (SLO-met requests/J) | 0.00245 | 0.00214 |
| η / η_base | 1.59× | 1.39× |
| s_E (inferred log form) | 0.42 | 0.30 |

Y is about 13% faster, but it draws more power, uses more total energy, and lets 80 more requests miss their SLOs. Its energy score is about 0.12 lower. **Y loses despite raw speed.**

Neither candidate is close to full energy marks (3×, or 0.00462 SLO-met req/J). For either one to reach it with 980 SLO-met requests, window energy would have to fall to about 212 kJ.

## Technical depth
**Decision checklist for every candidate:**
1. Passes all hard gates (accuracy retention, API correctness, stability) with margin?
2. SLO pass rate / useful requests ≥ best-known?
3. η vs best-known and vs the track's `η_base` (Final 0.00163, saturated at ≥ 0.00489; Validation 0.00154, saturated at ≥ 0.00462)?
4. Each component score (`s_E`, `s_T`, `s_L`, `A`) and final S — median over repetitions.
5. Improvement larger than run-to-run noise?
6. Per-category regressions?

Keep two columns: **hard gates** (pass/fail) and **continuous terms**. Ask organizers about boundary equality, failed/retried requests, malformed tool calls, and zero-sample components.

## Backend-engineer analogy
Choosing a deployment by total cost per successful transaction under SLO, not by peak QPS on a microbenchmark.

## Why it matters for GreenMind
Mastery criterion for Stage 9: "you can tell whether a proposed optimization improves the metric the grader actually rewards and whether it crosses a hard SLO boundary."

## Common mistakes
- Declaring a win from wall time or tokens/s alone.
- Ignoring the numerator of η (SLO-met requests): a missed SLO costs energy and earns nothing.

## Related concepts
[Useful Requests](12_Useful_Requests.md) · [Clipping and Saturation](123_Clipping_and_Saturation.md) · [Controlled Experiments](127_Controlled_Experiments.md) · [Submission Discipline](128_Submission_Discipline.md)

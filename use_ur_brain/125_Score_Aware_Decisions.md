# 125. Score-Aware Decisions (Why Faster Can Score Worse)

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md), [Energy per Useful Request](121_Energy_per_Useful_Request.md)

## In one sentence
Score-aware decision making means choosing configurations by their effect on the official score — including gates, useful requests, and energy — not by a single speed metric.

## Plain-English explanation
The roadmap's worked example (invented numbers, same 1,000-request workload):

| Metric | Candidate X | Candidate Y |
|---|---:|---:|
| Wall time | 80 s | 65 s |
| GPU energy | 20 kJ | 22 kJ |
| Useful/on-time requests | 980 | 900 |
| Useful requests/joule | 0.049 | 0.0409 |

Y is ~19% faster, but uses more energy and delivers fewer useful requests — worse efficiency. If the score rewards energy efficiency and enforces SLOs, **Y loses despite raw speed**.

## Technical depth
**Decision checklist for every candidate:**
1. Passes all hard gates (accuracy retention, API correctness, stability) with margin?
2. SLO pass rate / useful requests ≥ best-known?
3. J per useful request vs best-known?
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
- Ignoring the denominator (useful requests).

## Related concepts
[Useful Requests](12_Useful_Requests.md) · [Clipping and Saturation](123_Clipping_and_Saturation.md) · [Controlled Experiments](127_Controlled_Experiments.md) · [Submission Discipline](128_Submission_Discipline.md)

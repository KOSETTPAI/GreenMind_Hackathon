# 129. Final Pitch (and Pitch Rubric)

**Stage:** 10 | **Priority:** Must know | **Prerequisites:** [Experiment Log](90_Experiment_Log.md), [Score-Aware Decisions](125_Score_Aware_Decisions.md)

## In one sentence
The final pitch explains, with evidence, why your configuration is better under the actual score — baseline, bottleneck, hypothesis, controlled experiment, result, trade-offs, energy impact, limitations, and reproducibility.

## Plain-English explanation
Judges want a clear engineering story, not just a number. Show you understood the problem, measured before changing things, tested hypotheses one at a time, and know the limits of your results. A failed experiment is valuable if it narrowed down the bottleneck.

## Suggested structure
1. **Problem & constraints** — model, A100 40 GB, workload, scoring, gates.
2. **Baseline** — reproduced metrics with noise floor.
3. **Bottleneck evidence** — profiling/telemetry showing what limits performance (e.g., decode bandwidth-bound, prefill interference driving p95 TTFT).
4. **Hypotheses & controlled experiments** — one change at a time, results table with medians and spread.
5. **Final configuration** — what changed and why.
6. **Results** — every score component, SLO pass rate, accuracy per category, J/useful request vs baseline.
7. **Trade-offs & limitations** — what got worse, what's uncertain, what you'd do with more time.
8. **Reproducibility** — launch script, hashes, environment.

Distinguish **measured facts** from **interpretation**.

## Pitch rubric
The final ranking reportedly combines the technical score with weighted pitch criteria — exact criteria, weights, and tie-breaks must come from the briefing. Map each slide to a rubric criterion once known.

## Backend-engineer analogy
A post-project performance review / design-doc defense: data, decisions, trade-offs, and what's next.

## Why it matters for GreenMind
Part of the final ranking. Mastery: "defend why the final configuration is better under the actual score, not merely faster in one metric."

## Common mistakes
- Presenting only a speedup number.
- Claiming causes without evidence.
- Hiding regressions.

## Related concepts
[Experiment Log](90_Experiment_Log.md) · [Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md) · [Submission Discipline](128_Submission_Discipline.md) · [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md)

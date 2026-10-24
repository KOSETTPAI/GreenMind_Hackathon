# 127. Controlled Experiments

**Stage:** 6 / 10 | **Priority:** Must know | **Prerequisites:** [Experiment Log](90_Experiment_Log.md), [Run-to-Run Variance](91_Run_to_Run_Variance.md)

## In one sentence
A controlled experiment changes exactly one variable while holding everything else fixed, repeats the run, and judges the result by the official score.

## Plain-English explanation
If you change three flags and the score improves, you don't know which one helped — or whether one of them hurt. Change one thing, measure properly, decide, then move on.

## The 10 rules (from the roadmap, Phase D)
1. One independent change per experiment; record every config diff.
2. Same workload, arrival schedule, seeds, warmup, measurement window, hardware state.
3. Repeat runs; compare medians and spread, not a single lucky result.
4. Keep raw per-request records, not just aggregates.
5. Evaluate correctness and API semantics before comparing speed.
6. Keep category-level metrics so aggregates can't hide Thai/coding/tool-call regressions.
7. Rank candidates with the actual official scoring formula.
8. Maintain a rollback path and a frozen "best-known" artifact.
9. Avoid hidden-test overfitting; never exploit grader bugs.
10. Save a final reproducibility bundle: launch script, environment, hashes, logs, limitations.

## Suggested experiment order (roadmap Phase C)
1 reproduce baseline → 2 batch token budget / chunked prefill → 3 max sequences / cache allocation → 4 prefix caching → 5 CPU/API capacity → 6 lower-precision artifact → 7 speculative decoding → 8 alternative engine → 9 power/clocks (if permitted) → 10 custom kernels.

## Backend-engineer analogy
A/B testing with a single variable, or bisecting a performance regression.

## Why it matters for GreenMind
It's the only way to produce trustworthy wins and a defensible pitch.

## Common mistakes
- Changing multiple flags at once.
- Moving to riskier experiments before preserving the best-known config.

## Related concepts
[Experiment Log](90_Experiment_Log.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md) · [Submission Discipline](128_Submission_Discipline.md)

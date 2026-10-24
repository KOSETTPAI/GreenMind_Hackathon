# 5. Validation vs Final Submission

**Stage:** 0 / 10 | **Priority:** Must know | **Prerequisites:** [Baseline](4_Baseline.md)

## In one sentence
A validation run is a feedback signal on a visible or sample workload; the final submission is scored on the real (often hidden) workload — good validation is evidence, not proof.

## Plain-English explanation
Organizers usually give you a validation set or a practice grader so you can check your server. The final grade uses a different or larger set. If you tune obsessively to the validation set (for example, special-casing particular prompts), you can score well there and badly on the hidden test.

Submissions are often **limited** in number, so each one should be a frozen, tested candidate — not an experiment.

## Technical depth
- **Overfitting to validation:** choosing configurations based on tiny differences that are within noise, or that exploit quirks of the visible prompts.
- **Distribution shift:** the hidden test may have a different mix of Thai, coding, long-context, or tool-call requests.
- Best practice: evaluate per category, repeat runs, prefer robust configurations with margin from gates.

## Backend-engineer analogy
Staging vs production. Passing staging load tests is necessary, but production traffic can differ. You don't deploy an untested build to prod just because you have one deploy slot left.

## Why it matters for GreenMind
The rules forbid tuning to hidden tests or exploiting evaluator behavior. Treat validation as a measurement tool and the final submission as a release.

## Common mistakes
- Confusing validation scores with final scores.
- Burning a limited submission on an untested idea.
- Selecting the single best lucky validation run instead of the median of repeated runs.

## Related concepts
[Submission Discipline](128_Submission_Discipline.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md) · [Workload Mix](6_Workload_Mix.md) · [Controlled Experiments](127_Controlled_Experiments.md)

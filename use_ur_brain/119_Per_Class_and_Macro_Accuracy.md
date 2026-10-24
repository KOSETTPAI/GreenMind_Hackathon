# 119. Per-Class and Macro Accuracy

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Accuracy](118_Accuracy.md)

## In one sentence
Per-class accuracy is accuracy computed separately per category (e.g., Thai, coding, tool calls); macro accuracy is the unweighted mean of those per-class accuracies.

## Plain-English explanation
If 90% of the test is English chat and 10% is Thai, overall (micro) accuracy barely moves when Thai collapses. Macro accuracy gives each category **equal weight**, so a Thai collapse hurts a lot.

Example: English 95%, Thai 60% → macro = (95 + 60)/2 = 77.5%, while micro (with 90/10 split) = 91.5%.

## Technical depth
- `MacroAcc = (1/K) Σ_{k=1..K} Acc_k`.
- Micro accuracy = total correct / total items (weighted by class size).
- Clarify with the briefing: class definitions, missing-class handling (class with zero items?), whether macro is used for retention.
- Quantization and other changes often hurt minority categories (Thai, long-context recall, structured tool calls) disproportionately.

## Backend-engineer analogy
Per-endpoint SLOs instead of one global error rate — a broken low-traffic endpoint is still broken.

## Why it matters for GreenMind
The roadmap lists per-class and macro accuracy in the scoring reference. Always report per-category results for every experiment.

## Common mistakes
- Letting an aggregate hide a Thai/coding/tool-call regression.
- Calibrating quantization on data that under-represents a category.

## Related concepts
[Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md) · [Workload Mix](6_Workload_Mix.md) · [Calibration](104_Calibration.md) · [Accuracy](118_Accuracy.md)

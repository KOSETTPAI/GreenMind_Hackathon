# 4. Baseline

**Stage:** 0 / 5 | **Priority:** Must know | **Prerequisites:** [Hard Gates](2_Hard_Gates_and_Eligibility.md)

## In one sentence
The baseline is the designated reference configuration (and its measured results) against which your accuracy, speed, and energy are compared.

## Plain-English explanation
"Better" only means something relative to a reference. In this event the baseline is described as the unmodified model in BF16 served by vLLM (verify in the briefing). Accuracy retention, energy score, and possibly throughput/latency scores are likely all computed relative to it.

There are two baselines to keep in mind:
1. **Official baseline** — what the grader uses as the reference.
2. **Your reproduced baseline** — what you measure on your hardware with your harness. If you can't reproduce the official numbers, your measurements aren't trustworthy yet.

## Confirmed official reference values
| Reference | Value |
|---|---|
| Baseline energy efficiency `η_base` | **0.00154 SLO-met requests/J** (≈ 649 J per SLO-met request) |
| Full energy marks | **K = 3×** baseline → η ≥ 0.00462 SLO-met requests/J (≈ 216 J per request) |
| Reference macro-accuracy | **87.2%** |

Your reproduced baseline should land near these values. If it doesn't, your harness, energy boundary, measurement window, or accuracy judge probably differs from the grader's. Fix that before tuning anything.

## Technical depth
A baseline record must include: model/checkpoint hash, tokenizer + chat template, engine and library versions, launch command and flags, dtype, GPU SKU and driver, environment variables, sampling settings, max context/output, warmup procedure, load schedule, telemetry source, dataset version, scoring script version.

Run it multiple times to learn the **noise floor** — the variation between identical runs. Any "improvement" smaller than this is not real.

## Backend-engineer analogy
Like capturing a performance baseline before a refactor: same load test, same hardware, same build — otherwise your before/after comparison is meaningless.

## Why it matters for GreenMind
- Accuracy retention = candidate macro-accuracy / 87.2%.
- Energy score uses baseline efficiency (0.00154 SLO-met req/J) as its zero point and 3× that as full marks.
- Without a solid baseline, you can't tell whether a flag change helped or whether the GPU was just cooler that run.

## Common mistakes
- Tuning before reproducing the baseline.
- Comparing against a baseline run with different output lengths or workload.
- Recording only aggregate numbers instead of raw per-request logs.

## Related concepts
[Reproducibility](87_Reproducibility.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md) · [Experiment Log](90_Experiment_Log.md) · [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md) · [BF16](46_BF16.md)

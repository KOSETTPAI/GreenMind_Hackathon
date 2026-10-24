# 87. Reproducibility

**Stage:** 5 — Baseline & harness | **Priority:** Must know | **Prerequisites:** [Baseline](4_Baseline.md)

## In one sentence
Reproducibility means someone else (or you, next week) can rerun an experiment from your records and get comparable results.

## Plain-English explanation
If you can't reproduce a result, you can't trust it, defend it in the pitch, or rebuild it after a mistake. Every experiment needs enough recorded detail to rerun it exactly.

## Technical depth
**Record for every run:**
- Model artifact hashes (weights, tokenizer, config, chat template).
- Engine + library versions (`pip freeze`), CUDA/driver versions, container image digest.
- Exact launch command and all environment variables.
- Hardware: GPU SKU (PCIe/SXM), power limit, clocks, MIG state, other GPU processes.
- Workload/dataset version, arrival schedule, seeds, sampling params.
- Raw per-request logs, server logs, telemetry, scoring script version.

**Practices:** launch scripts in git (no hand-typed commands); one config file per experiment; `nvidia-smi -q` snapshot per run; a final "reproducibility bundle" for submission.

## Backend-engineer analogy
Infrastructure-as-code + pinned dependencies + immutable artifacts + runbooks.

## Why it matters for GreenMind
Mastery criterion for the baseline stage: "another person can reproduce your run from the log." Judges reward evidence you can defend.

## Common mistakes
- Changing multiple flags at once and not recording which.
- Logging only a screenshot of aggregate metrics.

## Related concepts
[Experiment Log](90_Experiment_Log.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md) · [Submission Discipline](128_Submission_Discipline.md) · [Checkpoint](14_Checkpoint.md)

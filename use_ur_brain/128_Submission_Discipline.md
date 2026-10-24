# 128. Submission Discipline

**Stage:** 10 — Validation & submission | **Priority:** Must know | **Prerequisites:** [Validation vs Final Submission](5_Validation_vs_Final_Submission.md), [Controlled Experiments](127_Controlled_Experiments.md)

## In one sentence
Submission discipline is the release process for a final candidate: freeze, smoke-test, validate, compare every gate and score component, repeat, preserve artifacts — and only then spend a limited submission.

## Plain-English explanation
Treat a submission like a production release with one deploy slot. Never submit an experiment; submit a frozen, verified configuration with a known rollback.

## Workflow (from the roadmap)
1. **Freeze** a candidate (config, artifact hashes, launch script, environment).
2. Run **smoke tests**.
3. Run **validation** (official workload unchanged).
4. Compare **every score component and hard gate** against best-known.
5. Inspect **per-category accuracy and errors**.
6. **Repeat** to check noise.
7. **Preserve** artifact hashes and launch instructions.
8. Only then use a **limited final submission**.

Never tune directly to hidden tests or exploit evaluator behavior.

## Final checklist
- [ ] Frozen best-known configuration and rollback path.
- [ ] Validation results, raw logs, telemetry, hashes, launch instructions.
- [ ] Offline startup tested (no network).
- [ ] Startup time within limits; no crashes over the full schedule.
- [ ] Energy impact quantified; measurement vs hypothesis distinguished.

## Backend-engineer analogy
Release management: code freeze, release candidate, staging validation, change approval, rollback plan.

## Why it matters for GreenMind
Submissions are limited; a broken submission can cost the event. Discipline converts experimental wins into an actual score.

## Common mistakes
- Last-minute flag changes after validation.
- No rollback to the previous best.

## Related concepts
[Reproducibility](87_Reproducibility.md) · [Smoke Testing](88_Smoke_Testing.md) · [Final Pitch](129_Final_Pitch.md) · [Hard Gates](2_Hard_Gates_and_Eligibility.md)

# 90. Experiment Log

**Stage:** 5 | **Priority:** Must know | **Prerequisites:** [Reproducibility](87_Reproducibility.md)

## In one sentence
The experiment log is a structured ledger with one row per run — hypothesis, config diff, results, and decision — so every claim is traceable.

## Plain-English explanation
During a hackathon you'll run dozens of experiments. Without a log, you'll forget which flag produced which result, rerun things, and be unable to justify choices in the pitch.

## Technical depth
**Columns (from the roadmap):**
ID · date · code commit · model hash · engine version · config diff · hypothesis · workload · repetitions · accuracy · accuracy retention · TTFT/p95 · TPOT · throughput · SLO pass rate · GPU joules · joules/useful request · score components · final score · failure notes · decision.

**Columns derived from the confirmed scoring constants:**
- `macro_acc`, `retention = macro_acc / 0.872`
- `SLO_met`, `E_J`, `η = SLO_met / E_J`, `η / 0.00154`
- `s_E = clip(ln(η / 0.00154) / ln 3, 0, 1)` (inferred form; flag it as such until you confirm it)
- `energy_saturated = η ≥ 0.00462`

**Tips:**
- Store as CSV/Markdown/spreadsheet in git; link to raw log folders.
- Write the hypothesis *before* running ("Raising max_num_batched_tokens to 8192 will lower TTFT p95 for RAG without hurting TPOT").
- Record **failed** experiments — they narrow the bottleneck hypothesis and are good pitch material.
- Mark a "best-known" row and keep its artifacts frozen.

## Backend-engineer analogy
A change log + incident log + benchmark dashboard rolled into one — like an ADR (architecture decision record) per experiment.

## Why it matters for GreenMind
The final pitch must explain baseline → bottleneck evidence → hypothesis → controlled experiment → result. The log *is* that story.

## Common mistakes
- Not writing down the hypothesis.
- Deleting failed runs.

## Related concepts
[Controlled Experiments](127_Controlled_Experiments.md) · [Reproducibility](87_Reproducibility.md) · [Final Pitch](129_Final_Pitch.md) · [Measurement Harness](89_Measurement_Harness.md)

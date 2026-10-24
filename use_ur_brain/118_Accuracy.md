# 118. Accuracy

**Stage:** 9 — Scoring | **Priority:** Must know | **Prerequisites:** [Baseline](4_Baseline.md)

## In one sentence
Accuracy is the fraction of evaluated items judged correct under the evaluator's rule — e.g., 90 correct out of 100 = 90%.

## Plain-English explanation
Speed means nothing if answers get worse. The grader checks outputs against expected answers using some judging method (exact match, regex extraction, unit tests for code, schema validation for tool calls, an LLM judge, etc.). Your optimizations must keep accuracy close to the baseline.

## Technical depth
- `Accuracy = N_correct / N_evaluated`.
- Judges differ by task: math (extract final answer), multiple choice (letter match), code (pass@1 via tests), tool calls (function name + argument match), Thai QA (normalized string match or judge).
- **Normalization rules** (whitespace, case, punctuation, Thai normalization) change scores — know the grader's.
- Sources of accuracy change in optimization: quantization, numerics from different kernels/batching, template/tokenizer mismatches, changed sampling, truncation by `max-model-len`/`max_tokens`, broken stop handling.
- Greedy-decoding output diffs vs baseline are a fast early-warning signal, but don't equal accuracy.

## Backend-engineer analogy
Correctness tests in CI — a performance refactor that fails tests doesn't ship.

## Why it matters for GreenMind
Accuracy feeds the accuracy-retention gate/factor, which can multiply or invalidate everything else.

## Common mistakes
- Checking only aggregate accuracy.
- Blaming kernels for drops actually caused by templates or sampling changes.

## Related concepts
[Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md) · [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md) · [Quantization](102_Quantization.md) · [Deterministic Settings](10_Deterministic_Settings.md)

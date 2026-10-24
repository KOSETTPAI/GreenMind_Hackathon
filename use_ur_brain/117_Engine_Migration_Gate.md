# 117. Engine Migration Gate

**Stage:** 8 | **Priority:** Must know before switching engines | **Prerequisites:** [vLLM](113_vLLM.md), [OpenAI-Compatible API](72_OpenAI_Compatible_API.md)

## In one sentence
The engine migration gate is a checklist that an alternative engine must pass before you trust its results or consider submitting it.

## Plain-English explanation
Switching from vLLM to SGLang/TensorRT-LLM/llama.cpp can look like a big win in a quick benchmark — and then fail on tool calls, Thai output, or long context. Before migrating, verify all six:

1. **Model architecture support** — the exact hybrid layers run on proper kernels, not fallbacks.
2. **Identical request semantics** — same chat template, sampling defaults, max lengths, stop handling.
3. **Streaming & tool-call compatibility** — byte-level checks of SSE chunks, `tool_calls`, `finish_reason`, usage.
4. **Quality retention** — per-category accuracy vs BF16 vLLM baseline.
5. **Measurement parity** — same harness, workload, telemetry, window.
6. **Startup/operational stability** — reliable startup within limits, no crashes/leaks under the full schedule, offline operation.

## Technical depth
- Work in a separate branch/directory; keep the best vLLM config frozen and runnable.
- Run the full smoke suite and validation suite, multiple repetitions.
- Compare against your **tuned** vLLM, not the untuned baseline.

## Backend-engineer analogy
A migration readiness review before swapping a production database: compatibility tests, shadow traffic, rollback plan.

## Why it matters for GreenMind
Prevents losing time and submissions to an engine that's fast but non-compliant. Roadmap experiment #8.

## Common mistakes
- Benchmarking speed before verifying correctness.
- Burning the remaining time on migration with no rollback.

## Related concepts
[SGLang](114_SGLang.md) · [TensorRT-LLM](115_TensorRT_LLM.md) · [llama.cpp](116_llama_cpp.md) · [Smoke Testing](88_Smoke_Testing.md) · [Submission Discipline](128_Submission_Discipline.md)

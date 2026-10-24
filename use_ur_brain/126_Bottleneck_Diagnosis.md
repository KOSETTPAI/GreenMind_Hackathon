# 126. Bottleneck Diagnosis

**Stage:** 10 (uses everything) | **Priority:** Must know | **Prerequisites:** [Profiling](92_Profiling.md), [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md)

## In one sentence
Bottleneck diagnosis maps an observed symptom to plausible causes and a first experiment, so you fix the real limit instead of guessing.

## Plain-English explanation
Ask the Phase-B questions first: Is the GPU saturated in prefill and decode? Is the workload dominated by long input, long output, or concurrency? Are TTFT and TPOT both bad or only one? Any preemptions/OOM/queue growth? Is CPU (tokenization/templates/streaming) a bottleneck? Does power rise while useful throughput stays flat? Does behavior differ by language/category?

## Diagnostic table (from the roadmap)
| Symptom | Plausible causes | First experiment |
|---|---|---|
| High TTFT, OK TPOT | long prefill, queueing, tokenizer/template overhead | split TTFT into queue/preprocess/prefill; vary batch token budget |
| Good TTFT, poor TPOT | decode bandwidth/compute limit, low batching, cache pressure, bad kernels | measure decode throughput & active seqs; test batch/cache settings |
| Good average, poor p95 | bursts, long requests starving short ones, preemption, CPU contention | per-request traces; chunked prefill/scheduling |
| High GPU util, poor throughput | inefficient kernels, memory stalls, padding, sync | profile kernels; compare tokens/s vs useful req/s |
| Low GPU util | CPU bottleneck, small batches, request gaps, fallback kernels | check CPU, logs, idle gaps, backend selection |
| OOM / frequent preemption | too many seqs, long contexts, low headroom | reduce concurrency/context; inspect cache allocation |
| Lower precision is slower | unsupported kernel, conversion overhead, poor batching | verify kernel path; check support matrix |
| Faster but lower accuracy | quantization, sampling, template mismatch, altered artifact | compare outputs per category; restore settings one by one |
| Lower watts, higher joules | longer runtime outweighs power savings | compare integrated energy and useful work |
| Energy varies run to run | telemetry sampling, thermal/clock variance, warmup, other GPU work | repeat under controlled conditions, same window |
| Tool calls fail, chat OK | template, parser, stream chunk semantics | exact tool-call tests; inspect raw streamed chunks |
| Thai quality/token cost degrades | tokenization, quantization sensitivity, calibration imbalance | Thai-specific accuracy, tokens, latency |

## Backend-engineer analogy
An incident runbook: symptom → hypotheses → first diagnostic step.

## Common mistakes
- Jumping to quantization or custom kernels before diagnosing.

## Related concepts
[Profiling](92_Profiling.md) · [Controlled Experiments](127_Controlled_Experiments.md) · [Preemption](97_Preemption.md) · [CPU and API Worker Capacity](99_CPU_and_API_Worker_Capacity.md)

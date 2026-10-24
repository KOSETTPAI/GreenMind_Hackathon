# 89. Measurement Harness

**Stage:** 5 | **Priority:** Must know | **Prerequisites:** [Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md), [Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md)

## In one sentence
A measurement harness is the repeatable setup that drives load, records per-request timings and outputs, captures GPU telemetry, and computes all score-relevant metrics the same way the grader does.

## Plain-English explanation
Your harness is your private grader. It should replay the official (or representative) workload with the official arrival schedule, record everything, and output the same metrics: accuracy, TTFT, TPOT, p95, throughput, SLO pass rate, energy, and your best estimate of the score.

## Technical depth
**Components:**
1. **Server launcher** — scripted launch with config file; waits for `/health`.
2. **Warmup** — varied prompt lengths, tool calls.
3. **Load generator** — open-loop schedule (Poisson or the grader's trace); timestamps intended send, actual send, first chunk, each chunk, last chunk.
4. **Telemetry recorder** — `nvidia-smi`/DCGM energy counter + power, clocks, temp; vLLM `/metrics` scrape.
5. **Output store** — raw responses for accuracy evaluation.
6. **Analyzer** — per-request and per-category metrics, percentiles, SLO pass/fail, energy over the official window, J/useful request.
7. **Experiment record** — appends a row to the experiment log.

Starting points: `vllm bench serve` for load + latency stats; your own scripts for grader-specific rules.

## Backend-engineer analogy
A load-testing + observability pipeline (k6 + Prometheus + a report script) built to mirror production SLO calculations.

## Why it matters for GreenMind
You can't tune without fast, trustworthy feedback. The harness must match grader definitions — otherwise you optimize the wrong thing.

## Common mistakes
- Load generator becomes the bottleneck (CPU-bound Python client).
- Computing TPOT/p95 with different conventions than the grader.

## Related concepts
[Experiment Log](90_Experiment_Log.md) · [Coordinated Omission](70_Coordinated_Omission.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Energy per Useful Request](121_Energy_per_Useful_Request.md)

# 66. Throughput

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Batching](55_Batching.md)

## In one sentence
Throughput is work completed per unit time — but "work" can mean requests, output tokens, total tokens, or useful/on-time requests, and you must use the grader's definition.

## Plain-English explanation
| Definition | Example | Caveat |
|---|---|---|
| Requests/s | 100 req / 20 s = 5 req/s | ignores request size |
| Output tokens/s | 50k tok / 20 s = 2,500 tok/s | rewards long outputs |
| Total tokens/s | (in + out) / s | inflated by long prompts |
| Goodput / useful req/s | only SLO-passing, correct requests | usually what matters |

## Technical depth
- `Throughput = completed_work / measurement_duration` — the duration (window) definition matters.
- Under **open-loop** load at rate λ: if the server keeps up, throughput ≈ λ (you can't exceed the offered load!). Throughput only differentiates servers when they're overloaded or when it's measured as goodput.
- Max throughput is found by increasing load until goodput stops rising.
- Model tokens/s ≠ requests/s: speculative decoding or quantization may raise tokens/s without changing req/s if the server wasn't the bottleneck.

## Backend-engineer analogy
QPS vs bytes/s vs successful QPS. Under a fixed-rate load test, a healthy server's QPS just equals the offered rate — latency and error rate become the differentiators.

## Why it matters for GreenMind
The throughput score's definition (and whether SLO failures count) decides whether to maximize raw capacity or SLO-compliant capacity.

## Common mistakes
- Confusing model tokens/s with requests/s.
- Reporting throughput without SLO pass rate.

## Related concepts
[Useful Requests](12_Useful_Requests.md) · [Arrival Rate and Load Phases](68_Arrival_Rate_and_Load_Phases.md) · [Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md) · [SLO](11_SLO.md)

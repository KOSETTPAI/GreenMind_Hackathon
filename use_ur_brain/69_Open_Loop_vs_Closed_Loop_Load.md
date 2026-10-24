# 69. Open-Loop vs Closed-Loop Load

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Arrival Rate and Load Phases](68_Arrival_Rate_and_Load_Phases.md)

## In one sentence
Open-loop load sends requests on a schedule regardless of whether previous ones finished; closed-loop load has N clients that each wait for a response before sending the next.

## Plain-English explanation
- **Closed-loop** (e.g., "64 concurrent users"): if the server slows down, clients send fewer requests — the load automatically eases. Latency looks better than reality.
- **Open-loop** (e.g., "5 requests/s, Poisson"): requests keep coming no matter what. If the server slows, queues build. This matches real traffic and the grader's likely behavior.

## Technical depth
- Closed-loop throughput is self-limiting: `throughput = N / (latency + think_time)`.
- Open-loop exposes overload: when `λ > μ`, latency grows over time.
- Results from the two are **not comparable**.
- Tools: vLLM's `vllm bench serve` (formerly `benchmark_serving.py`) supports `--request-rate` (open-loop, Poisson by default) and `--max-concurrency` (caps in-flight requests, closed-loop-like).
- For agentic workloads, each session is internally closed-loop (dependent steps) while sessions arrive open-loop.

## Backend-engineer analogy
wrk/ab with fixed connections (closed) vs wrk2/k6 constant-arrival-rate executors (open).

## Why it matters for GreenMind
Your harness must mimic the grader's load model. Tuning under closed-loop load can mislead you about TTFT and p95 under open-loop arrivals.

## Common mistakes
- Comparing closed-loop and open-loop results.
- Tuning with a fixed-concurrency benchmark and expecting the same p95 in grading.

## Related concepts
[Coordinated Omission](70_Coordinated_Omission.md) · [Measurement Harness](89_Measurement_Harness.md) · [Throughput](66_Throughput.md) · [Concurrency](58_Concurrency.md)

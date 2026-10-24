# 67. Queueing

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Concurrency](58_Concurrency.md)

## In one sentence
Queueing is the waiting that happens when requests arrive faster (even briefly) than the server can start them — and it's the main source of tail latency.

## Plain-English explanation
Even if average capacity exceeds average demand, random bursts create queues. As utilization approaches 100%, waiting time grows **non-linearly** — at 90% utilization, waits are much worse than at 70%. This is why a server that "handles the load on average" can still miss p95 SLOs.

## Technical depth
- **Little's Law:** `L = λW` (items in system = arrival rate × time in system).
- **Utilization:** `ρ = λ / μ` (arrival rate / service rate). If `ρ ≥ 1` sustained → queue grows without bound.
- Simple M/M/1 intuition: mean wait ∝ `ρ / (1 − ρ)` — at ρ = 0.5 → 1×, at 0.9 → 9×, at 0.95 → 19×.
- LLM serving is more complex: service rate depends on batch size (batching raises μ under load), and requests have very different sizes (head-of-line blocking).
- Queue time shows up inside TTFT. Track waiting-queue length from `/metrics`.

## Backend-engineer analogy
The same queueing theory you know from thread pools and message queues — high utilization → exploding tail latency.

## Why it matters for GreenMind
Peak phases of the arrival schedule are where SLOs are most likely to fail. Improving efficiency (higher μ) lowers ρ and disproportionately reduces queueing delay.

## Common mistakes
- Targeting 100% GPU utilization without considering tail latency.
- Measuring latency without measuring queue time.

## Related concepts
[Arrival Rate and Load Phases](68_Arrival_Rate_and_Load_Phases.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Backpressure](59_Backpressure.md) · [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)

# 98. Scheduling Policy

**Stage:** 6 | **Priority:** Should know | **Prerequisites:** [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)

## In one sentence
The scheduling policy decides the order in which waiting requests are admitted and which running requests are preempted first — e.g., first-come-first-served vs priority-based.

## Plain-English explanation
With FCFS, a burst of huge RAG prompts at the head of the queue delays every short chat request behind them (head-of-line blocking). Other policies can favor short or high-priority requests to protect tail latency — at the risk of starving long requests.

## Technical depth
- vLLM: `--scheduling-policy fcfs` (default) or `priority` (requests carry a `priority` field; lower value = higher priority). Priority requires the client to send priorities — the grader likely won't, so it may have limited use unless you add a proxy that assigns priority by request type (check rules).
- Related: decode-first ordering within a step, prefill chunk sizing, preemption victim selection (typically the most recently admitted).
- Research ideas (shortest-job-first using predicted output length, SLO-aware scheduling) are high-effort; validate against the actual scoring before attempting.
- Fairness vs efficiency: optimizing p95 for short requests can push long requests past their limits.

## Backend-engineer analogy
Queue disciplines: FIFO vs priority queues vs shortest-job-first in job schedulers.

## Why it matters for GreenMind
If p95 TTFT failures come from head-of-line blocking by long prompts, scheduling (plus chunked prefill) is the relevant lever.

## Common mistakes
- Assuming a priority policy helps without sending priorities.
- Starving long requests that also need to meet SLOs.

## Related concepts
[Chunked Prefill](95_Chunked_Prefill.md) · [Queueing](67_Queueing.md) · [Preemption](97_Preemption.md) · [Percentiles](65_Percentiles_p50_p95_p99.md)

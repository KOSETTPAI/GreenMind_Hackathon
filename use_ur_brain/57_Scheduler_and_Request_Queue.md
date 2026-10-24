# 57. Scheduler and Request Queue

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Continuous Batching](56_Continuous_Batching.md)

## In one sentence
The scheduler decides, every engine step, which queued and running requests get GPU work, subject to memory and token budgets; the request queue holds requests waiting to be admitted.

## Plain-English explanation
Requests arrive and wait in a queue ("waiting"). Each step, the scheduler admits some into the "running" set if there's enough cache memory and token budget. Running requests generate tokens until done. If memory runs out, the scheduler may preempt some running requests back to waiting.

Time spent waiting in the queue counts toward TTFT, often invisibly.

## Technical depth
- vLLM states: **waiting**, **running**, (preempted → back to waiting).
- Default policy is FCFS; vLLM also supports `--scheduling-policy priority` with per-request priority.
- Per-step budget: `max_num_batched_tokens` (decode tokens + prefill chunk tokens) and `max_num_seqs`.
- Decode tokens are usually prioritized over new prefills to protect TPOT; chunked prefill fills the leftover budget.
- Observable via `/metrics`: `num_requests_running`, `num_requests_waiting`, cache usage, preemptions.
- **Queue delay** = admit time − arrival time; split TTFT into queue + prefill to diagnose.

## Backend-engineer analogy
A job scheduler with admission control: a work queue, a bounded worker set, resource-aware admission, and eviction under pressure.

## Why it matters for GreenMind
High TTFT with low GPU utilization suggests the scheduler is limited by memory or config; high queue lengths during peaks point to capacity limits or bad batching settings.

## Common mistakes
- Measuring only end-to-end latency and missing queue time.
- Not watching the waiting queue during load peaks.

## Related concepts
[Queueing](67_Queueing.md) · [Scheduling Policy](98_Scheduling_Policy.md) · [Backpressure](59_Backpressure.md) · [Preemption](97_Preemption.md) · [TTFT](62_TTFT.md)

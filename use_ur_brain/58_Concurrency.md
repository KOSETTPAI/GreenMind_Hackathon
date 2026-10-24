# 58. Concurrency

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)

## In one sentence
Concurrency is the number of requests in flight at the same time — both those actively generating on the GPU and those waiting in queues.

## Plain-English explanation
More concurrent requests usually means bigger batches and higher throughput — up to a point. Beyond the GPU's memory or compute capacity, extra concurrency just turns into queueing delay and preemption, which hurts TTFT and p95.

## Technical depth
- **Little's Law:** `L = λ × W` — average requests in system = arrival rate × average time in system. Example: 5 req/s × 8 s average latency = 40 concurrent requests on average.
- **Server-side limit:** `max_num_seqs` caps running sequences; others wait.
- **Memory limit:** each running sequence needs KV cache blocks (attention layers) and a recurrent state slot (Mamba/DeltaNet layers). vLLM logs the maximum concurrency it can support for `max-model-len` at startup.
- **Client-side concurrency** (closed-loop tests) differs from **arrival rate** (open-loop tests) — see [Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md).
- Plot throughput and p95 latency vs concurrency to find the "knee."

## Backend-engineer analogy
Connection pool / worker count tuning: more workers increase throughput until a shared resource saturates, then latency explodes.

## Why it matters for GreenMind
The grader's arrival schedule decides concurrency. You control how much of it the GPU runs at once (`max_num_seqs`, memory), which trades throughput against tail latency.

## Common mistakes
- Equating "concurrency 64 in my test" with the grader's open-loop arrival rate.
- Pushing concurrency past the memory limit and triggering preemption storms.

## Related concepts
[Queueing](67_Queueing.md) · [Max Active Sequences](94_Max_Active_Sequences.md) · [Backpressure](59_Backpressure.md) · [Arrival Rate and Load Phases](68_Arrival_Rate_and_Load_Phases.md)

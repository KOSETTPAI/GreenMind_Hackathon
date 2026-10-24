# 56. Continuous Batching

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Batching](55_Batching.md)

## In one sentence
Continuous batching admits new requests and removes finished ones between every generation step, keeping the GPU busy with a constantly changing set of sequences.

## Plain-English explanation
Static batching is like a bus that only leaves when full and only returns when the last passenger reaches their stop. Continuous batching is like a tram: passengers board and leave at every stop. A short request finishes and frees its slot immediately; a new request can join on the next step.

## Technical depth
- Each engine step: the scheduler decides which running sequences continue, which waiting requests get admitted (and how many of their prompt tokens to prefill this step), and whether anyone must be preempted.
- Mixed steps contain prefill chunks + decode tokens together (with chunked prefill).
- Requires per-sequence memory management — vLLM's **PagedAttention** allocates KV cache in fixed-size blocks to avoid fragmentation; hybrid models also need per-sequence recurrent state slots.
- Constraints per step: `max_num_seqs` (running sequences) and `max_num_batched_tokens` (total tokens processed in the step).
- Benefit: high utilization under mixed lengths. Cost: scheduler complexity, CPU overhead per step, memory-pressure-driven preemption.

## Backend-engineer analogy
A work-conserving scheduler with a dynamic worker pool — like an event loop that services whatever connections are ready each tick, rather than processing fixed groups.

## Why it matters for GreenMind
This is the core of vLLM. Most low-risk tuning (batch token budget, max sequences, chunked prefill, scheduling policy) is tuning this scheduler.

## Common mistakes
- Thinking batch size is a single fixed number — it varies every step.
- Ignoring preemption counters when increasing concurrency.

## Related concepts
[Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md) · [Chunked Prefill](95_Chunked_Prefill.md) · [Preemption](97_Preemption.md) · [vLLM](113_vLLM.md)

# 97. Preemption

**Stage:** 6 | **Priority:** Must know | **Prerequisites:** [KV Cache](77_KV_Cache.md), [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)

## In one sentence
Preemption is when the scheduler evicts a running request's cache/state to free memory for others, later resuming it by recomputing (or swapping back) its state.

## Plain-English explanation
If too many sequences are running and their caches grow until memory is full, the engine must kick someone out. The evicted request goes back to the waiting queue and must later redo its prefill (prompt + already-generated tokens). That's wasted compute, wasted energy, and a big latency spike for that request.

## Technical depth
- vLLM V1 uses **recompute** preemption: free blocks/state, re-prefill on resume. (Older versions also supported swapping to CPU.)
- Triggers: KV block pool exhausted as sequences grow; too many concurrent long-context requests; `gpu_memory_utilization` too low; `max_num_seqs` too high for the memory.
- Logged as a warning; counted in `/metrics` (`num_preemptions` total).
- vLLM docs: preemption/recomputation hurts end-to-end latency; remedies are more cache memory (`gpu_memory_utilization`), fewer concurrent sequences (`max_num_seqs`), smaller `max_num_batched_tokens`, or more GPUs.
- For hybrid models, recurrent state must also be rebuilt by recompute.

## Backend-engineer analogy
Memory pressure causing cache eviction or process OOM-kills and restarts — work gets redone and latency spikes.

## Why it matters for GreenMind
Preemption silently wastes joules and creates tail-latency outliers. A config that looks fast on average but preempts often may fail p95 and energy goals.

## Common mistakes
- Not monitoring the preemption counter during benchmarks.
- Raising concurrency until throughput peaks without checking preemptions.

## Related concepts
[Max Active Sequences](94_Max_Active_Sequences.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md) · [ITL](64_ITL.md) · [Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md)

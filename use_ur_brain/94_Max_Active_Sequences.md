# 94. Max Active Sequences (`max_num_seqs`)

**Stage:** 6 | **Priority:** Must know | **Prerequisites:** [Concurrency](58_Concurrency.md), [KV Cache](77_KV_Cache.md)

## In one sentence
`max_num_seqs` caps how many sequences can be running (generating) at once — i.e., the maximum decode batch size.

## Plain-English explanation
More running sequences → bigger decode batches → more throughput and better energy per token, until:
- memory runs out (KV blocks / recurrent state slots) → preemption,
- per-step time grows enough that TPOT breaks the SLO,
- or the GPU becomes compute-bound and throughput plateaus.
Fewer running sequences → lower TPOT but more queueing (higher TTFT) under load.

## Technical depth
- vLLM flag: `--max-num-seqs N` (default commonly 256 in recent versions for GPU; check yours).
- For hybrid models, each running sequence needs a recurrent state slot — the state pool may cap effective concurrency below `max_num_seqs`. Check startup logs for the computed maximum concurrency.
- CUDA graphs are captured for a set of batch sizes up to a limit; batches above it may run eagerly (slower) — check the capture sizes config in your version.
- Watch: `num_requests_running`, `num_requests_waiting`, cache usage %, preemption counter.
- Sweep: e.g., 32, 64, 128, 256 under the real arrival schedule.

## Backend-engineer analogy
Worker-pool size or max DB connections: more parallelism until a shared resource saturates and latency climbs.

## Why it matters for GreenMind
Roadmap experiment #3: balances throughput/energy (bigger batches) against TPOT, p95, and preemption risk.

## Common mistakes
- Setting it very high and causing OOM or preemption storms.
- Assuming the configured value is the actual running batch (memory may cap it).

## Related concepts
[Batch Token Budget](93_Batch_Token_Budget.md) · [Preemption](97_Preemption.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md) · [Batching](55_Batching.md)

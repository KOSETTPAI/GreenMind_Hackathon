# 64. ITL (Inter-Token Latency)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [TPOT](63_TPOT.md)

## In one sentence
ITL is the time between two successive generated tokens (or chunks) for one request — TPOT is roughly its average, while ITL exposes spikes.

## Plain-English explanation
TPOT tells you the average pace; ITL tells you about stutters. A request with average TPOT 40 ms might have a 600 ms gap in the middle because a huge prefill ran in that step, or because it was preempted.

## Technical depth
- `ITL_i = t_token_i − t_token_{i−1}`; distribution per request and across requests.
- Measured at the client from streamed chunks; if multiple tokens arrive in one chunk (speculative decoding, buffered detokenization), ITL becomes bursty — grader convention matters.
- **Spike causes:** prefill interference, preemption + recompute, Python GC / CPU contention, CUDA graph miss (batch size not captured), stop-string buffering.
- Look at p95/p99 ITL to find stutters hidden by average TPOT.

## Backend-engineer analogy
Jitter in a streaming connection — average bitrate looks fine, but stalls ruin the experience.

## Why it matters for GreenMind
If the grader uses max or tail ITL rather than average TPOT, prefill interference becomes much more important. Even if not, ITL spikes reveal scheduler problems.

## Common mistakes
- Only looking at average TPOT.
- Comparing ITL between engines that chunk streams differently.

## Related concepts
[TPOT](63_TPOT.md) · [Chunked Prefill](95_Chunked_Prefill.md) · [Preemption](97_Preemption.md) · [Percentiles](65_Percentiles_p50_p95_p99.md)

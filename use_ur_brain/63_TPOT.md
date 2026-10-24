# 63. TPOT (Time Per Output Token)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Decode](54_Decode.md), [TTFT](62_TTFT.md)

## In one sentence
TPOT is the average time per generated token after the first one — a measure of streaming speed during decode.

## Plain-English explanation
Once text starts flowing, how fast does it keep coming? A TPOT of 50 ms ≈ 20 tokens/s per user. Faster than human reading speed is usually "good enough" for UX, but the grader may have a strict limit.

## Technical depth
- Common convention: `TPOT = (E2E − TTFT) / (n_output − 1)`.
- Undefined/special-cased for one-token outputs — check the grader's formula.
- **Drivers:** batch size (bigger batch → slower steps), context length in attention layers, interference from prefills in the same step, preemption, CPU overhead, kernel efficiency.
- **Levers:** smaller batch token budget (less prefill interference), CUDA graphs, quantization (faster weight reads), speculative decoding (multiple tokens per target step), limiting `max_num_seqs`.
- **Throughput–TPOT trade-off:** aggregate tokens/s ≈ `batch_size / TPOT`. Raising batch improves throughput but raises TPOT — the SLO caps how far you can go.

## Backend-engineer analogy
Streaming throughput per client (bytes/s on a long download) as opposed to time to first byte.

## Exercise
Measure TPOT for a fixed 500-token output at concurrency 1, 8, 32, 64. Plot TPOT and aggregate tokens/s.

## Why it matters for GreenMind
Likely an SLO condition. Decode-heavy categories (reasoning, coding, chat) are most at risk under high concurrency.

## Common mistakes
- Confusing TPOT (per request) with aggregate tokens/sec.
- Ignoring how a long prefill in the same step spikes TPOT.

## Related concepts
[ITL](64_ITL.md) · [TTFT](62_TTFT.md) · [Batch Token Budget](93_Batch_Token_Budget.md) · [Speculative Decoding](111_Speculative_Decoding.md) · [SLO](11_SLO.md)

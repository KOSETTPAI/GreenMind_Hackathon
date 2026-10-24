# 65. Percentiles (p50, p95, p99)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [End-to-End Latency](61_Latency_End_to_End.md)

## In one sentence
The pXX percentile is the value at or below which XX% of observations fall — p95 means 95% of requests were at least this fast; it measures the tail, not the average.

## Plain-English explanation
Averages hide pain. If 95 requests take 1 s and 5 take 30 s, the average is 2.45 s — looks fine — but p99 is 30 s. Tail latency comes from queueing bursts, long requests blocking short ones, preemption, and interference.

- **p50 (median):** typical request.
- **p95:** the "bad but common" experience.
- **p99:** the worst 1%.

## Technical depth
- Nearest-rank method: sort `n` values, p95 = value at rank `ceil(0.95 × n)`.
- Interpolation methods (e.g., numpy default "linear") give slightly different values — use the grader's method.
- With few samples (e.g., 40), p95 is driven by 1–2 requests → very noisy. Repeat runs.
- Percentiles don't average: the mean of per-run p95s isn't the p95 of the combined data.
- Percentiles may be **normalized** (e.g., divided by a reference/limit) in the score — check the briefing.

```python
import numpy as np
p95 = np.percentile(latencies, 95, method="inverted_cdf")  # nearest-rank-like
```

## Backend-engineer analogy
Exactly the same as SRE tail-latency SLOs.

## Why it matters for GreenMind
The briefing mentions p95 with normalization. Throughput-boosting changes often worsen p95. Optimize for the tail, not the mean.

## Common mistakes
- Optimizing average latency while ignoring p95.
- Averaging percentiles across runs.

## Related concepts
[SLO](11_SLO.md) · [Queueing](67_Queueing.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md) · [TTFT](62_TTFT.md) · [TPOT](63_TPOT.md)

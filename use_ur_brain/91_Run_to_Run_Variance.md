# 91. Run-to-Run Variance (Noise Floor)

**Stage:** 5 | **Priority:** Must know | **Prerequisites:** [Baseline](4_Baseline.md)

## In one sentence
Run-to-run variance is how much results change between identical runs; any "improvement" smaller than this noise floor is not a real improvement.

## Plain-English explanation
Run the same config 3–5 times and you'll get slightly different TTFT, p95, and energy each time — due to thermals, clock boosting, random arrival timing, batching differences, and OS noise. You need to know this spread before claiming a 3% gain.

## Technical depth
- Sources: GPU temperature/clock variance, Poisson arrival randomness (use fixed seeds/traces), non-deterministic batching → slightly different outputs → different output lengths, background processes, telemetry sampling.
- Report **median and spread** (min/max or IQR or std) over ≥3 repetitions.
- Tail metrics (p95/p99) are noisier than medians, especially with few requests.
- Energy: start runs from a similar thermal state (cool-down or consistent warm-up period).
- A change is credible if its effect exceeds the spread consistently across repetitions.

## Backend-engineer analogy
Benchmark noise in microbenchmarks — why tools like `hyperfine` or JMH run many iterations and report confidence intervals.

## Why it matters for GreenMind
Prevents selecting a lucky run, and tells you how much safety margin to keep from hard thresholds.

## Common mistakes
- Comparing single runs.
- Picking the best of N runs as "the result."
- Different thermal state between runs.

## Related concepts
[Reproducibility](87_Reproducibility.md) · [Controlled Experiments](127_Controlled_Experiments.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Hard Gates](2_Hard_Gates_and_Eligibility.md)

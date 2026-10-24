# final-run1: cap 64

**Final #3 on the grader** (run4 was Final #1, run6 was Final #2). Final baseline: η 0.00163, macro-accuracy 87.8%. Target `S` = 99.9. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM lines added to run6 | --max-num-seqs 64 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

**Why:** Fixes the run6 Final's TPOT failure (111 running, p95 TPOT 82 ms). From the run6 Validation (35 running, 18 ms), p95 TPOT crosses 50 ms near 70 running. A cap of 64 keeps the decode batch under that.

**Watch for:** TTFT misses at the peak: a cap alone finishes fewer requests per second than arrive at 4 req/s, so some queue. final-run2 adds MTP to fix that.

Runs on its own. No guard, no replay, no earlier run needed.

```bash
./final-run1/flag-check.sh && REPLACE=1 ./final-run1/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before each Submit
```

Optionally submit one Validation on this server first, to check it works. Then submit the Final on the **same container**, without relaunching. After each one:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation   # works-check
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final        # the graded run
```

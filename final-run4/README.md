# final-run4: cap 96 + MTP k=1, 250 W

**Final #6 on the grader** (run4 was Final #1, run6 was Final #2). Final baseline: η 0.00163, macro-accuracy 87.8%. Target `S` = 99.9. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM lines added to run6 | --max-num-seqs 96, MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

**Why:** The energy step. 99.9 needs about 205 J per SLO-met request on the Final; run6 used about 221 J per request. A constant 250 W limit trims joules once TPOT has headroom.

**Watch for:** p95 TPOT. A lower power limit slows every step. If the works-check Validation already shows p95 TPOT above about 35 ms, the Final will not have room.

Runs on its own. No guard, no replay, no earlier run needed.

```bash
./final-run4/flag-check.sh && REPLACE=1 ./final-run4/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before each Submit
```

Optionally submit one Validation on this server first, to check it works. Then submit the Final on the **same container**, without relaunching. After each one:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation   # works-check
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final        # the graded run
```

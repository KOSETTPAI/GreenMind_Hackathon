# final-run5: cap 96 + MTP k=1, 225 W

**Final #7 on the grader** (run4 was Final #1, run6 was Final #2). Final baseline: η 0.00163, macro-accuracy 87.8%. Target `S` = 99.9. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM lines added to run6 | --max-num-seqs 96, MTP k=1 |
| Power limit | 225 W, set by `start.sh` before the container starts |

**Why:** A further energy step at 225 W.

**Watch for:** The same TPOT risk as final-run4, larger.

Runs on its own. No guard, no replay, no earlier run needed.

```bash
./final-run5/flag-check.sh && REPLACE=1 ./final-run5/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before each Submit
```

Optionally submit one Validation on this server first, to check it works. Then submit the Final on the **same container**, without relaunching. After each one:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation   # works-check
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final        # the graded run
```

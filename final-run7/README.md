# final-run7: cap 96 + MTP k=1, 250 W

**Final #9 on the grader** (run4 was Final #1, run6 was Final #2). Final baseline: η 0.00163, macro-accuracy 87.8%. Target `S` = 99.9. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM lines added to run6 | --max-num-seqs 96, MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

**Why:** Last Final. Default is the final-run4 server. If an earlier Final scored higher, copy that folder's `profile.args` and its `GREENMIND_POWER_W` line here and submit that instead.

**Watch for:** None new. This is a repeat of the best server.

Runs on its own. No guard, no replay, no earlier run needed.

```bash
./final-run7/flag-check.sh && REPLACE=1 ./final-run7/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before each Submit
```

Optionally submit one Validation on this server first, to check it works. Then submit the Final on the **same container**, without relaunching. After each one:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation   # works-check
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final        # the graded run
```

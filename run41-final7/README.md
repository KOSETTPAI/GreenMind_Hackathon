# run41-final7: cap 96 + MTP k=1, 250 W

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

Last Final. Default is the cap 96 + MTP k=1 + 250 W server. If an earlier Final scored higher, copy that folder's `profile.args` and its `GREENMIND_POWER_W` line here.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run41-final7/flag-check.sh && REPLACE=1 ./run41-final7/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

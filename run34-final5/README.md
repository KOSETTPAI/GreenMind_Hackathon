# run34-final5: cap 96 + MTP k=1, 225 W

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=1 |
| Power limit | 225 W, set by `start.sh` before the container starts |

A further energy step, 225 W.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run34-final5/flag-check.sh && REPLACE=1 ./run34-final5/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

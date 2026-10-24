# run37-final6: cap 96 + MTP k=2, 250 W

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=2 |
| Power limit | 250 W, set by `start.sh` before the container starts |

MTP k=2 at 250 W. Two draft tokens per step means fewer steps per answer if acceptance holds.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run37-final6/flag-check.sh && REPLACE=1 ./run37-final6/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

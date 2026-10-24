# run36-val15: cap 96 + MTP k=1, 250 W

**Validation.** Validation, baseline η 0.00154 and 87.2%. A works-check; it does not count. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

Works-check for final7.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run36-val15/flag-check.sh && REPLACE=1 ./run36-val15/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation
```

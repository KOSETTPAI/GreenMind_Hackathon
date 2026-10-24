# run17-val1: cap 64

**Validation.** Validation, baseline η 0.00154 and 87.2%. A works-check; it does not count. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 64 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

Works-check for final1. The cap does not bind here (run6 Validation peaked at 35 running).

Runs on its own. It does not need any earlier run or a replay.

```bash
./run17-val1/flag-check.sh && REPLACE=1 ./run17-val1/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation
```

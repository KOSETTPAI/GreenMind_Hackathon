# run20-final1: cap 64

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 64 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

First fix for the run6 Final (111 running, p95 TPOT 82 ms). The cap keeps the decode batch under the ~70-running point where p95 TPOT crosses 50 ms.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run20-final1/flag-check.sh && REPLACE=1 ./run20-final1/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

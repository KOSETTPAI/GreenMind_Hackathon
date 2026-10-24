# run23-final2: cap 64 + MTP k=1

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 64 + MTP k=1 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

Adds MTP k=1 to final1. MTP accepted 91.5% of drafts on run4 full, about 1.9 tokens per step. That raises throughput, which shrinks the peak queue that a cap alone leaves, and lowers TPOT and joules per token.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run23-final2/flag-check.sh && REPLACE=1 ./run23-final2/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

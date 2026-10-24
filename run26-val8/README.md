# run26-val8: cap 128 + MTP k=1

**Validation.** Validation, baseline η 0.00154 and 87.2%. A works-check; it does not count. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 128 + MTP k=1 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

Variant: a looser cap of 128 with MTP, in case 96 still queues requests past TTFT.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run26-val8/flag-check.sh && REPLACE=1 ./run26-val8/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation
```

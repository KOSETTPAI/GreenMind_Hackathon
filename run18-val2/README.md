# run18-val2: cap 64 + MTP k=1

**Validation.** Validation, baseline η 0.00154 and 87.2%. A works-check; it does not count. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 64 + MTP k=1 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

Works-check for final2. Read the prefix hit rate from `summarize.py`: run6's Validation hit 87%. If MTP drops it below about 50%, or accuracy falls under 86%, run final2 with the run20-final1 profile instead.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run18-val2/flag-check.sh && REPLACE=1 ./run18-val2/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation
```

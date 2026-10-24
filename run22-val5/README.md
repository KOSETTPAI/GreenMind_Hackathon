# run22-val5: cap 64 + MTP k=1, 250 W

**Validation.** Validation, baseline η 0.00154 and 87.2%. A works-check; it does not count. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 64 + MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

Variant: power cap without loosening the cap. Compare J/request and p95 TPOT with val4.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run22-val5/flag-check.sh && REPLACE=1 ./run22-val5/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation
```

# run27-final3: cap 96 + MTP k=1

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=1 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

Loosens the cap from 64 to 96 now that MTP finishes requests faster. Fewer requests queue past their TTFT limit.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run27-final3/flag-check.sh && REPLACE=1 ./run27-final3/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

# run30-final4: cap 96 + MTP k=1, 250 W

**Final.** Final, baseline η 0.00163 and 87.8%. This is the graded track. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM change from run6 | cap 96 + MTP k=1 |
| Power limit | 250 W, set by `start.sh` before the container starts |

The energy step. 99.9 needs about 205 J per SLO-met request on the Final, and run6 used about 221. A 250 W limit trims joules once TPOT has headroom.

Runs on its own. It does not need any earlier run or a replay.

```bash
./run30-final4/flag-check.sh && REPLACE=1 ./run30-final4/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, start just before Submit
```

After the grader finishes:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

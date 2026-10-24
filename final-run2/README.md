# final-run2: cap 64 + MTP k=1

**Final #4 on the grader** (run4 was Final #1, run6 was Final #2). Final baseline: η 0.00163, macro-accuracy 87.8%. Target `S` = 99.9. Schedule: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

| | |
|---|---|
| vLLM lines added to run6 | --max-num-seqs 64, MTP k=1 |
| Power limit | card default (400 W), set by `start.sh` before the container starts |

**Why:** Adds MTP k=1 to final-run1. On run4 full, MTP accepted 91.5% of drafts, about 1.9 tokens per step. Requests finish faster at the same batch, so the peak queue shrinks, TPOT falls and joules per token fall.

**Watch for:** Prefix-cache hits. run4 combined MTP with explicit caching flags and hit about 1%. This profile leaves caching at the image default. If the works-check Validation shows hits far below run6's 87%, or accuracy under 86%, submit final-run1's profile instead.

Runs on its own. No guard, no replay, no earlier run needed.

```bash
./final-run2/flag-check.sh && REPLACE=1 ./final-run2/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before each Submit
```

Optionally submit one Validation on this server first, to check it works. Then submit the Final on the **same container**, without relaunching. After each one:

```bash
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation   # works-check
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final        # the graded run
```

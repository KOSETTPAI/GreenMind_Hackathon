# final-run5: the better of final-run3 and final-run4

**Final #7 on the grader.** Final baseline: η 0.00163, macro-accuracy 87.8%. Plan and evidence: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

Default is final-run3's server. If final-run4 scored higher, copy its profile first:

```bash
cp final-run4/profile.args final-run5/profile.args
```

**Power:** only if this server's last Final had p95 TPOT at or below 40 ms, set `GREENMIND_POWER_W="250"` in `start.sh` to cut joules. If TPOT was above 40 ms, leave it empty (400 W).

Do **not** run a Validation on this container before the Final unless you have confirmed with the organizers that it is allowed. The Validation's 100 prompts are the first 100 of the Final, so a Validation leaves them in the prefix cache.

```bash
./final-run5/flag-check.sh && REPLACE=1 ./final-run5/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

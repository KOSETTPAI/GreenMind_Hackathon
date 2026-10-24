# final-run7: repeat the best Final

**Final #9 on the grader.** Final baseline: η 0.00163, macro-accuracy 87.8%. Plan and evidence: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

Last Final. Copy the best Final's `profile.args` and its `GREENMIND_POWER_W` line here, then launch. Default is final-run3's server at 400 W. Must finish before 25 Oct 2026 11:00 Bangkok.

Do **not** run a Validation on this container before the Final unless you have confirmed with the organizers that it is allowed. The Validation's 100 prompts are the first 100 of the Final, so a Validation leaves them in the prefix cache.

```bash
./final-run7/flag-check.sh && REPLACE=1 ./final-run7/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

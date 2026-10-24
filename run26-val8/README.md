# run26-val8: power cap, no relaunch

**Cycle 2.** This folder does not start vLLM and has no `profile.args`. Apply it to the server that already won, while that server is up and idle.

**Launch only if** that server's p95 TPOT is under 50 ms with room and SLO-met is high. At run6's 127/300, a lower wattage would push TPOT further over 50 ms and the score would fall. The 99.9 arithmetic in [CYCLE_PLAN.md](../CYCLE_PLAN.md) says why this is the last lever: full SLO-met at run6's energy lands near `S ≈ 96`, and 99.9 needs about 205 J per SLO-met request.

`power.sh` refuses without `CONFIRM_SLO=at-least-90`. Leave the cap untouched from before Submit until the grader finishes. Restore between runs, never during one.

1. `./run26-val8/power.sh show` (400 W on this A100 is the reference)
2. `CONFIRM_SLO=at-least-90 ./run26-val8/power.sh set 250`, then one Validation
3. 200 W only if 250 W held SLO-met and improved efficiency
4. 175 W only if 200 W did the same

```bash
./run26-val8/power.sh show
CONFIRM_SLO=at-least-90 ./run26-val8/power.sh set 250
./run26-val8/power.sh restore
```

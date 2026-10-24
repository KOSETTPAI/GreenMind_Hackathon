# run15 — V9, constant power cap

**Late, and only on the kept server.** This run does not launch a container and has no `profile.args`. Changing the power limit and the vLLM arguments in one step would mix two causes.

Apply it to whatever configuration just won, with that server already up and idle.

**Order, one Validation each.** Leave the cap untouched from before Submit until the grader finishes. Restoring or moving it during a window is the dynamic case the rules forbid.

1. The card default (400 W on this A100) is the reference. `./run15/power.sh show`
2. `CONFIRM_SLO=at-least-90 ./run15/power.sh set 250`
3. 200 W only if 250 W held the SLO-met rate and improved efficiency.
4. 175 W only if 200 W did the same and there is time to recover.

**Run only if** the kept configuration is already around 90/100 SLO-met on Validation and p95 TPOT is not already over 50 ms. A cap that pushes TPOT over 50 ms shrinks the SLO-met count, which is the numerator of efficiency. `power.sh` refuses without `CONFIRM_SLO=at-least-90`.

```bash
./run15/power.sh show
CONFIRM_SLO=at-least-90 ./run15/power.sh set 250
./run15/power.sh restore          # between runs, never during one
```

Keep the cap with the best `S`, not the lowest watt reading. Record the limit in [log.md](log.md).

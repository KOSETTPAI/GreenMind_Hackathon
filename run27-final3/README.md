# run27-final3: cycle 2's second Final

Default profile is cap 64, so a power-cap Final can be relaunched as the same server. If val6 or val7 won, copy that `profile.args` here first. If the only change was the power cap, set the cap with [run26-val8](../run26-val8/README.md) before warmup and do not move it during the run.

`start.sh` refuses unless `CONFIRM_FINAL3=1`. Final baseline 0.00163 and 87.8%.

```bash
CONFIRM_FINAL3=1 REPLACE=1 ./run27-final3/start.sh
python3 lib/warmup.py
```

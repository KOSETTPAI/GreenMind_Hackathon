# run30-final4: cycle 3's last Final

Default profile is cap 64. Copy the cycle-3 winner's `profile.args` here first.

`start.sh` refuses unless `CONFIRM_FINAL4=1`. Final baseline 0.00163 and 87.8%.

Cycle 4 does not get a new folder. Relaunch whichever folder won, change nothing, and repeat it.

```bash
CONFIRM_FINAL4=1 REPLACE=1 ./run30-final4/start.sh
python3 lib/warmup.py
```

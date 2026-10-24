# run23-final2: cycle 2's first Final

Default profile is cap 64. If val4 or val5 won the replay, copy that `profile.args` here first.

`start.sh` refuses unless `CONFIRM_FINAL2=1`. Final baseline 0.00163 and 87.8%.

```bash
CONFIRM_FINAL2=1 REPLACE=1 ./run23-final2/start.sh
python3 lib/warmup.py
```

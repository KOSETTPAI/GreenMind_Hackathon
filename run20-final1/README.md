# run20-final1: cycle 1's Final

**Cycle 1, step 7.** Default profile is val1, `--max-num-seqs 64`.

Before launching, replay val1, val2, and val3 with the same seed and `--track final`. If val2 or val3 ranks higher, copy that folder's `profile.args` over this one. One change from run6 either way.

`start.sh` refuses unless `CONFIRM_FINAL1=1`.

```bash
CONFIRM_FINAL1=1 ./run20-final1/flag-check.sh
CONFIRM_FINAL1=1 REPLACE=1 ./run20-final1/start.sh
python3 lib/warmup.py
```

This is a Final. Baseline 0.00163 and 87.8%. Record the History row in [log.md](log.md) before cycle 2.

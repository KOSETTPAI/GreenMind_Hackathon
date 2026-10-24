# run21-val4: cap 24

**Cycle 2.** Parent is the final1 winner. Refuses to start without `CONFIRM_CYCLE2=1`.

**Single change:** `--max-num-seqs 24`.

**Launch only if** final1 still has p95 TPOT above 50 ms. If final1 already met TPOT, skip this folder.

```bash
CONFIRM_CYCLE2=1 REPLACE=1 ./run21-val4/start.sh
python3 lib/warmup.py
```

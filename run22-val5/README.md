# run22-val5: cap 96

**Cycle 2.** Parent is the final1 winner. Refuses to start without `CONFIRM_CYCLE2=1`.

**Single change:** `--max-num-seqs 96`.

**Launch only if** final1 met TPOT but SLO-met fell because requests queued past their TTFT limit. If TTFT was fine, skip this folder.

```bash
CONFIRM_CYCLE2=1 REPLACE=1 ./run22-val5/start.sh
python3 lib/warmup.py
```

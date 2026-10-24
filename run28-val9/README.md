# run28-val9: scheduler budget 16384

**Cycle 3.** Refuses to start without `CONFIRM_CYCLE3=1`.

**Single change:** `--max-num-batched-tokens 16384`, cap stays 64.

**Launch only if** val6's 8192 budget improved TTFT and p95 TPOT still had room. Otherwise skip it.

```bash
CONFIRM_CYCLE3=1 REPLACE=1 ./run28-val9/start.sh
python3 lib/warmup.py
```

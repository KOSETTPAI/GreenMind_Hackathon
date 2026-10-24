# run24-val6: cap kept, scheduler budget 8192

**Cycle 2, after final2.** Refuses to start without `CONFIRM_CYCLE2=1`.

**Single change:** `--max-num-batched-tokens 8192`. The cap line stays 64 unless you edit it to match the winner.

**Launch only if** p95 TPOT is under 50 ms and the remaining misses are TTFT. A larger budget lets a long prompt finish sooner, which is also how a long prompt can stall everyone else, so drop it if the replay's p95 TPOT goes back over 50 ms.

```bash
CONFIRM_CYCLE2=1 REPLACE=1 ./run24-val6/start.sh
python3 lib/warmup.py
```

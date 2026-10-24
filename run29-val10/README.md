# run29-val10: MTP k=2

**Cycle 3.** Parent is [run25-val7](../run25-val7/README.md). Refuses to start without `CONFIRM_CYCLE3=1`.

**Single change:** `num_speculative_tokens` 2, was 1.

**Launch only if** MTP k=1 raised the Final score and tool calls stayed clean. Check the prefix hit rate again. Drop it if hits collapse.

```bash
CONFIRM_CYCLE3=1 REPLACE=1 ./run29-val10/start.sh
python3 lib/warmup.py
```

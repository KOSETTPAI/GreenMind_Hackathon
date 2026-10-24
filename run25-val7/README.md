# run25-val7: cap kept, MTP k=1

**Cycle 2, after final2.** Refuses to start without `CONFIRM_CYCLE2=1`.

**Single change:** `--speculative-config {"method":"mtp","num_speculative_tokens":1}`.

**Launch only if** SLO-met is already high and joules are the remaining gap toward 99.9. On run4 full, MTP accepted 91.5% of drafts but, combined with explicit prefix caching, prefix hits fell to about 1%. This profile leaves caching at the image default. Read the prefix hit rate from `/metrics` after warmup. If it collapses toward run4's 1%, stop and do not submit.

```bash
CONFIRM_CYCLE2=1 REPLACE=1 ./run25-val7/start.sh
python3 lib/warmup.py
```

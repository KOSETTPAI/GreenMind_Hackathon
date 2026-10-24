# run18-val2: cap 32

**Cycle 1, second Validation.** Parent is [run17-val1](../run17-val1/README.md).

**Single change:** `--max-num-seqs 32` (val1 uses 64).

**Why:** 32 is below the Validation peak of 35, so this is the one cap that can show queueing on a Validation. If SLO-met falls here while val1 held, the tighter cap is costing TTFT and is a poor Final candidate. If it holds, it is the safer Final candidate when val1's replay still has p95 TPOT over 50 ms.

```bash
./run18-val2/flag-check.sh
REPLACE=1 ./run18-val2/start.sh
python3 lib/warmup.py
```

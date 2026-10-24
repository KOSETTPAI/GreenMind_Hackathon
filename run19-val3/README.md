# run19-val3: cap 64 plus long-prefill splitting

**Cycle 1, third Validation.** Parent is [run17-val1](../run17-val1/README.md).

**Single change:** `--long-prefill-token-threshold 2048`. The cap stays 64.

**Why:** while other requests are waiting, a prompt longer than 2048 tokens prefills at most 2048 tokens per step instead of taking the whole step. That is the TTFT cost of queueing behind one long prompt. Keep it only if the replay's p95 TTFT improves and p95 TPOT stays under 50 ms.

```bash
./run19-val3/flag-check.sh
REPLACE=1 ./run19-val3/start.sh
python3 lib/warmup.py
```

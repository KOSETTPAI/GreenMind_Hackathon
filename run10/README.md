# run10 — V6, batched-token budget 16384

**Conditional.** Parent is [run8](../run8/README.md), not run9. This compares budgets only.

**Single change:** `--max-num-batched-tokens 16384` instead of 8192.

**Run only if** 8192 materially improved TTFT and p95 TPOT still has room under 50 ms. `start.sh` refuses without `CONFIRM_V6=1`.

```bash
./run10/flag-check.sh
CONFIRM_V6=1 ./run10/start.sh
```

`flag-check.sh` does not require the variable. `start.sh` does.

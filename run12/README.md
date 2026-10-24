# run12 — V7, MTP k=2

**Conditional.** Parent is [run11](../run11/README.md).

**Single change:** `num_speculative_tokens` is 2 instead of 1. Same budget, caching still off.

**Run only if** run11 raised `S` and tool calls still parsed. `start.sh` refuses without `CONFIRM_K2=1`.

```bash
CONFIRM_K2=1 ./run12/start.sh
```

Do not try k=3 in this pass. The plan stops at two until k=2 itself wins.

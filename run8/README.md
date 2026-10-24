# run8 — V4, batched-token budget 8192

**Parent:** [run7](../run7/README.md).

**Single change:** `--max-num-batched-tokens 8192` instead of 4096. Every other line stays as in the kept run7 profile, including the prefix-caching choice.

**Question:** does the extra prefill budget cut TTFT by more than it hurts TPOT?

**Keep if:** `S` improves, or TTFT improves and p95 TPOT is still near 50 ms so a larger budget is worth trying. A worse TPOT means go back to 4096. Do not treat the larger number as better on its own.

```bash
./run8/flag-check.sh
REPLACE=1 ./run8/start.sh
```

If 8192 wins and TPOT still has room, the conditional larger budget is [run10](../run10/README.md). The scheduling experiment on this same parent is [run9](../run9/README.md).

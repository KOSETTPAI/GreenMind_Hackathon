# run17-val1: cap 64

**Cycle 1, first of the three Validations.** Parent is [run6](../run6/README.md). The schedule is [CYCLE_PLAN.md](../CYCLE_PLAN.md).

**Single change:** `--max-num-seqs 64`. Same profile as [run16](../run16/README.md). Submit this folder, not run16.

**Why:** the run6 Final reached 111 running and p95 TPOT of 82 ms. Interpolating from the Validation (35 running, 18 ms), p95 TPOT crosses 50 ms near 70 running. A cap of 64 stays under that. Requests beyond the cap wait. Some will miss TTFT. Uncapped, almost every peak request already missed TPOT.

Validation peaked at 35 running, so this cap does not bind there. The Validation only checks that the server still works. Rank it with `python3 lib/replay.py --label val1 --track final` once the GPU is idle.

```bash
./run17-val1/flag-check.sh
REPLACE=1 ./run17-val1/start.sh
python3 lib/warmup.py
```

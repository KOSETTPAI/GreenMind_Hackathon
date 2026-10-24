# run16: run6 + `--max-num-seqs 64`

**Parent:** [run6](../run6/README.md). Validation 95.6 (98/100), Final 19.1 (127/300).

**Single change:** `--max-num-seqs 64`. On an A100 the default is 256, so run6 had no effective cap.

**Why:** the run6 Final reached 111 running requests, and p95 TPOT rose to 82 ms. Most peak requests failed TPOT. The Validation never went past 35 running, at 18 ms. Interpolating between those two points, p95 TPOT crosses 50 ms at roughly 70 running. A cap of 64 keeps the decode batch under that. Requests over the cap wait for a slot. Some of them miss TTFT, but uncapped, almost every peak request already missed TPOT. Details in [run6/ANALYSIS.md](../run6/ANALYSIS.md).

**Test it under Final-like load.** Validation saturated at 98/100 on run6 and never reached this concurrency, so it cannot show the effect. Use one of:

- a Final submission, which is the graded track anyway, or
- `python3 lib/replay.py --label run16` with the GPU otherwise idle (see [lib/README.md](../lib/README.md)), compared with the same replay on run6.

**Same profile as [run17-val1](../run17-val1/README.md).** Submit `run17-val1`, not this folder, so the grader run has the cycle name. Do not submit both.

**Keep if:** Final SLO-met rises well above 127/300 and `S` above 19.1, with `A` unchanged. The Final with this profile is [run20-final1](../run20-final1/README.md). The order after it is in [CYCLE_PLAN.md](../CYCLE_PLAN.md).

```bash
./run16/flag-check.sh
REPLACE=1 ./run16/start.sh
python3 lib/warmup.py
```

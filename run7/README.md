# run7 — V3, batched-token budget 4096

**Parent:** [run6](../run6/README.md). This file assumes caching stayed off. If run5 won, copy `run5/profile.args` and add only the line below.

**Single change:** `--max-num-batched-tokens 4096`. On this A100 image the default for the API server is 2048, which is also the scheduler budget while MTP is on. A 20K–32K prompt then occupies the step for many iterations while short prompts wait. Those short prompts are most of the traffic and have the tightest TTFT limits.

**Keep if:** SLO-met and `S` rise. Watch p95 TPOT. A bigger prefill budget can slow decode. If TPOT goes well past 50 ms, this budget is too large.

```bash
./run7/flag-check.sh
REPLACE=1 ./run7/start.sh
```

Next is [run8](../run8/README.md), the same profile with 8192.

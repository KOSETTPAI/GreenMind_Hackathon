# run5 — V1, remove MTP

**Parent:** `run4/profiles/r4-full.args` (MTP k=1, prefix caching on, memory 0.90, context 40960).

**Single change:** the `--speculative-config` line is gone. Prefix caching stays. This is not `run4/profiles/r4-no-prefix.args`, which still turns MTP on.

**Question:** under the grader's peak, does MTP k=1 cost more than the draft tokens it saves?

**Keep if:** `S`, SLO-met, or p95 TTFT improves against the run4 Validation (32.8, 50/100) and accuracy and tool calls hold. A lower score with a much better TTFT can stay as the parent of run6, not as the final server.

```bash
./run5/flag-check.sh
REPLACE=1 ./run5/start.sh
```

Record the result in [log.md](log.md). Next default experiment is [run6](../run6/README.md).

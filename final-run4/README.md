# final-run4: budget 8192 + `--performance-mode throughput`

**Final #6 on the grader.** Final baseline: η 0.00163, macro-accuracy 87.8%. Plan and evidence: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

**What changes:** adds `--performance-mode throughput` to final-run3. This image's help describes it as "larger CUDA graphs, more aggressive batching, throughput-oriented kernels" for high concurrency. The Final peak runs about 100 requests at once.

**Launch this only if final-run3 raised SLO-met above 127.** If final-run3 came in below 127, launch `./run6/start.sh` for this Final instead: the plain best-known server (no budget change). See [CYCLE_PLAN.md](../CYCLE_PLAN.md).

Do **not** run a Validation on this container before the Final unless you have confirmed with the organizers that it is allowed. The Validation's 100 prompts are the first 100 of the Final, so a Validation leaves them in the prefix cache.

```bash
./final-run4/flag-check.sh && REPLACE=1 ./final-run4/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

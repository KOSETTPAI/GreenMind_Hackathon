# run18: run16 + `--long-prefill-token-threshold 2048`

**Combined candidate.** Parent is [run16](../run16/README.md): run6 + `--max-num-seqs 64`.

**Single change on top of run16:** `--long-prefill-token-threshold 2048`. While other requests are waiting, a prompt longer than 2048 tokens prefills at most 2048 tokens per step.

**Why:** on the run6 Final, TTFT was also over its SLO, with the p95 of TTFT ÷ SLO near 2.4× (derived from sL = 0.50 and p95 TPOT 82 ms). With a cap, requests also wait for a slot, and a long prefill that fills whole steps both delays new short prompts and stalls the decode steps of everyone running. The threshold splits that prefill so short prompts get in and steps stay short. The flag is in the deployed image (`vllm serve --help`). Chunked prefill is on by default there.

**Launch after** run16 has a Final or replay result. `start.sh` refuses without `CONFIRM_R18=1`.

```bash
./run18/flag-check.sh
CONFIRM_R18=1 REPLACE=1 ./run18/start.sh
python3 lib/warmup.py
```

**Keep if:** it beats run16 on the same track. Do not compare a run18 Final with a run16 Validation.

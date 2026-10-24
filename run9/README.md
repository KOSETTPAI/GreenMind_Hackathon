# run9 — V5, long-prefill cap

**Parent:** [run8](../run8/README.md). If 4096 beat 8192, copy the kept run7 profile instead and add only the line below.

**Single change:** `--long-prefill-token-threshold 4096`.

While more than one request is eligible, a prompt longer than 4096 tokens prefills at most 4096 tokens per step, so a short prompt can start instead of waiting behind it. The cap does not apply when that long prompt is the only request. Chunked prefill is already on by default in the deployed image, which is what makes the threshold do anything.

The plan also lists `--max-num-partial-prefills 2` and `--max-long-partial-prefills 1`. Neither flag is in `vllm serve --help` on the deployed image (`vllm 0.32.1rc1.dev361`). They are not in this profile. `./run9/flag-check.sh` must pass before a launch; do not add those two flags back unless a newer image lists them.

**Keep if:** short-prompt TTFT and SLO-met improve without a real TPOT or score drop.

```bash
./run9/flag-check.sh
REPLACE=1 ./run9/start.sh
```

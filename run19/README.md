# run19: run16 + MTP k=1

**Conditional.** Parent is [run16](../run16/README.md): run6 + `--max-num-seqs 64`.

**Single change on top of run16:** `--speculative-config {"method":"mtp","num_speculative_tokens":1}`.

**Why it could help:** on run4 full, MTP accepted 91.5% of draft tokens, about 1.9 tokens per decode step. At a fixed batch that cuts TPOT, so the cap could hold more requests under 50 ms.

**Why it could hurt:**

- run4 full had MTP and prefix caching together and hit only about 1% of prompt tokens. run6, without MTP, hit 87% on the Validation and 44% on the Final. Prefix caching is the biggest win measured so far.
- vLLM issue 53912 reports corrupted output with MTP plus prefix caching on a Qwen3.5-class hybrid model.

**Launch after** run16 has been measured. `start.sh` refuses without `CONFIRM_R19=1`. During the run, watch `prefix_hits_total` in `lib/watch.sh`. If the hit rate falls far below run6's, reject this run regardless of TPOT.

```bash
./run19/flag-check.sh
CONFIRM_R19=1 REPLACE=1 ./run19/start.sh
python3 lib/warmup.py
```

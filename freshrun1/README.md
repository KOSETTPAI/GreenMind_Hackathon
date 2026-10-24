# freshrun1: cold Final of the 19.1 server

**Next Final.** Final baseline: η 0.00163, macro-accuracy 87.8%.

**What this serves:** the only flag set that has cleared the Final energy cliff, launched cold. AWQ W4A16, MTP off, no `--max-num-seqs` cap, `--enable-prefix-caching --mamba-cache-mode align`, and no `--max-num-batched-tokens` (the image default, 2048 on this A100). Power stays at the card default (400 W).

The 19.1 Final was 127/300, 1.18×, p95 TTFT 2.16 s, p95 TPOT 82 ms. That container had already served two Validations, so the first 100 prompts were in the prefix cache. This folder is those same flags with a cold cache.

Launcher, endpoint, and flag check are the final-run3 shell. `flag-check.sh` calls [lib/flag-check.sh](../lib/flag-check.sh). `start.sh` calls [lib/start.sh](../lib/start.sh). Container `mango-vllm`, image `vllm/vllm-openai:nightly`, bind `0.0.0.0:8000`.

Do **not** run a Validation on this container before the Final unless the organizers have said that is allowed. The Validation’s 100 prompts are the first 100 of the Final.

```bash
./freshrun1/flag-check.sh && REPLACE=1 ./freshrun1/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

Copy the History row into [log.md](log.md) before changing any flag. Compare SLO-met, p95 TTFT, p95 TPOT, and η with 127/300, 2.16 s, 82 ms, 1.18×. If η is under 1.00×, this cold launch lost, even if another column improved.

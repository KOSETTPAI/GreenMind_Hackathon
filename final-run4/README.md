# final-run4: cold Final of the 19.1 server

**Next Final.** Final baseline: η 0.00163, macro-accuracy 87.8%. Formula and the measured Finals: the plan “Final score, from the formula”.

**What this serves:** the only flag set that has cleared the Final energy cliff, launched cold. That is run5’s profile: AWQ W4A16, MTP off, no `--max-num-seqs` cap, `--enable-prefix-caching --mamba-cache-mode align`, and no `--max-num-batched-tokens` (the image default, 2048 on this A100). Power stays at the card default (400 W).

**Why this, and not another budget:** `s_E` is 0 at or below 1.00×, and then `S` is 0. The 19.1 Final was 127/300, 1.18×, p95 TTFT 2.16 s, p95 TPOT 82 ms. It was run5’s container after two Validations, so the first 100 prompts were already in the prefix cache (44% hits). A cold launch of these same flags has not been graded. final-run3 changed the token budget to 8192 and omitted the cache flags in the same run, and its History row was not copied. This profile untangles that: one known shape, no warmup.

Do **not** run a Validation on this container before the Final unless the organizers have said that is allowed. The Validation’s 100 prompts are the first 100 of the Final.

Launcher, flag check, container, image, and endpoint are the final-run3 shell: `mango-vllm`, `vllm/vllm-openai:nightly`, bind `0.0.0.0:8000`.

```bash
./final-run4/flag-check.sh && REPLACE=1 ./final-run4/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

Copy the History row into [log.md](log.md) before changing any flag. Compare SLO-met, p95 TTFT, p95 TPOT, and η with 127/300, 2.16 s, 82 ms, 1.18×. If η is under 1.00×, this cold launch lost, even if another column improved.

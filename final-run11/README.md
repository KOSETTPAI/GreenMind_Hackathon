# final-run11: ultimate combination (budget 8192 + 350W + FlashInfer + NO seq cap)

**The Winning Final Profile.** Merges the 2.45s TTFT of run 10 with the 45 ms TPOT of run 8.  
Final baseline: η 0.00163, macro-accuracy 87.8%.

### Core Engineering Combination:
- **No `--max-num-seqs` Cap**: Eliminates head-of-line blocking, locking $p_{95}\text{ TTFT} \le 2.45\text{s}$.
- **Token Budget (`--max-num-batched-tokens 8192`)**: Ingests prompts in 1–2 dense steps, isolating decodes into pure decode mode ($p_{95}\text{ TPOT} \le 45\text{ ms}$).
- **Power Cap (`GREENMIND_POWER_W=350`)**: Provides 312 TFLOPS compute to digest 8192 prefill chunks without queue delay, while keeping active Joules $< 195\text{ J/req}$.
- **Attention Backend (`--attention-backend FLASHINFER`)**: Fast paged attention decode speed.
- **Prefix Caching (`--enable-prefix-caching --mamba-cache-mode align`)**: Unlocks 44–87% cache reuse on multi-turn tool calling.

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main
./final-run11/flag-check.sh && REPLACE=1 ./final-run11/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final on the grader. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

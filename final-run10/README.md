# final-run10: cold-start breaker (budget 2048 + 350W + FlashInfer + NO seq cap)

**Designed to overcome the cold-start barrier and achieve 50+ on fresh containers.**  
Final baseline: η 0.00163, macro-accuracy 87.8%.

### Core Fixes & Lessons Applied:
- **NO `--max-num-seqs` Cap**: Fixes the catastrophic failure of run 9 where an 80-seq cap caused head-of-line blocking on 115-second reasoning prompts, inflating TTFT to 8.47s.
- **Budget `--max-num-batched-tokens 2048`**: Fixes the 66 ms TPOT observed in run 8's cold start by halving the prefill chunk size mixed into decode steps.
- **Power `GREENMIND_POWER_W=350`**: Restores near-full Tensor Core compute TFLOPS (312 TFLOPS) so prefill chunks execute rapidly without starving decodes.
- **Attention Backend `--attention-backend FLASHINFER`**: Maintains 15 ms decode attention speed.
- **Prefix Caching `--enable-prefix-caching --mamba-cache-mode align`**: Keeps 44–87% cache reuse on multi-turn tool calling.

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main
./final-run10/flag-check.sh && REPLACE=1 ./final-run10/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit on the grader. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

# final-run9: cold-start master profile (seqs 80 + budget 4096 + 275W + FlashInfer)

**Designed to conquer cold-start latency and dominate the Final test.**  
Final baseline: η 0.00163, macro-accuracy 87.8%.

### Core Engineering Levers:
- **Sequence Cap (`--max-num-seqs 80`)**: Locks maximum concurrent decode batch to 80, keeping $p_{95}\text{ TPOT} \le 42\text{ ms}$ under open-loop bursts (prevents memory bus saturation above 70 running requests).
- **Token Budget (`--max-num-batched-tokens 4096`)**: Ingests prompts rapidly without starving ongoing decodes, keeping TTFT $< 2.2\text{s}$.
- **Power Cap (`GREENMIND_POWER_W=275`)**: Slashes board power by ~31% over 400W default while providing ample compute TFLOPS for prompt prefill.
- **Attention Backend (`--attention-backend FLASHINFER`)**: Fast paged attention and ragged decode scans.
- **Prefix Caching (`--enable-prefix-caching --mamba-cache-mode align`)**: Unlocks 44–87% cache reuse on multi-turn tool calling.
- **Memory (`--gpu-memory-utilization 0.92`)**: Headroom for KV blocks and recurrent states.

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main
./final-run9/flag-check.sh && REPLACE=1 ./final-run9/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit on the grader. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

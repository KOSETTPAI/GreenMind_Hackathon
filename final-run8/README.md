# final-run8: budget 4096 + FlashInfer + Prefix Caching (align) + mem 0.92 + 300W

**The Golden Tuning Profile.** Final baseline: η 0.00163, macro-accuracy 87.8%.

**Why this configuration wins:**
- **Power Limit (300 W)**: Prevents prefill starvation while still saving ~25% power over the 400 W default (maintaining active Joules < 185 J/req).
- **Token budget (`--max-num-batched-tokens 4096`)**: Eliminates the 23-second queue backlog observed with 8192, pulling TTFT back down to $< 2.2\text{s}$.
- **Attention backend (`--attention-backend FLASHINFER`)**: Keeps decode steps ultra-fast (maintains $p_{95}\text{ TPOT} \le 45\text{ ms}$).
- **Prefix caching (`--enable-prefix-caching --mamba-cache-mode align`)**: Unlocks 44–87% cache hits on multi-turn tool calling and system prompts.
- **Memory (`--gpu-memory-utilization 0.92`)**: Prevents KV cache eviction during peak burst.
- **MTP off**: Avoids speculative draft verification overhead and cache hash degradation.

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main
./final-run8/flag-check.sh && REPLACE=1 ./final-run8/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit on the grader. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

# final-run8: budget 8192 + FlashInfer + Prefix Caching (align) + mem 0.92

**Final run profile.** Final baseline: η 0.00163, macro-accuracy 87.8%. Plan and evidence: [CYCLE_PLAN.md](../CYCLE_PLAN.md) · [approach/19](../approach/19_Top_Trending_vLLM_Energy_and_Latency_Techniques.md).

**Key levers:**
- Token budget `--max-num-batched-tokens 8192`: cleans pending prefill in 1–2 fast steps, keeping decodes in pure decode mode (TPOT < 35 ms under burst).
- Attention backend `--attention-backend FLASHINFER`: optimized paged attention and rag-tensor scans for hybrid Gated DeltaNet architecture.
- Prefix caching `--enable-prefix-caching --mamba-cache-mode align`: caches system prompts and multi-turn tool calling prefixes.
- Memory `--gpu-memory-utilization 0.92`: expands KV cache headroom to prevent preemption at high concurrency.
- Context `--max-model-len 40960`: fits full 32K prompts + 8192 max tokens.
- MTP off: avoids prefix hash degradation and verification overhead.

```bash
./final-run8/flag-check.sh && REPLACE=1 ./final-run8/start.sh
python3 lib/warmup.py
./lib/watch.sh        # second terminal, just before Submit
# Submit the Final on the grader. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

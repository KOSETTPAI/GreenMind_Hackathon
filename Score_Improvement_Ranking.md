# GreenMind — Every Approach, Ranked

Why the approaches in [approach/](approach/README.md) are ranked the way they are, and the sources behind them.

> Ranking basis: expected score gain ÷ (effort + risk), on our setup (1× A100 40 GB, vLLM, MANGO1.5-Qwen3.5-9B, 2-day event).
> These are hypotheses until our own Validation runs confirm them. Flag names are from the vLLM docs; check them against the installed vLLM version (`vllm serve --help`).

---

## Why the ranking looks like this (the energy budget)

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2` → **energy carries 60% of the weight.**

| | Value |
|---|---|
| Baseline efficiency (η_base) | **Final 0.00163** SLO-met req/J (graded); Validation 0.00154 (practice). Confirmed on the grader page |
| ≈ Baseline cost | ~615 J per good answer |
| Full energy marks (3×) | ~205 J per good answer → **~61 kJ total** if all 300 pass |
| A100 idle draw | ~50–57 W, and **idle counts** |
| Idle cost of a ~10 min window | ~33 kJ — about half the full-marks budget before any work |

Two conclusions drive the ranking:

1. **Lower the watts while working**, not only the run time. Idle alone eats half the budget.
2. **Turn missed answers into good ones.** A late answer still costs energy and earns nothing, so every rescued request raises η for free.

---

## Ranking

The ranked list now lives in [approach/README.md](approach/README.md), one file per approach (numbered 1 to 19).

---

## Sources

- [From Words to Watts — arXiv 2310.03003](https://arxiv.org/pdf/2310.03003)
- [GPU Power Capping at HPC Scale — arXiv 2402.18593](https://arxiv.org/pdf/2402.18593)
- [GreenLLM — arXiv 2508.16449](https://arxiv.org/pdf/2508.16449)
- [xPU-athalon — arXiv 2604.10852](https://arxiv.org/pdf/2604.10852)
- [Energy vs frequency U-curve — arXiv 2509.04827](https://arxiv.org/pdf/2509.04827v1)
- [DynamoLLM — arXiv 2408.00741](https://arxiv.org/html/2408.00741v1)
- [MANGO AWQ-W4A16-mtp model page](https://friendli.ai/models/CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp)
- [vLLM speculative config (MTP types)](https://docs.vllm.ai/en/v0.11.0/api/vllm/config/speculative.html)
- [vLLM forum: Qwen3.5 MTP](https://discuss.vllm.ai/t/qwen3-5-27b-fp8-speculative-decoding/2447)
- [vLLM blog: Qwen3-Next hybrid support](https://vllm.ai/blog/qwen3-next)
- [vLLM docs: automatic prefix caching](https://docs.vllm.ai/en/v0.30.0/features/automatic_prefix_caching/)
- [Qwen3.6-27B W4A16 (Avesed)](https://huggingface.co/Avesed/Qwen3.6-27B-W4A16)
- [Qwen3.6-27B W4A16 (88plug)](https://friendli.ai/models/88plug/Qwen3.6-27B-W4A16)
- [Qwen3.8-27B AWQ MTP notes](https://friendli.ai/models/Twu31/Qwen3.8-27B-AWQ-INT4-MTP-LowLatency)
- [GPTQ vs AWQ on vLLM Marlin](https://computingforgeeks.com/?p=172295)
- [A100 idle power — NVIDIA forum](https://forums.developer.nvidia.com/t/minimizing-a100-power-consumptin-while-idle-under-linux/308388)

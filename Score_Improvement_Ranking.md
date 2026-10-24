# GreenMind — Every Approach, Ranked

Every optimization from the roadmap and from the research, ranked by **how much score it can add for the time and risk it costs**, with one line on the evidence behind each.

> Ranking basis: expected score gain ÷ (effort + risk), on our setup (1× A100 40 GB, vLLM, MANGO1.5-Qwen3.5-9B, 2-day event).
> These are hypotheses until our own Validation runs confirm them. Flag names are from the vLLM docs; check them against the installed vLLM version (`vllm serve --help`).

---

## Why the ranking looks like this (the energy budget)

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2` → **energy carries 60% of the weight.**

| | Value |
|---|---|
| Baseline efficiency (η_base) | 0.00163 SLO-met req/J (one source says 0.00154 — confirm) |
| ≈ Baseline cost | ~615 J per good answer |
| Full energy marks (3×) | ~205 J per good answer → **~61 kJ total** if all 300 pass |
| A100 idle draw | ~50–57 W, and **idle counts** |
| Idle cost of a ~10 min window | ~33 kJ — about half the full-marks budget before any work |

Two conclusions drive the ranking:

1. **Lower the watts while working**, not only the run time. Idle alone eats half the budget.
2. **Turn missed answers into good ones.** A late answer still costs energy and earns nothing, so every rescued request raises η for free.

---

## Summary table

| Rank | Approach | Expected gain | Effort | Risk | Do it? |
|---:|---|---|---|---|---|
| 0 | Valid server + reproduced baseline | Required (no score without it) | Low | Low | **Must** |
| 1 | Fixed GPU power cap | High (≈ −20% energy) | Very low | Low–Med | **Yes, first** |
| 2 | Provided AWQ W4A16 model | High | Low | Medium (accuracy) | **Yes** |
| 3 | MTP speculative decoding | Medium–High | Low | Medium | **Yes** |
| 4 | Tune `max_num_seqs` (batch size) | Medium–High | Low | Low | **Yes** |
| 5 | Tune `max_num_batched_tokens` + chunked prefill | Medium | Low | Low | **Yes** |
| 6 | Prefix caching (`--mamba-cache-mode align`) | Medium (agentic/RAG) | Low | Medium | **Yes** |
| 7 | `gpu_memory_utilization` / `max_model_len` | Low–Medium | Very low | Low | Yes |
| 8 | Mamba state cache in BF16 | Low–Medium | Very low | Low–Med | Yes, if time |
| 9 | Keep CUDA graphs on + warm up before the run | Low–Medium | Very low | Low | Yes (check) |
| 10 | Fixed clock lock instead of / with power cap | Low–Medium | Very low | Medium | Maybe |
| 11 | Re-quantize ourselves (keep DeltaNet in BF16) | Medium (only if #2 hurts accuracy) | High | Medium | Only as fallback |
| 12 | API server / CPU worker count | Low | Very low | Low | Only if CPU-bound |
| 13 | FP8 KV cache | Low | Low | Medium | Probably not |
| 14 | Scheduling policy (priority) | Low | Low | Low | Probably not |
| 15 | External draft model (instead of MTP) | Low | Medium | High | No |
| 16 | Switch engine to SGLang | Unknown | High | High | No (unless vLLM blocks us) |
| 17 | TensorRT-LLM / llama.cpp | Unknown | Very high | Very high | No |
| 18 | Pruning | Low | High | High | No |
| 19 | Fine-tuning / distillation | Low (in 2 days) | Very high | High | No |
| 20 | Custom kernels | Unknown | Very high | Very high | No |
| ✗ | Not allowed: dynamic clocks, window-only settings, response caching, NVML tampering | — | — | Disqualification | **Never** |

---

## Details

### 0. Valid server + reproduced baseline — *must do first*

**Plain version:** Get the original setup running and measure it, so every later change can be compared against it.

- Run `vllm serve CMKL/MANGO1.5-Qwen3.5-9B --enable-auto-tool-choice --tool-call-parser qwen3_coder`.
- Submit one Validation run. Check it lands near η_base and 87.2–87.8% macro-accuracy.
- Run it twice to learn the noise (how much the score moves with no change at all).
- **Record:** joules, SLO-met count, per-class accuracy, p95 TTFT, p95 TPOT.

---

### 1. Fixed GPU power cap — *best value*

**Plain version:** Limit how many watts the GPU may draw. Writing words mostly waits on memory, so the GPU barely slows down.

**Evidence:**
- A100, LLaMA-65B: 250 W → 175 W cut energy **~23%** for **~7%** more time ([arXiv 2310.03003](https://arxiv.org/pdf/2310.03003)). Confirmed at HPC scale: 5–8% slower, 22–24% less energy; 150 W slowed things noticeably ([arXiv 2402.18593](https://arxiv.org/pdf/2402.18593)).
- A100 decode draws only ~50–60% of max power, so there is headroom ([arXiv 2604.10852](https://arxiv.org/pdf/2604.10852)).
- Energy vs clock speed is U-shaped: there's a sweet spot, and going too low wastes energy again ([arXiv 2509.04827](https://arxiv.org/pdf/2509.04827v1)).

**How to try:**
```bash
sudo nvidia-smi -pm 1
```
```bash
sudo nvidia-smi -pl 175
```
Sweep **250 → 200 → 175 → 150 W**, one Validation run each.

**Risk:** too low → TPOT > 50 ms or TTFT misses at peak → fewer good answers.
**Rule:** set it **before** the run and keep it **constant** the whole time.

---

### 2. Provided AWQ W4A16 model

**Plain version:** A compressed copy of the model (4-bit weights). Each word needs less memory reading → faster and cheaper.

**Evidence:**
- The model page says it was built for A100: vLLM runs it with the Marlin kernel, which suits memory-bound decode ([model page](https://friendli.ai/models/CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp)).
- It frees ~13 GB of GPU memory → more room for batching (helps #4).

**How to try:** `vllm serve CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp ...` with the same flags as the baseline.

**Risk:** accuracy. For similar Qwen hybrid models, people **disagree** on whether quantizing the DeltaNet layers is safe ([fine](https://huggingface.co/Avesed/Qwen3.6-27B-W4A16) vs [breaks state](https://friendli.ai/models/88plug/Qwen3.6-27B-W4A16)).
**Check:** accuracy **for every class** (Thai, tool calling, math/code, long context). Retention must stay ≥ 98% for full A.

---

### 3. MTP speculative decoding

**Plain version:** A built-in helper guesses the next few words. The main model checks them all in one step → fewer expensive steps.

**Evidence:**
- vLLM supports MTP with `"method": "mtp"` for Qwen3.5 / Qwen3-Next ([vLLM docs](https://docs.vllm.ai/en/v0.11.0/api/vllm/config/speculative.html), [vLLM blog](https://vllm.ai/blog/qwen3-next)).
- One user on Qwen3.5-27B could only run `num_speculative_tokens: 1`; a vLLM maintainer said more should work ([forum](https://discuss.vllm.ai/t/qwen3-5-27b-fp8-speculative-decoding/2447)).

**How to try:**
```bash
vllm serve CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp --speculative-config '{"method":"mtp","num_speculative_tokens":1}' --enable-auto-tool-choice --tool-call-parser qwen3_coder
```
Then try 2 and 3.

**Risk:** helps most at small batches. At the 4 req/s peak (big batches) the extra checking work can cancel the gain. Measure joules, not just speed.

---

### 4. Tune `max_num_seqs` (how many answers at once)

**Plain version:** More answers in parallel = each memory read serves more answers = less energy each.

**Evidence:** batching is the main decode lever; weight reads get shared across the batch (roadmap Stage 6, vLLM tuning docs).

**How to try:** `--max-num-seqs 64`, `128`, `256`.
**Risk:** too many → each word slower → TPOT > 50 ms. Find the largest value that still passes TPOT at peak.
**Re-tune after** changing the model (#2) or power cap (#1).

---

### 5. Tune `max_num_batched_tokens` + chunked prefill

**Plain version:** Controls how much question-reading is mixed into each step. Long documents (RAG, 32K context) can block word-writing for everyone else.

**How to try:** `--enable-chunked-prefill --max-num-batched-tokens 2048` / `4096` / `8192`.
**Trade-off:** smaller = smoother TPOT, slower TTFT for long prompts. Larger = the opposite.
**Measure:** p95 TTFT (normalized by each request's own limit) and p95 TPOT together.

---

### 6. Prefix caching (hybrid mode)

**Plain version:** Reuse the reading work when questions share the same start. Our test has **60 agentic questions with up to 15 turns** and 60 RAG questions, so there's lots of repeated text.

**Evidence:** for hybrid models, vLLM keeps prefix caching **off by default**; it needs `--mamba-cache-mode align` ([vLLM docs](https://docs.vllm.ai/en/v0.30.0/features/automatic_prefix_caching/)). Reuse only works in whole blocks, which are large for DeltaNet models ([community report](https://friendli.ai/models/Twu31/Qwen3.8-27B-AWQ-INT4-MTP-LowLatency)).

**How to try:** `--enable-prefix-caching --mamba-cache-mode align`.
**Check:** the startup log says prefix caching is **enabled**, and the metrics show cache hits.
**Allowed:** rules permit normal KV / prefix caching (just not caching graded responses).

---

### 7. `gpu_memory_utilization` / `max_model_len`

**Plain version:** Give vLLM more GPU memory for cache, and don't reserve room for longer prompts than the test uses.

**How to try:** `--gpu-memory-utilization 0.92`–`0.95`. Set `--max-model-len` to cover 32K prompt + 8,192 output (about 40,960). **Don't go lower**, or long requests fail.
**Risk:** too high → out-of-memory crash mid-run → the whole submission fails.

---

### 8. Mamba state cache in BF16

**Plain version:** Store each conversation's running memory in a smaller format → smaller cache blocks → more prefix reuse, more parallel answers.

**Evidence:** one user reported BF16 state about halved block size and raised cache hits with no output change ([community report](https://friendli.ai/models/Twu31/Qwen3.8-27B-AWQ-INT4-MTP-LowLatency)). One report only.

**How to try:** `--mamba-ssm-cache-dtype bfloat16` (check the flag exists in our vLLM).
**Check:** accuracy, especially long context.

---

### 9. Keep CUDA graphs on + warm up before the run

**Plain version:** Pre-record GPU work so small steps launch faster. Warm-up makes the first real requests fast too.

- **Don't** pass `--enforce-eager` (it turns CUDA graphs off).
- Send a few warm-up requests (short, long, tool call) **after startup and before submitting**. The hybrid kernels compile on first use.

---

### 10. Fixed clock lock (alternative or extra to the power cap)

**Plain version:** Instead of a watt limit, fix the GPU's speed.

**How to try:**
```bash
sudo nvidia-smi -lgc 1095,1095
```
Compare against the best power cap from #1.
**Evidence:** no source found showing it beats a power cap or meaningfully lowers idle power ([NVIDIA forum](https://forums.developer.nvidia.com/t/minimizing-a100-power-consumptin-while-idle-under-linux/308388)). Must stay constant all run.

---

### 11. Re-quantize ourselves — *fallback only*

**When:** only if the provided AWQ model loses too much accuracy (especially Thai or tool calls).
**How:** llm-compressor AWQ/GPTQ on **open** calibration data that includes Thai, keeping the Gated DeltaNet layers in BF16.
**Rules:** must be made during the event from the official weights, uploaded to Hugging Face, and disclosed.
**Cost:** calibration can take ~30 min or more ([comparison](https://computingforgeeks.com/?p=172295)), plus a full re-test.

---

### 12. API server / CPU workers

Only matters if the CPU is the bottleneck (GPU shows idle gaps while the queue is full). Check with `htop` during a Validation run. If needed: `--api-server-count 2`.

---

### 13. FP8 KV cache — *probably not*

The A100 has no FP8 math units (storage only). Only ~8 of 32 layers use a KV cache, so the memory savings are small. Accuracy risk on long context.

---

### 14. Scheduling policy — *probably not*

vLLM's `--scheduling-policy priority` needs a priority on each request, and the grader won't send one. Default first-come-first-served is fine.

---

### 15. External draft model — *no*

A separate small model must be disclosed, and **its energy counts**. The built-in MTP (#3) does the same job more cheaply.

---

### 16–17. Switching engines (SGLang, TensorRT-LLM, llama.cpp) — *no*

Hybrid Mamba/DeltaNet support, tool-call format, and streaming must all be re-verified (the six-point gate in `use_ur_brain/117_Engine_Migration_Gate.md`). Too risky for 2 days unless vLLM itself blocks us.

---

### 18–20. Pruning, fine-tuning/distillation, custom kernels — *no*

High effort, high accuracy risk, small likely gain in the time we have.

---

### ✗ Not allowed — never do these

- **Changing clocks or power during the run** (GreenLLM-style dynamic scaling, [arXiv 2508.16449](https://arxiv.org/pdf/2508.16449)). It saves energy in research but breaks the "constant setting" rule.
- Any setting that applies **only** during the measured window.
- Caching graded responses.
- `LD_PRELOAD` or replacing NVML (measurement tampering).
- Extra GPU workloads or external API calls during a graded run.

---

## Suggested order of experiments

1. Baseline ×2 (noise floor)
2. Power cap sweep (#1) → keep the best
3. AWQ model (#2) → check per-class accuracy
4. + MTP (#3), tokens 1 → 2 → 3
5. + prefix caching (#6)
6. Tune batch size (#4), then batched tokens (#5)
7. Small knobs (#7, #8, #9)
8. Re-check the power cap (#1) on the final config
9. Final submission only on a config that passed Validation **twice**

**Change one thing per run. Log joules, SLO-met count, per-class accuracy, p95 TTFT/TPOT, and S.**

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

# Approaches — Ranked Index

Every optimization we considered, one file each. **File number = rank**, from 1 (do first) to 18 (never do). Ranked by **expected score gain ÷ (effort + risk)** on our setup (1× A100 40 GB, vLLM, MANGO1.5-Qwen3.5-9B, 2-day event).

> Nothing here has been run yet. Every command section is labeled **"Proposed steps (untested — run on the VM to confirm)"**. Commands come from public docs, the briefing, and published studies on other models; check flag names with `vllm serve --help` and trust only our own Validation runs.

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. Energy carries the most weight, and idle power counts, so the top approaches either lower watts or turn missed requests into SLO-met ones. Background and sources: [Score_Improvement_Ranking.md](../Score_Improvement_Ranking.md) · [scoring_criteria.md](../scoring_criteria.md).

---

## Ranking

| Rank | Approach | Gain | Effort | Risk | Verdict |
|---:|---|---|---|---|---|
| 1 | [Baseline + measurement](1_Baseline_and_Measurement_Prerequisite.md) | required | low | low | **Must, first** |
| 2 | [Fixed GPU power cap](2_Fixed_GPU_Power_Cap.md) | high | very low | low–med | **Yes** |
| 3 | [Weight-only quantization](3_Weight_Only_Quantization_With_Accuracy_Guardrail.md) (provided AWQ W4A16; self-made FP8/INT4 as fallback) | high | low–high | medium | **Yes** |
| 4 | [MTP speculative decoding](4_MTP_Speculative_Decoding.md) | med–high | low | medium | **Yes** |
| 5 | [Batch size (`max_num_seqs`)](5_Batch_Size_Max_Num_Seqs.md) | med–high | low | low | **Yes** |
| 6 | [Batched-token budget + chunked prefill](6_Batched_Tokens_and_Chunked_Prefill.md) | medium | low | low | **Yes** |
| 7 | [Prefix caching (hybrid mode)](7_Prefix_Caching_Hybrid.md) | medium | low | medium | **Yes** |
| 8 | [GPU memory + `max_model_len`](8_GPU_Memory_and_Max_Model_Len.md) | low–med | very low | low | Yes |
| 9 | [Mamba state cache in BF16](9_Mamba_State_Cache_BF16.md) | low–med | very low | low–med | If time |
| 10 | [CUDA graphs on + warm-up](10_CUDA_Graphs_and_Warmup.md) | low–med | very low | low | Yes (check) |
| 11 | [Fixed clock lock](11_Fixed_Clock_Lock.md) | low–med | very low | medium | Maybe |
| 12 | [API server / CPU workers](12_API_Server_and_CPU_Workers.md) | low | very low | low | Only if CPU-bound |
| 13 | [FP8 KV cache](13_FP8_KV_Cache.md) | low | low | medium | Probably not |
| 14 | [Scheduling policy](14_Scheduling_Policy.md) | low | low | low | Probably not |
| 15 | [External draft model](15_External_Draft_Model.md) | low | medium | high | No |
| 16 | [Switch engine (SGLang, TensorRT-LLM, llama.cpp)](16_Engine_Switch.md) | unknown | high | high | No |
| 17 | [Pruning, fine-tuning, custom kernels](17_Rejected_Pruning_Finetuning_Kernels.md) | low | very high | high | No |
| 18 | [Not allowed (dynamic clocks, response caching, NVML tampering, …)](18_Not_Allowed.md) | — | — | disqualification | **Never** |

---

## Suggested experiment order

The run order differs slightly from the rank, because batch size should be tuned after the model and caching are settled.

1. Baseline ×2 for the noise floor ([1](1_Baseline_and_Measurement_Prerequisite.md))
2. Power cap sweep ([2](2_Fixed_GPU_Power_Cap.md)) → keep the best
3. Quantized model, check per-class accuracy ([3](3_Weight_Only_Quantization_With_Accuracy_Guardrail.md))
4. + MTP, draft tokens 1 → 2 → 3 ([4](4_MTP_Speculative_Decoding.md))
5. + prefix caching ([7](7_Prefix_Caching_Hybrid.md))
6. Tune batch size, then batched tokens ([5](5_Batch_Size_Max_Num_Seqs.md), [6](6_Batched_Tokens_and_Chunked_Prefill.md))
7. Small knobs ([8](8_GPU_Memory_and_Max_Model_Len.md), [9](9_Mamba_State_Cache_BF16.md), [10](10_CUDA_Graphs_and_Warmup.md))
8. Re-check the power cap on the final config
9. Final submission only on a config that passed Validation twice

**Change one thing per run.** Log joules, SLO-met count, per-class accuracy, p95 TTFT/TPOT, and S for every run.

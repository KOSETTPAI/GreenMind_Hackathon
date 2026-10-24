# Approaches — Ranked Index

Every optimization we considered, one file each, ranked by **expected score gain ÷ (effort + risk)** on our setup (1× A100 40 GB, vLLM, MANGO1.5-Qwen3.5-9B, 2-day event).

> Nothing here has been run yet. Every command section is labeled **"Proposed steps (untested — run on the VM to confirm)"**. Commands come from public docs, the briefing, and published studies on other models; check flag names with `vllm serve --help` and trust only our own Validation runs.

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. Energy carries the most weight, and idle power counts, so the top approaches either lower watts or turn missed requests into SLO-met ones. Background and sources: [Score_Improvement_Ranking.md](../Score_Improvement_Ranking.md) · [scoring_criteria.md](../scoring_criteria.md).

---

## Ranking

| Rank | File | Approach | Gain | Effort | Risk | Verdict |
|---:|---|---|---|---|---|---|
| — | [0](0_Baseline_and_Measurement_Prerequisite.md) | Baseline + measurement | required | low | low | **Must, first** |
| 1 | [2](2_Fixed_GPU_Power_Cap.md) | Fixed GPU power cap | high | very low | low–med | **Yes** |
| 2 | [1](1_Weight_Only_Quantization_With_Accuracy_Guardrail.md) | Weight-only quantization (provided AWQ W4A16; self-made FP8/INT4 as fallback) | high | low–high | medium | **Yes** |
| 3 | [3](3_MTP_Speculative_Decoding.md) | MTP speculative decoding | med–high | low | medium | **Yes** |
| 4 | [4](4_Batch_Size_Max_Num_Seqs.md) | Batch size (`max_num_seqs`) | med–high | low | low | **Yes** |
| 5 | [5](5_Batched_Tokens_and_Chunked_Prefill.md) | Batched-token budget + chunked prefill | medium | low | low | **Yes** |
| 6 | [6](6_Prefix_Caching_Hybrid.md) | Prefix caching (hybrid mode) | medium | low | medium | **Yes** |
| 7 | [7](7_GPU_Memory_and_Max_Model_Len.md) | GPU memory + `max_model_len` | low–med | very low | low | Yes |
| 8 | [8](8_Mamba_State_Cache_BF16.md) | Mamba state cache in BF16 | low–med | very low | low–med | If time |
| 9 | [9](9_CUDA_Graphs_and_Warmup.md) | CUDA graphs on + warm-up | low–med | very low | low | Yes (check) |
| 10 | [10](10_Fixed_Clock_Lock.md) | Fixed clock lock | low–med | very low | medium | Maybe |
| 11 | [11](11_API_Server_and_CPU_Workers.md) | API server / CPU workers | low | very low | low | Only if CPU-bound |
| 12 | [12](12_FP8_KV_Cache.md) | FP8 KV cache | low | low | medium | Probably not |
| 13 | [13](13_Scheduling_Policy.md) | Scheduling policy | low | low | low | Probably not |
| 14 | [14](14_External_Draft_Model.md) | External draft model | low | medium | high | No |
| 15 | [15](15_Engine_Switch.md) | Switch engine (SGLang, TensorRT-LLM, llama.cpp) | unknown | high | high | No |
| 16 | [16](16_Rejected_Pruning_Finetuning_Kernels.md) | Pruning, fine-tuning, custom kernels | low | very high | high | No |
| ✗ | [17](17_Not_Allowed.md) | Not allowed (dynamic clocks, response caching, NVML tampering, …) | — | — | disqualification | **Never** |

File numbers are not ranks: file 1 was written first by a teammate; file 2 (power cap) ranks highest because it's the cheapest win.

---

## Suggested experiment order

1. Baseline ×2 for the noise floor ([0](0_Baseline_and_Measurement_Prerequisite.md))
2. Power cap sweep ([2](2_Fixed_GPU_Power_Cap.md)) → keep the best
3. Quantized model, check per-class accuracy ([1](1_Weight_Only_Quantization_With_Accuracy_Guardrail.md))
4. + MTP, draft tokens 1 → 2 → 3 ([3](3_MTP_Speculative_Decoding.md))
5. + prefix caching ([6](6_Prefix_Caching_Hybrid.md))
6. Tune batch size, then batched tokens ([4](4_Batch_Size_Max_Num_Seqs.md), [5](5_Batched_Tokens_and_Chunked_Prefill.md))
7. Small knobs ([7](7_GPU_Memory_and_Max_Model_Len.md), [8](8_Mamba_State_Cache_BF16.md), [9](9_CUDA_Graphs_and_Warmup.md))
8. Re-check the power cap on the final config
9. Final submission only on a config that passed Validation twice

**Change one thing per run.** Log joules, SLO-met count, per-class accuracy, p95 TTFT/TPOT, and S for every run.

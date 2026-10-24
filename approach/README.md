# Approaches — Ranked Index

Every optimization we considered, one file each. **File number = rank**, from 1 (do first) to 18 (never do). Ranked by **expected score gain ÷ (effort + risk)** on our setup (1× A100 40 GB, vLLM, MANGO1.5-Qwen3.5-9B, 2-day event).

> One Validation has been scored. File numbers stay the original ranking. The **run order below replaces that ranking** until SLO-met is high. Command sections in each file are still untested except the defaults that produced V0. Check new flag names with `vllm serve --help` on the VM.

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. Baselines differ by track. **Final (graded, the only one that counts): `η_base = 0.00163`, macro-accuracy `87.8%`.** Validation (practice): `0.00154`, `87.2%`. Full energy marks at 3× on both. Background: [Score_Improvement_Ranking.md](../Score_Improvement_Ranking.md) · [scoring_criteria.md](../scoring_criteria.md) · [experiments/log.md](../experiments/log.md).

**V0 (indicative):** `scripts/start-vllm.sh` defaults, `S = 34.8`, SLO-met `56/100`. The checkpoint is already `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`. Approach 3 is adopted, not the next run. A power cap (approach 2) waits until SLO-met is at least 90/100, because a slower decode would fail more of the 50 ms TPOT checks and shrink the numerator of `η`.

---

## Ranking

The verdict column is the original hypothesis. Follow [Run order after V0](#run-order-after-v0) for what to submit next. Power cap stays rank 2 on effort, and it is not the next run while SLO-met is 56/100.

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

## Run order after V0

Exact exports and smoke checks: [experiments/vm-sequence.md](../experiments/vm-sequence.md). One change per Validation. Revert any change that lowers SLO-met or `A`.

1. Copy the V0 History row into [experiments/log.md](../experiments/log.md). No submission.
2. `MAX_MODEL_LEN=40960` ([8](8_GPU_Memory_and_Max_Model_Len.md)). Keep it even if the pass count barely moves. Prompts reach 32K and the grader sets `max_tokens = 8192`.
3. `MAX_NUM_BATCHED_TOKENS=4096`, and chunked prefill if the log says it is off ([6](6_Batched_Tokens_and_Chunked_Prefill.md)). This is the default next step when misses are TPOT or mixed.
4. MTP with one draft token ([4](4_MTP_Speculative_Decoding.md)). Try `k = 2` or `3` only if `k = 1` raises `S` and tool calls still parse.
5. Prefix caching with `--mamba-cache-mode align` ([7](7_Prefix_Caching_Hybrid.md)). Skip the submission if the log says hybrid prefix caching turned itself off.
6. Raise GPU memory utilization, then `max_num_seqs`, only while p95 TPOT is under 50 ms ([5](5_Batch_Size_Max_Num_Seqs.md), [8](8_GPU_Memory_and_Max_Model_Len.md)).
7. Power cap sweep 250 → 200 → 175 W, only if SLO-met is at least 90/100 ([2](2_Fixed_GPU_Power_Cap.md)).
8. One confirmation Validation, then one Final. Do not retune on Final.

Do not rebuild a BF16 baseline, and do not start another quantization. Approaches 13–17 stay off the list for the time left before Final closes.

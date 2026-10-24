# Approach 3: Weight-Only Quantization with an Accuracy Guardrail

**Goal:** raise energy efficiency η (SLO-met requests per joule) toward the 3× full-marks point, while also helping throughput and latency, without letting macro-accuracy retention fall below the cutoff.

**One-line thesis:** decode on an A100 is limited by how fast weights stream from memory. Storing the weights in 8 or 4 bits instead of 16 cuts the bytes moved per generated token by about 2–3.5×. That shortens GPU busy time (energy), frees VRAM for larger batches (throughput and fewer SLO misses at peak), and lowers TPOT (latency). The cost is accuracy risk, which we gate against the 87.2% reference.

> Estimates in this document are back-of-envelope hypotheses for planning. Only measured results on the official workload count.

---

## 1. Scoring targets (confirmed constants)

| Constant | Value | What it means for this approach |
|---|---|---|
| `η_base` | **Final 0.00163** SLO-met req/J (≈ 613 J per request); Validation 0.00154 (≈ 649 J) | the number to beat. Only the Final counts |
| `K` | 3× → Final η ≥ 0.00489 (≈ 204 J per request); Validation η ≥ 0.00462 (≈ 216 J) | full energy marks; gains past this are wasted |
| Reference macro-accuracy | **Final 87.8%**; Validation 87.2% | retention = candidate macro-accuracy / that track's reference |

Energy score (confirmed on the grader page): `s_E = clip(ln(η / η_base) / ln 3, 0, 1)`, with the track's own `η_base`.

| η gain vs baseline | 1.25× | 1.5× | 1.75× | 2× | 2.5× | 3× |
|---|---:|---:|---:|---:|---:|---:|
| s_E | 0.20 | 0.37 | 0.51 | 0.63 | 0.83 | 1.00 |

Concepts: [Energy per Useful Request](../use_ur_brain/121_Energy_per_Useful_Request.md) · [Accuracy Retention](../use_ur_brain/120_Accuracy_Retention_and_Relative_Loss.md) · [Score Symbols](../use_ur_brain/124_Score_Symbols_A_sE_sT_sL_S.md)

---

## 2. Why this lever moves several score components at once

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_E` (energy) | fewer bytes per decode step means a shorter busy time per token and less HBM traffic | ↑ |
| SLO-met count (numerator of η) | freed VRAM gives more cache, more concurrent sequences, less preemption and queueing at peak | ↑ |
| `s_L` (latency) | lower TPOT on decode-heavy requests; TTFT roughly unchanged (prefill is compute-bound) | ↑ or neutral |
| `s_T` (throughput) | larger batches, faster steps | ↑ |
| `A` (accuracy) | quantization error | ↓ (the risk we gate) |

Most serving-config tweaks trade one component for another (for example, bigger batches give better throughput but worse TPOT). Quantization is one of the few changes that can move energy, throughput, and latency in the same direction. That's why it's the first approach.

Concepts: [Memory Bandwidth](../use_ur_brain/34_Memory_Bandwidth.md) · [Arithmetic Intensity](../use_ur_brain/38_Arithmetic_Intensity.md) · [Decode](../use_ur_brain/54_Decode.md)

---

## 3. Back-of-envelope model

### 3.1 Bytes per decode step (9B parameters, A100 at ~1.555 TB/s)

| Weights | Approx. weight bytes* | Bandwidth floor per decode step | VRAM freed vs BF16 |
|---|---:|---:|---:|
| BF16 (baseline) | ~18 GB | ~11.6 ms | — |
| FP8 weight-only (W8A16) | ~9.5 GB | ~6.1 ms | ~8.5 GB |
| INT4 weight-only (W4A16, group 128) | ~5.5 GB | ~3.5 ms | ~12.5 GB |

*Includes layers usually left in BF16 (embeddings, LM head, norms, small gate projections). Real step time is higher than the floor (kernel efficiency, cache/state reads, overhead), and the advantage shrinks at large batch sizes, where decode becomes compute-bound.

### 3.2 Why 3× is hard: the idle floor
If the measurement window has a fixed length (the open-loop schedule plus drain), energy is:

`E ≈ T × (P_idle + (P_active − P_idle) × busy_fraction)`

Illustrative numbers (replace with your telemetry): `P_idle = 55 W`, `P_active = 280 W`, baseline `busy_fraction = 0.80`.

| Scenario | Busy fraction | Average power | η gain | s_E |
|---|---:|---:|---:|---:|
| Baseline | 0.80 | 235 W | 1.00× | 0.00 |
| Quantization cuts busy time 40% | 0.48 | 163 W | 1.44× | 0.33 |
| + batching retune (busy time down 56% total) | 0.35 | 134 W | 1.76× | 0.51 |
| + SLO-met rate 88% → 98% | 0.35 | 134 W | 1.96× | 0.61 |
| What 3× would require | ~0.10 | ~78 W | 3.00× | 1.00 |

Takeaways:
- On these assumptions, quantization plus batching could plausibly reach **~1.5–2×**, worth roughly **0.35–0.6 of s_E**.
- If idle time is inside the window, idle power dominates once active energy is small, so reaching **3× needs further levers** (idle power, power caps if allowed). That's a reason for a later approach, not for skipping this one.
- If the window is not fixed length (for example, it ends at the last completion), the gains are larger. **Confirm the window definition first** ([Measurement Window](../use_ur_brain/7_Measurement_Window.md)).

---

## 4. Go/no-go preconditions (check before any work)

| # | Question | Where to check | If "no" |
|---|---|---|---|
| 1 | Are quantized or converted artifacts allowed? Only organizer-provided ones, or self-made too? | briefing rules | stop; use only provided artifacts, or skip this approach |
| 2 | Is calibration on public data allowed (not on the evaluation set)? | briefing rules | use FP8 weight-only first (needs no calibration data) |
| 3 | Does the installed vLLM run this hybrid architecture with quantized linear layers on A100? | startup logs; small test | try the other format, or stop |
| 4 | Do we know the retention cutoff? | briefing | assume a conservative cutoff (≥ 98%) until known |
| 5 | Is the reproduced baseline close to the track's reference (Final η ≈ 0.00163 and 87.8%; Validation η ≈ 0.00154 and 87.2%)? | harness | fix the harness first; nothing below is trustworthy without this |

Concepts: [Allowed Artifacts](../use_ur_brain/9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [Hybrid Cache and Kernels](../use_ur_brain/86_Hybrid_Cache_and_Architecture_Specific_Kernels.md)

---

## 5. Candidate order (lowest risk first)

1. **FP8 weight-only (W8A16).** About half the weight bytes, usually very small accuracy loss, no calibration data needed. On the A100 this runs as weight-only through Marlin-style kernels; there's no FP8 compute. Expect vLLM to log that it's using weight-only FP8.
2. **INT4 weight-only (W4A16, GPTQ or AWQ, group size 128).** About 3.3× fewer weight bytes than BF16, with higher accuracy risk. Needs calibration data that includes **Thai, code, tool-call conversations, and long contexts**, with the chat template applied.
3. Only if both pass and there's time: an **FP8 KV cache** for the attention layers. It's a separate experiment, its support for this hybrid model and the A100 must be verified, and it should never be combined with step 1 or 2 in the same experiment.

Concepts: [FP8](../use_ur_brain/48_FP8.md) · [Weight-Only Quantization](../use_ur_brain/103_Weight_Only_Quantization_W4A16.md) · [AWQ](../use_ur_brain/105_AWQ.md) · [Calibration](../use_ur_brain/104_Calibration.md)

---

## 6. Experiment plan

Each step changes one thing. Every run is repeated at least 3 times on the official workload and arrival schedule, and logged in the experiment log.

### Step 0: Lock the baseline
- Reproduce BF16 + vLLM. Record macro-accuracy (target ≈ 87.8% Final, 87.2% Validation), per-category accuracy, SLO-met count, window energy, η (target ≈ 0.00163 Final, 0.00154 Validation), TTFT/TPOT p95, and preemptions.
- Measure the noise: the spread of η and of macro-accuracy across repetitions. This defines the minimum believable improvement.
- Record `P_idle`, `P_active`, and the busy fraction from telemetry to calibrate the model in section 3.2.

### Step 1: Get the artifact
- Prefer an organizer-provided quantized checkpoint, if one exists.
- Otherwise, only if the rules allow it, create one. Illustrative `llm-compressor` sketch (check the API for your installed version):

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from llmcompressor import oneshot
from llmcompressor.modifiers.quantization import QuantizationModifier

model = AutoModelForCausalLM.from_pretrained(SRC, torch_dtype="auto")
tok = AutoTokenizer.from_pretrained(SRC)

# FP8 weight-only path: no calibration data needed
recipe = QuantizationModifier(targets="Linear", scheme="FP8_DYNAMIC",
                              ignore=["lm_head"])  # extend after inspecting module names
oneshot(model=model, recipe=recipe)
model.save_pretrained(DST, save_compressed=True); tok.save_pretrained(DST)
```

- For the hybrid layers, list the module names first (`model.named_modules()`). Leave any layer that vLLM can't run quantized in BF16, and check the vLLM startup logs for warnings about layers falling back.
- Record SHA-256 hashes of the new artifact.

### Step 2: Smoke tests (must all pass)
Streaming and non-streaming chat, streaming tool calls with valid JSON arguments, multi-turn with tool results, Thai output (no broken characters), a prompt near the maximum context, `finish_reason` values, and a client disconnect.
→ [Smoke Testing](../use_ur_brain/88_Smoke_Testing.md)

### Step 3: Accuracy gate
- Run the full accuracy evaluation. Compute macro-accuracy and per-category accuracy, then `retention = macro / 0.872`.
- **Pass** if all of these hold:
  - retention ≥ cutoff + margin. The margin is the larger of 1 point or 2× the accuracy noise measured in Step 0.
  - no single category drops more than about 3 points (catches Thai, code, or tool-call collapse).
  - the tool-call JSON validity rate isn't lower than baseline.
- With an unknown cutoff, use 98% retention as the working floor, which means macro-accuracy ≥ 85.5%.

### Step 4: Energy and performance on the official schedule
- Same vLLM flags as the baseline; only the checkpoint changes.
- Record η, η / η_base, s_E, SLO-met count, TTFT/TPOT p95, preemptions, cache usage, and average power.
- **Pass** if η improves by more than the Step 0 noise and the SLO-met count is not lower.

### Step 5: Spend the freed VRAM (one flag per experiment)
Quantization frees roughly 8–12 GB, so the baseline memory settings are now leaving capacity unused.
1. Raise `--max-num-seqs` (for example 128 → 192 → 256) and watch TPOT p95 and the SLO-met count.
2. Re-check `--gpu-memory-utilization` and `--max-num-batched-tokens` against the new step times.
3. Stop increasing once SLO-met stops rising or TPOT p95 nears its limit.

Concepts: [Max Active Sequences](../use_ur_brain/94_Max_Active_Sequences.md) · [Batch Token Budget](../use_ur_brain/93_Batch_Token_Budget.md) · [GPU Memory Allocation](../use_ur_brain/101_GPU_Memory_Allocation.md)

### Step 6: Decide
Adopt the candidate with the best estimated total score S (median over repetitions) that passes every gate. Freeze it as the new best-known configuration, keep BF16 as the rollback, and only then move on to INT4 or other approaches.

---

## 7. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Accuracy drops in one category (Thai, code, tool calls) | per-category report | FP8 before INT4; better calibration mix; leave sensitive layers in BF16 |
| Quantized kernel unsupported for hybrid layers → silent fallback or slowdown | startup logs, profiler, no TPOT gain | add those layers to the ignore list; try the other format; stop if neither works |
| Quantization helps decode but not prefill-heavy RAG | TTFT unchanged on RAG | expected; prefix caching and chunked prefill are separate levers for that |
| Large batches make W4A16 compute-bound and erase the gain | gain shrinks as concurrency rises | tune `max_num_seqs` for score, not peak tokens/s |
| Tool-call JSON validity drops | smoke tests, validity rate | treat as a hard fail; fall back to FP8 or BF16 |
| Gain falls within noise | overlapping repetitions | don't adopt; keep BF16 |
| Artifact not allowed | rules | don't proceed |

---

## 8. Measurement sheet (one row per run)

| Run | Artifact | Flags diff | Macro-acc | Retention | Worst category Δ | Tool-call JSON valid % | SLO-met | E (kJ) | η | η/η_base | s_E | TTFT p95 | TPOT p95 | Preemptions | Decision |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| B1–B3 | BF16 | baseline | | | — | | | | | 1.00 | 0.00 | | | | reference |
| Q1–Q3 | FP8 W8A16 | none | | | | | | | | | | | | | |
| Q4–Q6 | FP8 W8A16 | max-num-seqs ↑ | | | | | | | | | | | | | |
| Q7–Q9 | INT4 W4A16 | none | | | | | | | | | | | | | |

---

## 9. Abandon criteria
- Neither FP8 nor INT4 passes the accuracy gate, **or**
- The η gain stays within run-to-run noise after the Step 5 retune, **or**
- The rules don't allow quantized artifacts.

In any of these cases, record the evidence (it narrows down the bottleneck) and move to the next approach. Candidates: serving-config tuning, prefix caching for agentic and RAG traffic, or idle and power management if allowed.

---

## 10. How this reads in the pitch
1. **Evidence:** decode is memory-bound (measured step time close to the bandwidth floor; telemetry). BF16 weights leave about 15 GB for cache, which limits concurrency at peak.
2. **Hypothesis:** halving or quartering the bytes per weight cuts busy time and raises concurrency, improving η, TPOT, and SLO-met requests.
3. **Controlled result:** retention X% vs the 87.2% reference (per-category table), η = Y (Z× baseline, s_E ≈ …), TPOT p95 and SLO-met changes, with 3-run medians and spread.
4. **Trade-offs and limits:** prefill-heavy traffic unchanged; idle-power floor limits progress toward 3×; next lever identified.

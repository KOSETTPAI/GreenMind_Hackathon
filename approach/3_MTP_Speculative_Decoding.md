# Approach 3: MTP Speculative Decoding

**Rank:** 3 · **Effort:** low · **Risk:** medium

**Goal:** generate more than one token per full model step using the checkpoint's built-in multi-token-prediction (MTP) head, cutting decode steps, energy, and TPOT.

**One-line thesis:** the MTP head drafts the next k tokens; the main model verifies them all in one pass. If enough drafts are accepted, one weight read produces several tokens.

> Expected gains are hypotheses. Only measured results on our workload count.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_E` | fewer full decode steps per output token | ↑ if acceptance is good |
| `s_L` (TPOT) | more tokens per step | ↑ |
| `s_T` | faster completion at peak | ↑ or neutral |
| `A` | verification should keep outputs the same at temperature 0 | neutral (verify) |

The gain is largest at small batch sizes. At the 4 req/s peak, batches are large and verification work can eat the gain.

Concepts: [Speculative Decoding](../use_ur_brain/111_Speculative_Decoding.md) · [MTP](../use_ur_brain/112_MTP_Multi_Token_Prediction.md) · [Decode](../use_ur_brain/54_Decode.md)

---

## 2. Evidence

- The provided artifact `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp` includes an MTP head ([model page](https://friendli.ai/models/CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp)).
- vLLM lists `qwen3_next_mtp` among MTP model types and a generic `mtp` method ([vLLM speculative config](https://docs.vllm.ai/en/v0.11.0/api/vllm/config/speculative.html)); vLLM supports Qwen3-Next hybrid models ([vLLM blog](https://vllm.ai/blog/qwen3-next)).
- One user on Qwen3.5-27B-FP8 could only run `num_speculative_tokens: 1`; a vLLM maintainer said more should work ([vLLM forum](https://discuss.vllm.ai/t/qwen3-5-27b-fp8-speculative-decoding/2447)).
- vLLM exposes per-request acceptance metrics (experimental) ([docs](https://docs.vllm.ai/en/latest/features/speculative_decoding/acceptance_metrics/)).

---

## 3. Go/no-go preconditions

| # | Question | If "no" |
|---|---|---|
| 1 | Do the checkpoint files include MTP weights (`mtp` in the weight index / `config.json`)? | skip approach |
| 2 | Does our vLLM start with `--speculative-config` on this model? | try k = 1; else skip |
| 3 | Do streaming and tool calls still work with it on? | hard fail; skip |

---

## 4. Proposed steps (untested — run on the VM to confirm)

Source: flag and method name from the vLLM docs above. Apply **after** Approach 1 (quantized model) is adopted, so only one thing changes.

```bash
vllm serve CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp --speculative-config '{"method":"mtp","num_speculative_tokens":1}' --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. k = 1 → Validation run.
2. Then k = 2, then k = 3, one run each.
3. Record acceptance rate / mean acceptance length from the metrics endpoint.
4. Re-tune `--max-num-seqs` (Approach 4) with the winner; spec decoding uses extra memory per sequence.

---

## 5. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Low acceptance on Thai / code / tool JSON | acceptance metrics per class | fewer draft tokens; drop if no gain |
| Gain disappears at peak batch sizes | TPOT improves only in quiet phase, η flat | keep only if η improves overall |
| Startup error for k > 1 | vLLM log | stay at k = 1; check GitHub issues |
| Output differences vs no spec decoding | smoke tests, accuracy | any accuracy drop is a fail |
| Extra memory → fewer concurrent sequences | cache size in startup log | re-tune `--max-num-seqs`, `--gpu-memory-utilization` |

---

## 6. Measurement sheet

| Run | k | Acceptance len | E (kJ) | SLO-met | η | s_E | TPOT p95 | TTFT p95 | Macro-acc | Decision |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| M0 | off | — | | | | | | | | reference |
| M1 | 1 | | | | | | | | | |
| M2 | 2 | | | | | | | | | |
| M3 | 3 | | | | | | | | | |

---

## 7. Abandon criteria

No k gives an η gain above noise, **or** any streaming / tool-call / accuracy regression.

## 8. Pitch angle

"The model already knows how to guess ahead. We let it, and only pay for the guesses that turn out right." Report acceptance rate and joules per request.

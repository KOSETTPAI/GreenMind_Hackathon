# Approach 9: Mamba / DeltaNet State Cache in BF16

**Rank:** 9 · **Effort:** very low · **Risk:** low–medium

**Goal:** store each sequence's recurrent state in BF16 instead of FP32, to fit more sequences and improve prefix-cache reuse.

**One-line thesis:** 24 of 32 layers keep a fixed-size recurrent state per sequence. Halving its size frees memory and halves the hybrid cache block size, so more prefixes can be reused.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| SLO-met / `s_T` | more sequences fit in memory | ↑ |
| Prefix-cache hit rate (Approach 7) | smaller blocks → finer reuse | ↑ |
| `A` | lower-precision state may drift on long context | ↓ risk |

Concepts: [Recurrent State](../use_ur_brain/79_Recurrent_State.md) · [Hybrid Cache and Kernels](../use_ur_brain/86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [BF16](../use_ur_brain/46_BF16.md)

---

## 2. Evidence

- One community report: BF16 SSM state roughly halved the block size and raised cache hits, with no measurable output change on that workload ([report](https://friendli.ai/models/Twu31/Qwen3.8-27B-AWQ-INT4-MTP-LowLatency)). Single source, different model.

---

## 3. Proposed steps (untested — run on the VM to confirm)

Source: the flag name comes from the community report above; confirm it exists with `vllm serve --help`.

```bash
vllm serve <model> --mamba-ssm-cache-dtype bfloat16 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Check the startup log for the state dtype and the new cache size.
2. Run Validation; compare long-context and RAG accuracy against FP32 state.
3. If combined with Approach 7, compare cache-hit rate.

---

## 4. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Accuracy drop on long context (≤ 32K) | per-class accuracy | revert to default |
| Flag doesn't exist in our version | `--help` | skip |

---

## 5. Abandon criteria

Any accuracy drop beyond noise, or no measurable gain in SLO-met / hit rate.

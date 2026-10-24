# Approach 13: FP8 KV Cache

**Rank:** 13 · **Effort:** low · **Risk:** medium · **Verdict:** probably not

**Goal:** store the attention layers' KV cache in 8 bits to fit more sequences.

**Why it ranks low:**
- Only ~8 of 32 layers use a KV cache; the other 24 keep a fixed-size recurrent state. Shrinking the KV cache saves much less memory than in a plain Transformer.
- The A100 has no FP8 math units, so FP8 is storage only (conversion adds work).
- Accuracy risk on long context (RAG, 32K).

Concepts: [KV Cache](../use_ur_brain/77_KV_Cache.md) · [FP8](../use_ur_brain/48_FP8.md) · [Hybrid Model Architecture](../use_ur_brain/85_Hybrid_Model_Architecture.md)

---

## 1. Proposed steps (untested — run on the VM to confirm)

Source: vLLM `--kv-cache-dtype` flag. Only try after Approaches 2–7 are settled, and never in the same run as a quantization change (see Approach 3 §5).

```bash
vllm serve <model> --kv-cache-dtype fp8 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Check the startup log: the cache size should grow and no layer should fall back.
2. Compare long-context and RAG accuracy, preemptions, and SLO-met.

## 2. Abandon criteria

Any accuracy drop on long-context / RAG, or no change in preemptions.

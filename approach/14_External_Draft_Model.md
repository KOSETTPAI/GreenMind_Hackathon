# Approach 14: External Draft Model for Speculative Decoding

**Rank:** 14 · **Effort:** medium · **Risk:** high · **Verdict:** no

**Goal:** use a separate small open-source model to draft tokens for the main model to verify.

**Why it ranks low:**
- The rules allow it, but the draft model must be **disclosed** and **its energy counts**.
- It needs the same tokenizer as MANGO / Qwen3.5 and extra GPU memory, which reduces concurrent sequences.
- The checkpoint's built-in MTP head (Approach 3) does the same job with no extra model to load.

Concepts: [Speculative Decoding](../use_ur_brain/111_Speculative_Decoding.md) · [Allowed Artifacts](../use_ur_brain/9_Allowed_Artifacts_Dependencies_and_Network_Rules.md)

---

## 1. Proposed steps (untested — run on the VM to confirm)

Only consider if Approach 3 (MTP) is unsupported on our vLLM version. Then pick a small Qwen3.5-family model with a matching tokenizer, pass it via `--speculative-config`, and measure total joules including the draft model.

## 2. Abandon criteria

MTP works, or the draft model's energy cancels the saved decode steps.

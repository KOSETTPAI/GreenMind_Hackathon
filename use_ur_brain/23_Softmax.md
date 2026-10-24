# 23. Softmax

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Logits](22_Logits.md)

## In one sentence
Softmax converts a vector of logits into a probability distribution that is positive and sums to 1.

## Plain-English explanation
Exponentiate every score (so they're all positive and big gaps become bigger), then divide by the total. The token with the highest logit gets the highest probability, but others still get some.

## Technical depth
- `p_i = exp(z_i) / Σ_j exp(z_j)`.
- **Numerically stable form:** subtract the max first: `p_i = exp(z_i − m) / Σ_j exp(z_j − m)`, `m = max(z)`. Prevents overflow — especially important in FP16.
- **Temperature:** `softmax(z / T)`. `T < 1` sharpens (more confident), `T > 1` flattens (more random), `T → 0` → greedy argmax.
- Softmax also appears **inside attention** (over QKᵀ scores). FlashAttention computes it in a streaming "online softmax" way so the full `n × n` score matrix never hits HBM.

## Backend-engineer analogy
Like turning raw scores into normalized weights for weighted random load balancing.

## Why it matters for GreenMind
Understanding softmax explains temperature behavior, why greedy decoding is near-deterministic, and why FlashAttention saves memory traffic.

## Exercise
For logits `[2.0, 1.0, 0.1]`, compute softmax at T = 1 and T = 0.5 by hand. (≈ `[0.66, 0.24, 0.10]` and ≈ `[0.86, 0.12, 0.02]`.)

## Common mistakes
- Assuming temperature changes speed materially.
- Implementing softmax without max-subtraction.

## Related concepts
[Sampling](24_Sampling_Temperature_TopK_TopP.md) · [Attention](18_Attention.md) · [FlashAttention](110_FlashAttention.md) · [Deterministic Settings](10_Deterministic_Settings.md)

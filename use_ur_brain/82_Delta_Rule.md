# 82. Delta Rule

**Stage:** 4 | **Priority:** Should know | **Prerequisites:** [Linear Attention](81_Linear_Attention.md)

## In one sentence
The delta rule updates a memory matrix by correcting only the *error* between what it currently stores for a key and the new value — a targeted overwrite instead of blind accumulation.

## Plain-English explanation
Plain linear attention just adds new information on top of old ("append to the notebook"). The delta rule first asks the memory "what do you currently associate with this key?", compares it to the new value, and writes only the difference. It's like updating a dictionary entry rather than stacking duplicates.

## Technical depth
- Retrieve current prediction: `v̂_t = S_{t−1} k_t`.
- Update with learning rate (write strength) `β_t ∈ (0,1)`:
  `S_t = S_{t−1} + β_t (v_t − S_{t−1} k_t) k_tᵀ = S_{t−1}(I − β_t k_t k_tᵀ) + β_t v_t k_tᵀ`.
- Output: `o_t = S_t q_t`.
- This is one step of online gradient descent on `‖S k_t − v_t‖²` — the memory "learns" key→value associations at test time.
- Comes from classic neural-network learning (Widrow–Hoff, 1960). **DeltaNet** applied it to linear attention; efficient chunked-parallel training algorithms (WY representation) made it practical on GPUs.

## Backend-engineer analogy
An upsert into a key-value store with a fixed-size hash table: update the existing slot toward the new value rather than inserting a duplicate.

## Why it matters for GreenMind
Explains how Gated DeltaNet keeps a compact memory with better recall than plain linear attention — relevant for long-context accuracy and why its kernels are more complex than simple sums.

## Common mistakes
- Confusing the delta rule (state update) with "delta" in Mamba (Δ step size). Different concepts.

## Related concepts
[Gating](83_Gating.md) · [Gated DeltaNet](84_Gated_DeltaNet.md) · [Linear Attention](81_Linear_Attention.md)

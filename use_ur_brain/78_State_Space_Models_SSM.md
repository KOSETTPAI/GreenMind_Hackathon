# 78. State-Space Models (SSM)

**Stage:** 4 — Hybrid architecture | **Priority:** Must know (high level) | **Prerequisites:** [Attention](18_Attention.md), [KV Cache](77_KV_Cache.md)

## In one sentence
A state-space model processes a sequence by updating a fixed-size hidden state token by token, instead of letting every token look back at every previous token like attention does.

## Plain-English explanation
Attention keeps a full transcript of the conversation and rereads it for every new word. An SSM keeps a running summary — a fixed-size notebook — and updates it as each token arrives. Memory and per-token cost stay constant no matter how long the sequence gets. The trade-off: a summary can forget details that a full transcript keeps.

## Technical depth
- Continuous form: `h'(t) = A h(t) + B x(t)`, `y(t) = C h(t)`.
- Discretized (step Δ): `h_t = Ā h_{t−1} + B̄ x_t`, `y_t = C h_t`.
- **Inference:** recurrent mode — `O(1)` time and memory per token in decode.
- **Training / prefill:** can be computed in parallel (convolution or parallel scan) — `O(n)` or `O(n log n)` over the sequence.
- Classic SSMs (S4) have fixed A, B, C. **Mamba** makes them input-dependent ("selective").
- Many SSM layers also include a short causal **convolution** over the last few tokens, which needs its own small per-sequence "conv state."

## Backend-engineer analogy
Attention = keep the full event log and query it each time. SSM = maintain an incrementally updated aggregate (like a running materialized view) — O(1) update, but you can't recover arbitrary old events.

## Why it matters for GreenMind
MANGO's non-attention layers are SSM-like/recurrent. Their per-sequence state is fixed-size, which changes memory planning, prefix-caching behavior, and kernel requirements.

## Common mistakes
- Thinking SSMs are "attention without cost" — quality on exact recall and kernel efficiency are real trade-offs.

## Related concepts
[Recurrent State](79_Recurrent_State.md) · [Mamba](80_Mamba_Selective_State_Update.md) · [Linear Attention](81_Linear_Attention.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md)

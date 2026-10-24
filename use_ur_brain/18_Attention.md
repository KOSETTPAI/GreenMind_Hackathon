# 18. Attention (Self-Attention)

**Stage:** 1 / 4 | **Priority:** Must know | **Prerequisites:** [Embeddings and Hidden States](17_Embeddings_and_Hidden_States.md)

## In one sentence
Attention lets each token pull information from other (earlier) tokens by comparing a query against keys and mixing the corresponding values.

## Plain-English explanation
In "The cat sat on the mat because **it** was tired," the model must link "it" to "cat." Attention does this: each token asks a question (query), every earlier token offers a label (key) and content (value). Tokens whose keys match the query get higher weight, and their values are blended into the current token's representation.

## Technical depth
- Projections: `Q = XW_Q`, `K = XW_K`, `V = XW_V`.
- `Attention(Q,K,V) = softmax(QKᵀ / √d_k + mask) V`, with a **causal mask** so tokens can't see the future.
- **Multi-head:** several attention heads in parallel. **GQA** (grouped-query attention): many query heads share fewer K/V heads → smaller KV cache.
- **Cost:** prefill attention compute scales ~`O(n²)` in sequence length; in decode, each new token attends to all `n` cached keys → `O(n)` per step, and the **KV cache grows linearly** with context.
- Standard Transformer = stack of (attention + FFN) blocks. A hybrid model like MANGO replaces many attention layers with linear/recurrent layers (Mamba / Gated DeltaNet).

## Backend-engineer analogy
Attention is like a fuzzy join/lookup: the query is matched against all keys with a soft score, and the result is a weighted average of matching values instead of a single row.

## Why it matters for GreenMind
Attention layers are where KV cache memory grows with context length, and where FlashAttention-style kernels help. In a hybrid model only *some* layers are attention — so attention-specific optimizations only help those layers.

## Common mistakes
- Assuming every layer in MANGO is attention.
- Assuming attention is the dominant cost at short contexts (the FFN often dominates).

## Related concepts
[KV Cache](77_KV_Cache.md) · [Linear Attention](81_Linear_Attention.md) · [FlashAttention](110_FlashAttention.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md) · [Softmax](23_Softmax.md)

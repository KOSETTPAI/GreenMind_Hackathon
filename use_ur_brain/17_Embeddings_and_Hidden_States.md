# 17. Embeddings and Hidden States

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Token IDs and Vocabulary](16_Token_IDs_and_Vocabulary.md)

## In one sentence
An embedding turns a token ID into a vector of numbers, and hidden states are those vectors as they get transformed layer by layer through the model.

## Plain-English explanation
A token ID like `4521` means nothing numerically. The embedding layer looks up row 4521 in a big table and returns a vector (e.g., 4096 numbers). That vector then flows through dozens of layers; each layer updates it using context from other tokens. The vector at each point is a **hidden state**. The final hidden state is converted into scores for the next token.

## Technical depth
- Embedding lookup: `h_0 = E[token_id]`, `E ∈ R^{vocab × d_model}`.
- Each layer: `h_{l+1} = h_l + Block_l(Norm(h_l))` (see [Residual Connections](21_Residual_Connections.md)).
- Hidden size `d_model` (from `config.json` as `hidden_size`) determines matrix sizes and activation memory: activations ≈ `batch_tokens × d_model × bytes` per layer buffer.
- In prefill, hidden states exist for every prompt token at once (a matrix); in decode, one new vector per sequence per step.

## Backend-engineer analogy
The hidden state is like a request context object passed through a middleware pipeline — each middleware (layer) enriches it before the final handler (LM head) produces a response.

## Why it matters for GreenMind
Activation memory scales with the number of tokens processed per step — that's why [Batch Token Budget](93_Batch_Token_Budget.md) and [Chunked Prefill](95_Chunked_Prefill.md) affect memory and latency.

## Common mistakes
- Confusing embeddings (per-token input vectors) with the model's state/cache (per-request memory of the past).

## Related concepts
[Attention](18_Attention.md) · [Feed-Forward Network](19_Feed_Forward_Network_MLP.md) · [Normalization](20_Normalization.md) · [Logits](22_Logits.md)

# 26. Context Window (Context Length)

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Autoregressive Generation](25_Autoregressive_Generation.md)

## In one sentence
The context window is the maximum number of tokens (prompt + generated output) a model/configuration can handle in one sequence.

## Plain-English explanation
The model can only "see" a limited number of tokens at once. If prompt + answer exceeds that, the request is rejected or truncated. Longer contexts cost more: more prefill work, and for attention layers a bigger KV cache.

## Technical depth
- Model max: `max_position_embeddings` in `config.json`. Serving max: vLLM `--max-model-len`, which can be set **lower** than the model max to save memory.
- vLLM checks at startup that at least one max-length sequence fits in the cache; a huge `max-model-len` can fail to start or shrink concurrency.
- Cost scaling:
  - Attention layers: prefill compute ~`O(n²)`, KV cache memory `O(n)` per sequence, decode per-step `O(n)`.
  - Mamba / Gated DeltaNet layers: state size **constant** per sequence; prefill `O(n)`.
  - A hybrid model sits between: fewer attention layers → much smaller cache growth.
- The grader includes **long-context** requests, so `max-model-len` must cover them.

## Backend-engineer analogy
Like a maximum request body size plus a per-session memory cost that grows with session history.

## Why it matters for GreenMind
Setting `--max-model-len` correctly balances "can serve the longest grader request" against "maximum concurrency." Too small = failed requests; too large = wasted memory headroom.

## Common mistakes
- Setting `max-model-len` smaller than the grader's longest request (silent failures/errors).
- Assuming cost scales identically for all layers in a hybrid model.

## Related concepts
[KV Cache](77_KV_Cache.md) · [Recurrent State](79_Recurrent_State.md) · [Prompt and Completion Tokens](27_Prompt_and_Completion_Tokens.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md)

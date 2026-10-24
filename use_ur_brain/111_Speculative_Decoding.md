# 111. Speculative Decoding

**Stage:** 8 | **Priority:** Advanced | **Prerequisites:** [Decode](54_Decode.md), [Sampling](24_Sampling_Temperature_TopK_TopP.md)

## In one sentence
Speculative decoding uses a cheap draft mechanism to propose several tokens, then the target model verifies them all in one forward pass, accepting the correct prefix — producing multiple tokens per expensive step without changing the output distribution.

## Plain-English explanation
Decode is slow because each target-model step yields just one token, and the GPU is underused at small batch. A small "draft" guesses the next k tokens; the big model checks all k at once (like a mini-prefill). If the first 3 guesses were right, you got 3–4 tokens for roughly the price of one big step.

## Technical depth
- Expected tokens per target step with acceptance rate α and k drafts: `(1 − α^{k+1}) / (1 − α)`.
- **Draft sources:** small draft model (same tokenizer), n-gram/prompt lookup (great for RAG/code where output copies input), EAGLE-style heads, MTP heads (see [MTP](112_MTP_Multi_Token_Prediction.md)).
- vLLM: `--speculative-config '{"method": ..., "num_speculative_tokens": k, ...}'` (format varies by version).
- **Wins:** small batch, memory-bound decode, high acceptance.
- **Loses:** large batch (GPU already compute-saturated — verification of rejected tokens is waste), low acceptance, draft overhead, extra memory.
- **Hybrid models:** rejected tokens require rolling back recurrent state — engine support for speculative decoding with Mamba/DeltaNet layers is limited/version-dependent.
- Lossless only with correct rejection sampling (greedy: exact match).

## Backend-engineer analogy
Optimistic concurrency / branch prediction: guess ahead, validate in bulk, roll back on miss.

## Why it matters for GreenMind
Roadmap experiment #7: possible TPOT and energy gains at low load, but may hurt at peak load. Must verify model + engine support and measure acceptance rate.

## Common mistakes
- Enabling it at high concurrency and getting slower.
- Ignoring hybrid-state rollback support.

## Related concepts
[MTP](112_MTP_Multi_Token_Prediction.md) · [TPOT](63_TPOT.md) · [Recurrent State](79_Recurrent_State.md) · [Batching](55_Batching.md)

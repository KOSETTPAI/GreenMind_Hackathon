# 22. Logits

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Token IDs and Vocabulary](16_Token_IDs_and_Vocabulary.md)

## In one sentence
Logits are the model's raw, unnormalized scores for every token in the vocabulary as the possible next token.

## Plain-English explanation
At the end of each forward pass, the model outputs one number per vocabulary entry — ~150k numbers. Higher means "more likely next." These raw scores can be any real value (negative, huge), so they're converted to probabilities with [Softmax](23_Softmax.md) before sampling.

## Technical depth
- `logits = h_final · W_lm_headᵀ` → shape `[batch, vocab_size]`.
- Only the **last position** of each sequence needs logits during generation; computing logits for every prompt position in prefill is wasteful (engines skip it unless `prompt_logprobs` is requested).
- **Logprobs** = log-softmax of logits; APIs can return them (`logprobs: true`).
- Logit processors modify logits before sampling: repetition penalty, banned tokens, grammar/JSON-schema constraints (structured output), tool-call constraints.

## Backend-engineer analogy
A ranked candidate list with raw relevance scores, before normalization and selection — like search scores before you pick the top result.

## Why it matters for GreenMind
Comparing logprobs between baseline and a quantized model is a sensitive quality check. Structured-output/guided decoding works by masking logits — which costs CPU/GPU time per step.

## Common mistakes
- Confusing logits with probabilities.
- Requesting logprobs in benchmarks when the grader doesn't (adds overhead).

## Related concepts
[Softmax](23_Softmax.md) · [Sampling](24_Sampling_Temperature_TopK_TopP.md) · [Tool Calling](73_Tool_Calling.md) · [Quantization](102_Quantization.md)

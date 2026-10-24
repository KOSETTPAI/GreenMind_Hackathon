# 24. Sampling (Temperature, Top-k, Top-p, Seed)

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Softmax](23_Softmax.md)

## In one sentence
Sampling (decoding strategy) is the rule that picks the next token from the probability distribution.

## Plain-English explanation
Given probabilities for every token, you could always take the top one (**greedy**) or roll weighted dice (**sampling**). Knobs control how adventurous the dice are:
- **Temperature** — reshapes the distribution (low = safe, high = creative).
- **Top-k** — only consider the k most likely tokens.
- **Top-p (nucleus)** — only consider the smallest set of tokens whose probabilities sum to ≥ p.
- **Seed** — fixes the random number generator for repeatability.
- Others: min-p, repetition/presence/frequency penalties, stop sequences, max_tokens.

## Technical depth
- Order in typical engines: logit processors (penalties) → temperature → top-k/top-p/min-p filtering → renormalize → sample.
- Sampling itself is cheap relative to the forward pass, but top-p sorting over a 150k vocab for a large batch is not free; engines use optimized GPU sampling kernels.
- Sampling choices change **output length** (e.g., reasoning models may ramble more at high temperature), which changes latency and energy.
- Models often ship recommended settings in `generation_config.json`; vLLM may apply them as defaults when the request doesn't specify values.

## Backend-engineer analogy
A selection policy over a ranked candidate list — like choosing between "always pick best" vs "weighted random among top candidates" in a recommender.

## Why it matters for GreenMind
The grader's requests specify (or rely on defaults for) sampling. Changing them can change accuracy and output length — and may violate rules. Know where defaults come from (request vs server vs `generation_config.json`).

## Common mistakes
- Changing server-side sampling defaults to make outputs shorter.
- Comparing two configs where one silently uses different default sampling.

## Related concepts
[Deterministic Settings](10_Deterministic_Settings.md) · [Logits](22_Logits.md) · [Autoregressive Generation](25_Autoregressive_Generation.md) · [Speculative Decoding](111_Speculative_Decoding.md)

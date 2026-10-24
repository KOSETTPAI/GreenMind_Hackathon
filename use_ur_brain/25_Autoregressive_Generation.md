# 25. Autoregressive Generation

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Sampling](24_Sampling_Temperature_TopK_TopP.md)

## In one sentence
The model generates text one token at a time: predict the next token, append it, and repeat — each new token requires another forward pass.

## Plain-English explanation
An LLM can't write a whole paragraph in one shot. It writes word-piece by word-piece, and each piece depends on all the previous ones. So a 500-token answer needs ~500 sequential model steps. That's why output length is the single biggest driver of latency and energy for long responses.

## Technical depth
```
state = prefill(prompt_tokens)          # one big parallel pass
while not stop:
    logits = model.step(last_token, state)  # one decode step
    tok = sample(logits)
    state.update(tok); emit(tok)
    stop = tok in eos or len >= max_tokens or stop_sequence_hit
```
- Steps are **sequential** within a request — you can't parallelize decode steps of one sequence (except via speculative decoding).
- Parallelism comes from **batching many requests** in each step.
- Cost of a request ≈ prefill cost + `n_output × per-step decode cost` (per-step cost depends on batch size and context/state).
- State (KV cache or recurrent state) avoids recomputing the past each step.

## Backend-engineer analogy
A stateful streaming loop, not a single stateless query — like a long-lived session that produces one chunk per tick and keeps session state between ticks.

## Why it matters for GreenMind
Explains why TPOT exists, why decode dominates long outputs, why batching is the main throughput lever, and why runaway generations (missing stop tokens) waste energy.

## Common mistakes
- Thinking a request's cost is fixed regardless of output length.
- Comparing runs with different output lengths.

## Related concepts
[Prefill](53_Prefill.md) · [Decode](54_Decode.md) · [KV Cache](77_KV_Cache.md) · [Recurrent State](79_Recurrent_State.md) · [Speculative Decoding](111_Speculative_Decoding.md)

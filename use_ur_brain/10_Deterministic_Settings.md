# 10. Deterministic Settings

**Stage:** 0 | **Priority:** Must know | **Prerequisites:** [Sampling](24_Sampling_Temperature_TopK_TopP.md) (can read later)

## In one sentence
Deterministic settings (seed, temperature, top-p/top-k, max tokens, stop conditions) control whether the same request produces the same output, which affects both repeatability and the cost of each run.

## Plain-English explanation
LLMs pick each next token from a probability distribution. With randomness on, two runs give different answers of different lengths — which changes latency, energy, and accuracy. To compare two server configurations fairly, you want outputs to be as repeatable as possible, and you must **not** change sampling settings unless the rules allow it.

## Technical depth
- **Greedy decoding** (`temperature=0`) picks the argmax token — closest to deterministic.
- Even with greedy decoding, GPU results can differ slightly due to batch composition, non-associative floating-point reduction order, and different kernels. Different batching → tiny numeric differences → occasionally a different token → divergent text.
- Quantization or a different engine also changes numerics, so exact-match outputs vs baseline are not guaranteed.
- `max_tokens` and stop sequences directly cap output length and therefore decode cost.

## Backend-engineer analogy
Like making tests deterministic: fixed seeds, frozen clocks, stable ordering. Flaky outputs make A/B comparisons noisy.

## Why it matters for GreenMind
The grader likely fixes sampling parameters in requests. Your server must honor them. Changing default sampling to shorten outputs could be considered gaming the evaluator and could hurt accuracy.

## Common mistakes
- Assuming temperature materially changes speed (it mostly changes *which* tokens, and thus output length).
- Overriding request sampling parameters server-side.
- Expecting bit-identical outputs across batch sizes.

## Related concepts
[Sampling](24_Sampling_Temperature_TopK_TopP.md) · [Reproducibility](87_Reproducibility.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md) · [Accuracy](118_Accuracy.md)

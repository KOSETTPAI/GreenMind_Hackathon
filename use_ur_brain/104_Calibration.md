# 104. Calibration

**Stage:** 7 | **Priority:** Should know | **Prerequisites:** [Quantization](102_Quantization.md)

## In one sentence
Calibration runs representative sample inputs through the model to choose quantization scales or transformations that minimize error on realistic data.

## Plain-English explanation
To compress well, you need to know which values matter. Calibration feeds a few hundred example prompts through the model, observes activation ranges and which weights are most influential, and picks scales accordingly. If the calibration data doesn't look like your real traffic (e.g., English-only when you serve Thai), the quantized model can do poorly on what you actually care about.

## Technical depth
- Used by AWQ, GPTQ, SmoothQuant, static FP8/INT8 activation scales.
- Typical size: 128–512 samples of 512–2048 tokens.
- Data should reflect: languages (Thai!), domains (code, reasoning), formats (chat template applied, tool calls), and context lengths.
- Tools: `llm-compressor` (vLLM project), AutoAWQ, GPTQModel.
- **Dynamic** quantization (scales computed at runtime per token) needs no calibration for activations, at some runtime cost.
- Calibrating on the evaluation set itself = overfitting to the test; avoid if the rules forbid it.

## Backend-engineer analogy
Choosing compression dictionaries or index statistics from a representative sample of production data — bad samples, bad plans.

## Why it matters for GreenMind
If you create your own quantized artifact (and it's allowed), calibration data choice directly affects per-category accuracy retention.

## Common mistakes
- English-only, short-context calibration for a multilingual, long-context workload.
- Calibrating without the chat template.

## Related concepts
[AWQ](105_AWQ.md) · [Quantization](102_Quantization.md) · [Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md) · [Workload Mix](6_Workload_Mix.md)

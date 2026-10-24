# 102. Quantization

**Stage:** 7 — Precision & model artifacts | **Priority:** Should know | **Prerequisites:** [Numerical Precision Basics](44_Numerical_Precision_Basics.md), [INT8 and INT4](49_INT8_and_INT4.md), [Baseline](4_Baseline.md)

## In one sentence
Quantization represents weights and/or activations (and sometimes cache) with fewer bits to reduce memory and data movement — and potentially compute — at some risk to accuracy.

## Plain-English explanation
Compressing an 18 GB BF16 model to ~5 GB INT4 means each decode step reads ~4× fewer bytes, freeing VRAM for more concurrent requests. But compression is lossy: math, code, Thai, tool-call JSON, and long-context recall can degrade. And if there's no efficient kernel for your format + architecture + GPU, the "smaller" model can be slower.

## Technical depth
- **What to quantize:** weights only (W8A16, W4A16), weights + activations (W8A8), KV cache (FP8 KV).
- **Methods:** round-to-nearest (RTN), GPTQ (second-order error compensation), AWQ (activation-aware scaling), SmoothQuant (move activation outliers into weights for W8A8), FP8 per-channel/block.
- **Formats in vLLM:** compressed-tensors, AWQ, GPTQ, FP8, bitsandbytes, GGUF, etc. Kernel choice on A100: Marlin/Machete-style kernels for W4A16/W8A16; INT8 W8A8 via CUTLASS.
- **Expected effects:** decode speedup when memory-bound; little/no prefill speedup (compute-bound, plus dequant overhead); more cache room → bigger batches.
- **Hybrid caveat:** recurrent-layer projections may or may not be covered by the quant method/kernels; some layers are typically left in BF16 (embeddings, LM head, norms, gates).

## Backend-engineer analogy
Lossy compression of a hot dataset — less I/O and memory, but you must verify that query results are still correct.

## Why it matters for GreenMind
Roadmap experiment #6, after low-risk serving tuning. Potentially large energy and throughput gains; the main risk is the accuracy-retention gate.

## Common mistakes
- Judging quality by aggregate accuracy only (hides Thai/code/tool-call regressions).
- Expecting "4-bit = ¼ VRAM, 4× speed."
- Using an artifact the rules don't permit.

## Related concepts
[Weight-Only Quantization](103_Weight_Only_Quantization_W4A16.md) · [AWQ](105_AWQ.md) · [Calibration](104_Calibration.md) · [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md) · [Allowed Artifacts](9_Allowed_Artifacts_Dependencies_and_Network_Rules.md)

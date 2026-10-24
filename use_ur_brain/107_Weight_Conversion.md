# 107. Weight Conversion

**Stage:** 7 | **Priority:** Should know | **Prerequisites:** [Checkpoint](14_Checkpoint.md), [Quantization](102_Quantization.md)

## In one sentence
Weight conversion transforms a checkpoint into a different layout, format, or precision that an engine supports — without training — e.g., BF16 → FP8, HF → TensorRT-LLM engine, HF → GGUF.

## Plain-English explanation
Engines have preferred formats. TensorRT-LLM builds an optimized "engine" from a checkpoint; llama.cpp needs GGUF; some quantized kernels need repacked weight layouts. Conversion is mechanical (no gradient updates), but it can still change numerics and outputs, and the rules may restrict it.

## Technical depth
- Examples: dtype cast (BF16 → FP16), quantization export (llm-compressor → compressed-tensors), engine build (`trtllm-build`), GGUF conversion (`convert_hf_to_gguf.py`), weight repacking for Marlin (often done at load time by vLLM).
- Risks: unsupported layer types in converters (hybrid Mamba/DeltaNet layers are a common gap), silently dropped layers/params, tokenizer/template mismatch, long build times.
- Always verify: output parity on a fixed prompt set vs BF16 baseline, hashes of converted artifacts, conversion script + version recorded.

## Backend-engineer analogy
Data migration / ETL into a new storage format — mechanical, but needs validation that nothing was lost or transformed incorrectly.

## Why it matters for GreenMind
Engine alternatives and quantization often require conversion. "Distinct from training" doesn't mean "allowed" — check the rules first.

## Common mistakes
- Assuming a converter supports the hybrid architecture because it supports Qwen Transformers.
- Not validating outputs after conversion.

## Related concepts
[Allowed Artifacts](9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [TensorRT-LLM](115_TensorRT_LLM.md) · [llama.cpp](116_llama_cpp.md) · [Reproducibility](87_Reproducibility.md)

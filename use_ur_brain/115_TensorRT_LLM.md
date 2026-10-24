# 115. TensorRT-LLM

**Stage:** 8 | **Priority:** Advanced (alternative engine) | **Prerequisites:** [vLLM](113_vLLM.md), [Weight Conversion](107_Weight_Conversion.md)

## In one sentence
TensorRT-LLM is NVIDIA's optimized LLM inference library, with highly tuned kernels, in-flight batching, and quantization support — strong performance, but with conversion/build effort and model-support risk.

## Plain-English explanation
TensorRT-LLM squeezes maximum performance out of NVIDIA GPUs using hand-optimized kernels and graph-level optimization. Historically it required converting the checkpoint and building a GPU-specific "engine" before serving; newer versions also offer a PyTorch-based workflow. It's often among the fastest on NVIDIA hardware — when the model is supported.

## Technical depth
- Serving: `trtllm-serve` (OpenAI-compatible) or Triton Inference Server with the TensorRT-LLM backend.
- Features: in-flight (continuous) batching, paged KV cache, KV cache reuse, chunked context, quantization (INT8/INT4 weight-only, SmoothQuant, AWQ, FP8 on Hopper+), speculative decoding.
- **Key risks for MANGO:** support for this exact hybrid Mamba/Gated-DeltaNet architecture; build time; conversion correctness; tool-call/streaming API parity; A100 (sm_80) feature coverage (no FP8 compute).

## Backend-engineer analogy
An ahead-of-time compiled, vendor-optimized runtime: fastest when it supports your stack, painful when it doesn't.

## Why it matters for GreenMind
Potential upside on raw speed and energy, but highest migration effort. Only attempt in a separate branch after preserving the best vLLM configuration.

## Common mistakes
- Starting a long engine build before confirming architecture support.
- Comparing a TRT-LLM build against an untuned vLLM baseline.

## Related concepts
[Engine Migration Gate](117_Engine_Migration_Gate.md) · [Weight Conversion](107_Weight_Conversion.md) · [vLLM](113_vLLM.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md)

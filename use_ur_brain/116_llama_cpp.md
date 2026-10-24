# 116. llama.cpp

**Stage:** 8 | **Priority:** Advanced (alternative engine) | **Prerequisites:** [Quantization](102_Quantization.md), [Weight Conversion](107_Weight_Conversion.md)

## In one sentence
llama.cpp is a C/C++ inference engine with a broad quantized-model ecosystem (GGUF format) that runs on CPUs and GPUs, and includes an OpenAI-compatible `llama-server`.

## Plain-English explanation
llama.cpp shines at running quantized models on modest hardware (laptops, CPUs, consumer GPUs) with many quantization formats (Q4_K_M, Q8_0, etc.). It's lightweight and portable. For high-concurrency data-center serving on an A100, its batching and throughput are generally less optimized than vLLM/SGLang/TensorRT-LLM.

## Technical depth
- Requires GGUF conversion (`convert_hf_to_gguf.py`) + optional quantization (`llama-quantize`).
- Server: `llama-server -m model.gguf --n-gpu-layers 999 --parallel N --ctx-size ...` (continuous batching with parallel slots).
- CUDA backend supports A100; many quant types use custom dequant kernels.
- Hybrid architecture support (Mamba/Gated DeltaNet) depends on whether llama.cpp has implemented that specific model family — must be verified.
- API differences (tool calls, streaming, usage) vs vLLM must be tested.

## Backend-engineer analogy
SQLite vs a distributed database — fantastic, portable, efficient for single-user/local use; not the default for high-concurrency serving.

## Why it matters for GreenMind
The roadmap lists it as an alternative; compatibility with the exact hybrid model, endpoint semantics, and A100 throughput efficiency must be established first. Likely lower priority.

## Common mistakes
- Comparing single-stream latency (where it may look good) instead of throughput under the grader's concurrency.

## Related concepts
[Engine Migration Gate](117_Engine_Migration_Gate.md) · [Weight Conversion](107_Weight_Conversion.md) · [INT8 and INT4](49_INT8_and_INT4.md) · [vLLM](113_vLLM.md)

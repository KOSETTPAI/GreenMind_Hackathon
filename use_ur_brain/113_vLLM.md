# 113. vLLM

**Stage:** 3 / 8 | **Priority:** Must know | **Prerequisites:** [Continuous Batching](56_Continuous_Batching.md), [KV Cache](77_KV_Cache.md)

## In one sentence
vLLM is an open-source high-throughput LLM serving engine (PagedAttention, continuous batching, OpenAI-compatible server) and the hackathon's baseline engine.

## Plain-English explanation
vLLM loads the model, manages GPU memory for caches, batches requests continuously, picks optimized kernels, and exposes an OpenAI-compatible HTTP API. Most of your low-risk tuning is vLLM flags.

## Technical depth
**Launch example (illustrative — check flags for your version):**
```bash
vllm serve /models/MANGO1.5-Qwen3.5-9B \
  --dtype bfloat16 --max-model-len 32768 \
  --gpu-memory-utilization 0.90 \
  --max-num-seqs 128 --max-num-batched-tokens 8192 \
  --enable-prefix-caching \
  --enable-auto-tool-choice --tool-call-parser <parser> \
  --served-model-name mango
```
**Key features:** PagedAttention KV management; hybrid cache manager for Mamba/linear-attention models (newer versions); chunked prefill; automatic prefix caching; CUDA graphs + `torch.compile`; quantization (AWQ, GPTQ, FP8, compressed-tensors, Marlin kernels); speculative decoding; tool-call parsers; Prometheus `/metrics`; `vllm bench serve` benchmarking.

**Watch:** startup logs (backends, cache blocks, max concurrency, disabled features), `/metrics` (running, waiting, cache usage, preemptions, TTFT/TPOT histograms).

## Backend-engineer analogy
The app server + connection pool + query planner for LLMs, all in one.

## Why it matters for GreenMind
Official baseline; best starting point if it supports MANGO properly. Defaults and flags change between releases — always use docs for your installed version.

## Common mistakes
- Following docs/blogs for a different vLLM version.
- Not reading startup logs.

## Related concepts
[SGLang](114_SGLang.md) · [TensorRT-LLM](115_TensorRT_LLM.md) · [Engine Migration Gate](117_Engine_Migration_Gate.md) · [Batch Token Budget](93_Batch_Token_Budget.md)

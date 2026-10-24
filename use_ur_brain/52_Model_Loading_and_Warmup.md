# 52. Model Loading and Warmup

**Stage:** 3 — Inference serving | **Priority:** Must know | **Prerequisites:** [Checkpoint](14_Checkpoint.md), [VRAM and HBM](33_VRAM_and_HBM.md)

## In one sentence
Model loading reads weights into GPU memory and initializes the engine; warmup runs initial work (profiling, compilation, CUDA graph capture, dummy requests) so steady-state requests aren't slowed by one-time costs.

## Plain-English explanation
Starting vLLM is not instant. It:
1. Reads config and tokenizer.
2. Loads ~18 GB of weights from disk to GPU.
3. Profiles peak activation memory with a dummy forward pass.
4. Allocates the KV cache / state pool from remaining memory.
5. Optionally runs `torch.compile` and captures CUDA graphs for many batch sizes.
6. Starts the HTTP server.

The first real requests may still be slower (cold caches, lazy initialization, JIT-compiled Triton kernels). Sending a few warmup requests before measurement avoids polluting results.

## Technical depth
- **Cold start vs steady state:** report them separately.
- Startup-heavy options (compilation, many CUDA graph sizes) improve steady-state speed but add startup time and memory.
- Triton kernels (used heavily by Mamba/Gated-DeltaNet layers) may JIT-compile on first use per shape → first-request latency spikes. Warmup with varied prompt lengths.
- Check the readiness endpoint (`/health`, `/v1/models`) before starting the load test.

## Backend-engineer analogy
JVM warmup / JIT compilation, cache priming, connection-pool initialization. You don't load-test a service in its first 10 seconds after boot.

## Why it matters for GreenMind
Whether warmup and loading are inside the grader's measurement window decides whether startup-heavy optimizations are free or costly. There may also be a startup time limit.

## Common mistakes
- Omitting warmup and blaming the server for first-request spikes.
- Including warmup in one run and not another.

## Related concepts
[Measurement Window](7_Measurement_Window.md) · [CUDA Graphs and Compilation](100_CUDA_Graphs_and_Compilation.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md) · [Smoke Testing](88_Smoke_Testing.md)

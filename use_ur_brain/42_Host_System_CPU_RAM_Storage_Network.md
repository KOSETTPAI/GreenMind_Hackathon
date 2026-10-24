# 42. Host System (CPU, RAM, Storage, Network)

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [GPU Fundamentals](29_GPU_Fundamentals.md)

## In one sentence
The host system — CPU, system RAM, disk, and network — handles the HTTP API, tokenization, scheduling, kernel launches, and model loading, and can bottleneck the GPU.

## Plain-English explanation
The GPU does the math, but the CPU does everything else: accepting HTTP requests, parsing JSON, rendering chat templates, tokenizing, running the scheduler, launching kernels, detokenizing, and streaming responses. If the CPU falls behind, the GPU waits. Disk speed matters for startup (loading 18 GB of weights). Network (between grader and server) adds latency to TTFT measurements.

## Technical depth
- **CPU hot spots:** tokenization of long prompts, chat-template rendering, structured-output/tool-call grammar masks, per-step scheduling in Python, detokenization + SSE serialization for many streams.
- vLLM separates the API server process from the engine core process, and newer versions support multiple API server processes (`--api-server-count`) to parallelize HTTP/tokenization work.
- **PCIe:** host ↔ GPU transfers (A100 PCIe Gen4 ~32 GB/s each way). Avoid CPU offload of weights/cache during serving unless necessary.
- **Storage:** load time = weights / disk throughput; NVMe vs network storage can mean seconds vs minutes.
- **System RAM:** needed for loading, CPU swap space for preempted sequences (if configured).

## Backend-engineer analogy
The classic "app server is the bottleneck, not the database" scenario: your expensive backend sits idle because the front tier can't parse and dispatch requests fast enough.

## Why it matters for GreenMind
A low-GPU-utilization symptom often points here. Check CPU usage per process, GPU idle gaps, and queue delays before blaming the GPU.

## Common mistakes
- Looking only at GPU metrics.
- Adding CPU worker processes without measuring (extra processes add overhead too).

## Related concepts
[CPU and API Worker Capacity](99_CPU_and_API_Worker_Capacity.md) · [Launch Overhead](41_Launch_Overhead.md) · [Model Loading and Warmup](52_Model_Loading_and_Warmup.md) · [Energy Boundary](8_Energy_Boundary.md)

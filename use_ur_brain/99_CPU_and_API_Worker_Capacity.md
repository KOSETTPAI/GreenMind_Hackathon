# 99. CPU and API Worker Capacity

**Stage:** 6 | **Priority:** Should know | **Prerequisites:** [Host System](42_Host_System_CPU_RAM_Storage_Network.md)

## In one sentence
CPU/API worker capacity is the host-side ability to accept HTTP requests, render templates, tokenize, schedule, detokenize, and stream — if it saturates, the GPU starves.

## Plain-English explanation
At high request rates with long prompts and many streams, the Python API server and engine loop can max out a CPU core. Symptoms: GPU utilization drops, queue grows, yet GPU metrics look "fine." Adding API server processes or reducing per-request CPU work can unlock GPU throughput.

## Technical depth
- vLLM process layout: API server process(es) ↔ engine core process (scheduler + model runner) ↔ GPU worker(s). The engine core loop runs on one main thread — scheduling overhead scales with running sequences.
- Options (version-dependent — check docs): multiple API server processes (`--api-server-count`), async scheduling options, disabling expensive per-request logging (`--disable-log-requests`), avoiding unneeded features (logprobs, guided decoding when not needed).
- Diagnose: `top -H` per process; `py-spy top --pid <engine_pid>`; Nsight timeline gaps between GPU steps.
- vLLM's optimization docs discuss CPU-side considerations; ensure enough CPU cores are allocated to the container.

## Backend-engineer analogy
Scaling the stateless front tier (more API workers) when the backend is underutilized because request parsing is the bottleneck.

## Why it matters for GreenMind
Roadmap experiment #5. Low GPU utilization under heavy load is a sign; fixing it raises throughput without touching the model.

## Common mistakes
- Adding processes without measuring — extra processes add IPC overhead.
- Container CPU limits too low.

## Related concepts
[Launch Overhead](41_Launch_Overhead.md) · [Tokens and Tokenizer](15_Tokens_and_Tokenizer.md) · [Profiling](92_Profiling.md) · [Bottleneck Diagnosis](126_Bottleneck_Diagnosis.md)

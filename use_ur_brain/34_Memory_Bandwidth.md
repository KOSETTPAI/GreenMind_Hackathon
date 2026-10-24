# 34. Memory Bandwidth

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [VRAM and HBM](33_VRAM_and_HBM.md)

## In one sentence
Memory bandwidth is how many bytes per second can move between VRAM and the compute units — for the A100 40 GB about 1.555 TB/s.

## Plain-English explanation
A model can fit in memory and still be slow, because every decode step has to stream all the weights from memory to the compute units. If moving the data takes longer than doing the math, bandwidth is the bottleneck. This is the normal situation for LLM decode at small batch sizes.

## Technical depth
**Decode speed-of-light estimate (batch 1, BF16 9B):**
`time_per_step ≥ bytes_read / bandwidth = 18 GB / 1.555 TB/s ≈ 11.6 ms` → max ≈ 86 tokens/s for one sequence.
Real systems hit maybe 60–80% of peak bandwidth.

**Why batching helps:** with batch B, weights are read once and used for B tokens — per-token weight traffic drops by B×, until compute becomes the limit.

**Why quantization helps decode:** 4-bit weights ≈ 4.5–5 GB → per-step weight read ~3.5–4× smaller → faster decode, if the kernel is efficient.

Cache/state reads also consume bandwidth: attention layers read the KV cache every step (grows with context); recurrent layers read/write a fixed-size state.

## Backend-engineer analogy
Like disk I/O throughput for a full-table scan: a faster CPU won't help if you're scanning 18 GB per query. Batching = answering many queries in one scan; quantization = compressing the table.

## Why it matters for GreenMind
Bandwidth explains decode TPOT, why batching raises throughput, and why weight-only quantization often speeds decode. It also matters for energy: moving bytes from HBM costs significant power.

## Common mistakes
- Predicting speed from TFLOPS instead of bytes moved.
- Expecting lower precision to speed up a compute-bound phase (like large prefill) as much as decode.

## Related concepts
[Arithmetic Intensity](38_Arithmetic_Intensity.md) · [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md) · [Decode](54_Decode.md) · [Batching](55_Batching.md) · [Quantization](102_Quantization.md)

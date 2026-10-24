# 13. Parameters and Weights

**Stage:** 1 — ML fundamentals | **Priority:** Must know | **Prerequisites:** [Inferencing](1_Inferencing.md)

## In one sentence
Parameters (weights) are the learned numbers inside the model; a 9B model has roughly nine billion of them.

## Plain-English explanation
A neural network is mostly big matrices. Each number in those matrices is a parameter learned during training. At inference time they're read (not changed) for every token processed. Their count and storage format determine the minimum memory needed and how many bytes must be moved from GPU memory per decode step.

## Technical depth
- **Raw weight memory** ≈ `params × bytes_per_param`:
  - BF16/FP16: `9e9 × 2 B ≈ 18 GB`
  - FP8/INT8: `≈ 9 GB`
  - INT4: `≈ 4.5 GB` (+ scales/zero-points overhead)
- This is a **lower bound**. Total runtime memory also includes KV cache/recurrent state, activations, CUDA context (~0.5–1 GB), CUDA graph buffers, and allocator fragmentation.
- On an A100 40 GB with 18 GB of BF16 weights, roughly 15–20 GB remain for cache/state and overhead — this limits concurrency.
- **Bandwidth implication:** in decode, every step reads (nearly) all weights. 18 GB / 1.555 TB/s ≈ 11.6 ms minimum per step → ≈ 86 tokens/s ceiling for a single sequence at batch size 1. Batching amortizes this read across many sequences.

## Backend-engineer analogy
Weights are a large read-only dataset that every query must scan. Shrinking it (quantization) or sharing one scan across many queries (batching) are the main levers.

## Why it matters for GreenMind
Weight size drives the memory budget for concurrent requests and the decode speed floor. It's the starting point of almost every optimization calculation.

## Common mistakes
- Assuming model size equals total VRAM requirement.
- Forgetting that "9B" is approximate and embedding/LM-head matrices can be large for big vocabularies.

## Related concepts
[Checkpoint](14_Checkpoint.md) · [VRAM and HBM](33_VRAM_and_HBM.md) · [Memory Bandwidth](34_Memory_Bandwidth.md) · [Quantization](102_Quantization.md) · [Decode](54_Decode.md)

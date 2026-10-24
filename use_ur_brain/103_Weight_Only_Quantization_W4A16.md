# 103. Weight-Only Quantization (W4A16)

**Stage:** 7 | **Priority:** Should know | **Prerequisites:** [Quantization](102_Quantization.md)

## In one sentence
Weight-only quantization compresses just the weights (e.g., to 4 bits) while activations and math stay in 16-bit; "W4A16" means 4-bit weights, 16-bit activations.

## Plain-English explanation
Store the weights small, unpack them to BF16/FP16 right before multiplying. Since decode is limited by reading weights from memory, shrinking weights speeds it up directly — while keeping activations in 16-bit preserves accuracy better than quantizing everything.

## Technical depth
- Notation: `W{bits}A{bits}` — W4A16, W8A16, W8A8, W4A8.
- Kernel does: load packed INT4 weights + group scales → dequantize in registers → FP16/BF16 Tensor Core MMA → FP32 accumulate.
- On A100: Marlin kernels (W4A16 / W8A16, incl. FP8-weight variants) are near-ideal for small-to-medium batches.
- Speedup is largest at small batch (memory-bound). At large batch or prefill (compute-bound), dequant overhead can make it equal to or slower than BF16.
- Group size (e.g., 128) and symmetric vs asymmetric scales affect accuracy and speed.
- Memory: 9B → ~5 GB weights (+ unquantized embeddings/LM head/norms) → ~13 GB more for cache.

## Backend-engineer analogy
Storing data compressed on disk and decompressing in CPU cache — wins when I/O-bound, loses when CPU-bound.

## Why it matters for GreenMind
Likely the most practical quantization path on A100 for decode-heavy workloads — if a compatible artifact exists and the rules allow it.

## Exercise
Compare BF16 vs W4A16 at batch 1, 32, 128 for TPOT and tokens/s; find where the advantage shrinks.

## Common mistakes
- Expecting prefill/TTFT gains.
- Not checking that the kernel actually supports the hybrid model's layer shapes.

## Related concepts
[AWQ](105_AWQ.md) · [INT8 and INT4](49_INT8_and_INT4.md) · [Arithmetic Intensity](38_Arithmetic_Intensity.md) · [FP16](47_FP16.md)

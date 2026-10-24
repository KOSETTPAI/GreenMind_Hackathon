# 38. Arithmetic Intensity

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [FLOPs, FLOPS, TOPS](37_FLOPs_FLOPS_and_TOPS.md), [Memory Bandwidth](34_Memory_Bandwidth.md)

## In one sentence
Arithmetic intensity is the number of operations performed per byte moved from memory; it tells you whether a kernel will be limited by compute or by memory.

## Plain-English explanation
If you fetch a number and use it once, you're memory-bound. If you fetch it once and reuse it in many calculations, you're compute-bound. Arithmetic intensity measures that reuse.

## Technical depth
- `AI = FLOPs / bytes_moved`.
- **Ridge point** (roofline model) = `peak FLOPS / peak bandwidth`. A100 BF16: `312e12 / 1.555e12 ≈ 200 FLOPs/byte`.
  - AI < 200 → memory-bound; AI > 200 → compute-bound.
- **Decode GEMV, batch B, BF16 weights:** each weight (2 bytes) is used for 2 FLOPs per token → `AI ≈ B` FLOPs/byte. So batch 1 → AI ≈ 1 (deeply memory-bound); you'd need B ≈ 200 tokens per step to approach compute-bound.
- **Prefill:** thousands of tokens share each weight read → AI in the thousands → compute-bound.
- **Weight-only INT4:** weight bytes drop 4× → AI rises 4× at the same batch → memory-bound decode speeds up (if dequant overhead is small).
- Attention decode reads a per-sequence KV cache that isn't shared across the batch → AI stays low no matter the batch size.

## Backend-engineer analogy
Like the ratio of CPU work to I/O per request: a cache-friendly in-memory computation vs. a query that reads lots of rows and does almost nothing with each.

## Why it matters for GreenMind
This single number explains why batching helps decode, why quantization helps decode more than prefill, and why the roofline model is the right first diagnostic.

## Exercise
Compute AI for batch sizes 1, 16, 64, 256 in BF16 decode; mark where it crosses the A100 ridge point.

## Related concepts
[Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md) · [Batching](55_Batching.md) · [Weight-Only Quantization](103_Weight_Only_Quantization_W4A16.md) · [GPU Memory Hierarchy](35_GPU_Memory_Hierarchy_Cache_Registers_Shared_Memory.md)

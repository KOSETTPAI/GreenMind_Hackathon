# 37. FLOPs, FLOPS, and TOPS

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [CUDA Cores and Tensor Cores](32_CUDA_Cores_and_Tensor_Cores.md)

## In one sentence
A FLOP is one floating-point operation; FLOPS is FLOPs per second (a rate); TOPS is tera (10¹²) operations per second, usually for integer math.

## Plain-English explanation
- **FLOPs (count):** "This forward pass needs 18 billion FLOPs per token."
- **FLOPS (rate):** "The A100 can do 312 trillion BF16 FLOPS (peak)."
- **TOPS:** same idea for integer ops (A100 INT8: ~624 TOPS).

Peak rates are marketing ceilings under ideal conditions — real applications reach a fraction.

## Technical depth
- Forward-pass FLOPs per token ≈ `2 × N_params` (one multiply + one add per weight) plus attention terms that grow with context. For 9B: ≈ 18 GFLOPs/token.
- **Prefill estimate:** 4,000 prompt tokens × 18 GFLOPs ≈ 72 TFLOPs → ideal ≈ 0.23 s at 312 TFLOPS; real maybe 40–60% utilization → ~0.4–0.6 s.
- **Decode** at batch 1: 18 GFLOPs per token in ~12 ms ≈ 1.5 TFLOPS achieved — <1% of peak, because it's bandwidth-bound, not compute-bound.
- **MFU** (model FLOPs utilization) = achieved FLOPS / peak FLOPS — useful for prefill. **MBU** (memory bandwidth utilization) is the analog for decode.

## Backend-engineer analogy
Peak FLOPS is like a NIC's line rate — you rarely achieve it, and if you're blocked on disk, a faster NIC doesn't help.

## Why it matters for GreenMind
Back-of-envelope FLOP and byte counts let you predict whether a phase is compute- or memory-bound and how far from the hardware limit you are.

## Common mistakes
- Using peak TFLOPS as predicted speed.
- Mixing up FLOPs (count) and FLOPS (rate).

## Related concepts
[Arithmetic Intensity](38_Arithmetic_Intensity.md) · [Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md) · [Prefill](53_Prefill.md) · [NVIDIA A100](43_NVIDIA_A100.md)

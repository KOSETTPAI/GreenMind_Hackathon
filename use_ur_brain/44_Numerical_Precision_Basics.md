# 44. Numerical Precision Basics

**Stage:** 2 / 7 | **Priority:** Must know | **Prerequisites:** [Parameters and Weights](13_Parameters_and_Weights.md)

## In one sentence
A numerical format decides how many bits store each number and how those bits split between range (exponent) and precision (mantissa) — fewer bits means less memory and bandwidth but more rounding error.

## Plain-English explanation
Floating-point numbers are like scientific notation: `sign × mantissa × 2^exponent`.
- **Exponent bits** set the **range** (how big/small numbers can get before overflow/underflow).
- **Mantissa bits** set the **precision** (how finely you can distinguish nearby values).
Integer formats (INT8/INT4) have no exponent; they need a separate **scale** factor to represent real values.

| Format | Bits | Sign/Exp/Mantissa | Notes |
|---|---|---|---|
| FP32 | 32 | 1/8/23 | reference precision |
| TF32 | 19 (stored in 32) | 1/8/10 | A100 Tensor Core math mode for FP32 inputs |
| BF16 | 16 | 1/8/7 | FP32 range, low precision |
| FP16 | 16 | 1/5/10 | more precision, narrow range |
| FP8 E4M3 / E5M2 | 8 | 1/4/3, 1/5/2 | needs scaling; not native on A100 |
| INT8 / INT4 | 8 / 4 | integer + scale | quantized weights/activations |

## Technical depth
- Bytes per param: FP32 4, BF16/FP16 2, FP8/INT8 1, INT4 0.5 (+ scale metadata).
- Accumulation is usually done in FP32 even when inputs are 16-bit or 8-bit, to limit error growth.
- Lower precision reduces memory traffic and can increase Tensor Core throughput — **but only if a supported, efficient kernel exists** for that format on that GPU.

## Backend-engineer analogy
Like choosing `float64` vs `float32` vs compressed integer encodings for a column: smaller encodings save storage and I/O but lose fidelity and may need decode work.

## Why it matters for GreenMind
Precision is the main "model-side" lever: BF16 baseline vs FP8/INT8/INT4 variants trade memory/bandwidth/energy against accuracy retention.

## Common mistakes
- Assuming "half the bits = twice the speed."
- Ignoring the scale/metadata overhead of integer formats.

## Related concepts
[FP32](45_FP32.md) · [BF16](46_BF16.md) · [FP16](47_FP16.md) · [FP8](48_FP8.md) · [INT8 and INT4](49_INT8_and_INT4.md) · [Quantization](102_Quantization.md)

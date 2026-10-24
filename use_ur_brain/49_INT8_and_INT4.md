# 49. INT8 and INT4

**Stage:** 2 / 7 | **Priority:** Should know | **Prerequisites:** [Numerical Precision Basics](44_Numerical_Precision_Basics.md)

## In one sentence
INT8 and INT4 are integer formats used to store quantized weights (and sometimes activations) with a scale factor, cutting weight memory to ~1/2 or ~1/4 of BF16.

## Plain-English explanation
Instead of storing each weight as a float, store a small integer plus a shared scale: `real ≈ scale × (int − zero_point)`. INT8 has 256 levels; INT4 only 16. Weights are grouped (e.g., 128 weights share one scale) to limit error.

## Technical depth
- **Weight memory (9B):** INT8 ≈ 9 GB, INT4 ≈ 4.5 GB + scales (group size 128 adds ~3% extra).
- **Symmetric vs asymmetric:** with or without zero-point.
- **Granularity:** per-tensor, per-channel, per-group. Smaller groups = better accuracy, more metadata.
- **Schemes:**
  - **W8A8 (INT8):** weights and activations INT8 → uses A100 INT8 Tensor Cores (~624 TOPS); activation outliers make it harder (SmoothQuant-style methods address this).
  - **W4A16:** INT4 weights, 16-bit activations → weights dequantized in-kernel (e.g., Marlin kernels on Ampere); great for memory-bound decode.
- **Outliers:** a few large-magnitude values stretch the scale and crush the rest; methods like AWQ/GPTQ protect important weights.

## Backend-engineer analogy
Lossy compression with a codebook/scale per block — like storing prices as integer cents with a currency multiplier, but with only 16 possible values per block for INT4.

## Why it matters for GreenMind
INT4/INT8 weights can free 9–13 GB of VRAM for more concurrent sequences and speed up decode — if accuracy (especially Thai, coding, tool-calls) holds and an efficient kernel supports the hybrid model's layers.

## Common mistakes
- Expecting "4-bit = 4× faster and ¼ of total VRAM." Cache, activations, overhead, and non-quantized layers don't shrink.
- Quantizing without per-category accuracy checks.

## Related concepts
[Quantization](102_Quantization.md) · [Weight-Only Quantization](103_Weight_Only_Quantization_W4A16.md) · [AWQ](105_AWQ.md) · [Calibration](104_Calibration.md) · [CUDA Cores and Tensor Cores](32_CUDA_Cores_and_Tensor_Cores.md)

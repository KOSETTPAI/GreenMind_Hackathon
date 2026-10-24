# 32. CUDA Cores and Tensor Cores

**Stage:** 2 | **Priority:** Must know | **Prerequisites:** [Streaming Multiprocessor](31_Streaming_Multiprocessor_SM.md)

## In one sentence
CUDA cores do general scalar arithmetic; Tensor Cores are specialized units that perform small matrix multiply-accumulate operations extremely fast in supported low-precision formats.

## Plain-English explanation
CUDA cores are general-purpose calculators. Tensor Cores are matrix-multiplication machines — they multiply small tiles of matrices in one shot. Nearly all the heavy LLM math (attention projections, FFN) runs on Tensor Cores, but only if the data is in a format they support.

## Technical depth
- A100 third-gen Tensor Cores support: **FP16, BF16, TF32, INT8, INT4** (and FP64). They do **not** natively support FP8 (that's Hopper/Ada, sm_89/90).
- Approximate A100 dense peaks: FP32 (CUDA cores) 19.5 TFLOPS; TF32 156 TFLOPS; BF16/FP16 312 TFLOPS; INT8 624 TOPS; INT4 1248 TOPS. Sparsity can double these on supported 2:4 structured-sparse kernels.
- **Weight-only quantized** kernels (e.g., W4A16 via Marlin) dequantize weights to FP16/BF16 on the fly and still use FP16/BF16 Tensor Core math.
- FP8 checkpoints on A100 typically run as weight-only (FP8 weights dequantized to 16-bit), saving memory/bandwidth but not getting FP8 compute speedups.

## Backend-engineer analogy
CUDA cores are general CPUs; Tensor Cores are like a hardware accelerator for one specific op (think AES-NI for encryption). Huge speedup — only if your data fits the format.

## Why it matters for GreenMind
Precision choices matter only through supported Tensor Core/kernel paths on A100. A "faster" format without an efficient A100 kernel may be slower.

## Common mistakes
- Assuming FP8 gives compute speedups on A100.
- Using peak TFLOPS as predicted throughput.

## Related concepts
[FLOPs, FLOPS, TOPS](37_FLOPs_FLOPS_and_TOPS.md) · [Numerical Precision Basics](44_Numerical_Precision_Basics.md) · [FP8](48_FP8.md) · [INT8 and INT4](49_INT8_and_INT4.md) · [NVIDIA A100](43_NVIDIA_A100.md)

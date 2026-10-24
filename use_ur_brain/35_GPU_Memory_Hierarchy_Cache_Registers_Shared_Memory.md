# 35. GPU Memory Hierarchy (Cache, Registers, Shared Memory)

**Stage:** 2 | **Priority:** Should know | **Prerequisites:** [Memory Bandwidth](34_Memory_Bandwidth.md)

## In one sentence
GPU memory is layered from tiny-and-fast (registers) to big-and-slow (HBM), and fast kernels keep data in the upper layers as long as possible.

## Plain-English explanation
| Level | A100 size (approx.) | Speed | Scope |
|---|---|---|---|
| Registers | 256 KB per SM | fastest | per thread |
| Shared memory / L1 | up to 192 KB per SM | very fast | per thread block |
| L2 cache | 40 MB | fast | whole GPU |
| HBM (VRAM) | 40 GB | ~1.555 TB/s | whole GPU |

Reading from HBM is far slower and more power-hungry than reading from on-chip memory. Good kernels load a tile once into shared memory and reuse it many times.

## Technical depth
- **Tiling:** matrix-multiply kernels load blocks of A and B into shared memory and compute partial products — reuse raises arithmetic intensity.
- **FlashAttention** keeps attention score tiles in shared memory/registers and never writes the full `n×n` matrix to HBM.
- **Kernel fusion** keeps intermediate results on-chip instead of writing to HBM between ops.
- L2 (40 MB) is far smaller than the weights (18 GB), so weights stream from HBM every decode step — caching doesn't save you there.
- Register pressure limits how many threads run per SM → affects [Occupancy](40_Occupancy.md).

## Backend-engineer analogy
CPU L1/L2/RAM/disk, or app cache → Redis → database. Same lesson: maximize reuse at the fast layer, minimize round trips to the slow one.

## Why it matters for GreenMind
Explains why fused kernels and FlashAttention help, and why data movement (not math) dominates energy in many inference phases.

## Common mistakes
- Assuming the 40 MB L2 can meaningfully cache model weights during decode.

## Related concepts
[Kernels](36_Kernels.md) · [Kernel Fusion](109_Kernel_Fusion.md) · [FlashAttention](110_FlashAttention.md) · [Arithmetic Intensity](38_Arithmetic_Intensity.md)

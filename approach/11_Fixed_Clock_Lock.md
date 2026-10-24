# Approach 11: Fixed GPU Clock Lock

**Rank:** 11 · **Effort:** very low · **Risk:** medium · **Verdict:** maybe, after Approach 2

**Goal:** fix the GPU graphics clock at an efficient value as an alternative (or addition) to a power cap.

**One-line thesis:** a power cap lets the GPU pick its own clocks under the limit; a clock lock pins them. For memory-bound decode, a lower fixed clock may save power with little slowdown.

---

## 1. Evidence

- Energy vs frequency is U-shaped, with a middle sweet spot ([arXiv 2509.04827](https://arxiv.org/pdf/2509.04827v1)).
- No source found showing a clock lock beats a power cap, or that it meaningfully lowers idle power on A100 (~50–57 W idle either way) ([NVIDIA forum](https://forums.developer.nvidia.com/t/minimizing-a100-power-consumptin-while-idle-under-linux/308388); [power snapshot](https://services.nmrbox.org/system/gpudetail/gauss.nmrbox.org)).

Concepts: [GPU Power Caps and Clocks](../use_ur_brain/122_GPU_Power_Caps_and_Clocks.md)

---

## 2. Proposed steps (untested — run on the VM to confirm)

Source: standard `nvidia-smi` clock options; needs `sudo`.

```bash
nvidia-smi -q -d SUPPORTED_CLOCKS
```
```bash
sudo nvidia-smi -lgc 1095,1095
```

1. Compare 2–3 fixed clocks against the best power cap from Approach 2, one Validation run each.
2. Keep whichever gives the better S. Reset with `sudo nvidia-smi -rgc`.
3. The setting must stay **constant for the whole run**.

---

## 3. Risks

Prefill (long RAG prompts) is compute-bound and slows directly with lower clocks → TTFT misses. The lowest clocks can raise total joules.

## 4. Abandon criteria

No improvement over the best power cap.

# Approach 16: Rejected for This Event — Pruning, Fine-Tuning/Distillation, Custom Kernels

**Rank:** 16 · **Verdict:** no (record why, for the pitch)

These are allowed by the rules but don't fit a 2-day event. Listing them shows judges we considered and rejected them deliberately.

| Approach | Why rejected |
|---|---|
| **Pruning** | Removing weights only saves energy if kernels exploit the sparsity; unstructured sparsity gives little speedup on A100. High accuracy risk, especially per class (Thai, tool calls). |
| **Fine-tuning / distillation** | Allowed on open data only, and derived weights must be made during the event. Training plus full re-evaluation won't fit in the time; accuracy gains don't earn extra credit (retention caps at 98%). |
| **Custom kernels** | Fused or hand-written kernels for the hybrid layers could help, but need extensive correctness testing. Very high effort for an uncertain gain. |

Concepts: [Pruning](../use_ur_brain/106_Pruning.md) · [Fine-Tuning and Distillation](../use_ur_brain/108_Fine_Tuning_and_Distillation.md) · [Kernel Fusion](../use_ur_brain/109_Kernel_Fusion.md)

---

## Proposed steps (untested — run on the VM to confirm)

None. Revisit only if all higher-ranked approaches are done and time remains.

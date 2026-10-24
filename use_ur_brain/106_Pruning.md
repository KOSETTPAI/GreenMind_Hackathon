# 106. Pruning

**Stage:** 7 | **Priority:** Advanced / rule-dependent | **Prerequisites:** [Quantization](102_Quantization.md)

## In one sentence
Pruning removes weights or whole structures (heads, channels, layers) from a model to make it smaller — but sparsity only speeds things up if the hardware and kernels exploit it.

## Plain-English explanation
Some weights barely matter; set them to zero or cut them out. Two kinds:
- **Unstructured pruning:** zero out individual weights. The matrix is the same shape — no speedup without special sparse kernels.
- **Structured pruning:** remove whole rows/heads/layers. The model actually gets smaller and faster, but accuracy usually drops and often needs retraining to recover.

## Technical depth
- **2:4 semi-structured sparsity:** 2 of every 4 weights are zero; A100 Tensor Cores can exploit this for up to ~2× math throughput. vLLM has some support for 2:4 sparse checkpoints, but accuracy recovery usually needs fine-tuning, and speedups in memory-bound decode are smaller than the headline.
- Layer pruning in a hybrid model is risky: removing attention layers can destroy long-context recall.
- Pruning typically counts as modifying the model artifact — check the rules.

## Backend-engineer analogy
Deleting unused indexes or columns: only helps if the query engine actually skips them; deleting the wrong ones breaks queries.

## Why it matters for GreenMind
Mostly a "know it exists" concept here: high effort, high accuracy risk, and likely restricted by the rules.

## Common mistakes
- Expecting speedups from unstructured sparsity on dense kernels.
- Pruning without permission or without full accuracy evaluation.

## Related concepts
[Fine-Tuning and Distillation](108_Fine_Tuning_and_Distillation.md) · [Allowed Artifacts](9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [CUDA Cores and Tensor Cores](32_CUDA_Cores_and_Tensor_Cores.md) · [Weight Conversion](107_Weight_Conversion.md)

# 21. Residual Connections

**Stage:** 1 | **Priority:** Should know | **Prerequisites:** [Normalization](20_Normalization.md)

## In one sentence
A residual connection adds a block's input back to its output (`y = x + f(x)`), so each layer only learns a refinement instead of a full replacement.

## Plain-English explanation
Imagine editing a document with tracked changes instead of rewriting it from scratch each pass. Each layer proposes a small change; the residual connection keeps the original and adds the change. This makes very deep networks trainable and keeps information flowing through dozens of layers.

## Technical depth
- Pre-norm block: `h' = h + Attn(Norm(h))`, then `h'' = h' + FFN(Norm(h'))`.
- The running sum `h` is often called the **residual stream**.
- At inference, the residual add is a cheap elementwise op but costs a memory read/write of the whole hidden state → often **fused** with the following normalization (fused add-RMSNorm).
- Quantization errors in one layer propagate down the residual stream; outlier values in the stream are a known difficulty for activation quantization.

## Backend-engineer analogy
Like a patch/diff applied to a base object at each pipeline stage, rather than each stage returning an entirely new object.

## Why it matters for GreenMind
Mostly background knowledge; relevant when reasoning about kernel fusion and why activation outliers make INT8 activation quantization harder than weight-only quantization.

## Common mistakes
- None common in serving — just know the term when reading kernel or quantization docs.

## Related concepts
[Normalization](20_Normalization.md) · [Kernel Fusion](109_Kernel_Fusion.md) · [Quantization](102_Quantization.md) · [Embeddings and Hidden States](17_Embeddings_and_Hidden_States.md)

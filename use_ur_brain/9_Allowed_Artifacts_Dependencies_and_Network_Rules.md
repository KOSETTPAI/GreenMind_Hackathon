# 9. Allowed Artifacts, Dependencies, and Network Rules

**Stage:** 0 | **Priority:** Must know | **Prerequisites:** [Hard Gates](2_Hard_Gates_and_Eligibility.md)

## In one sentence
These rules define what you may change or bring: model files, converted/quantized checkpoints, libraries, engines, and whether the server may access the internet.

## Plain-English explanation
Before planning any optimization, ask: **is it allowed?**
- May I use a quantized version of the model? Only organizer-provided ones, or may I create my own?
- May I swap vLLM for SGLang or TensorRT-LLM?
- May I install extra Python packages or custom CUDA kernels?
- May I fine-tune, prune, or distill the model?
- Is network access blocked during evaluation (so no downloading weights at startup)?

An optimization that violates these rules is not an optimization — it's a disqualification.

## Technical depth
- **Artifacts:** checkpoint files, tokenizer, chat template, config. Record SHA-256 hashes.
- **Dependencies:** pin exact versions (`pip freeze`, container image digest). vLLM behavior changes between releases.
- **Offline operation:** set `HF_HUB_OFFLINE=1` / `TRANSFORMERS_OFFLINE=1` and pre-download everything; test with the network disabled.
- **Weight conversion vs training:** converting dtype/layout is not training, but rules may still restrict it.

## Backend-engineer analogy
Like a locked-down production environment: approved base images only, no outbound internet, dependency allowlist, change-management rules.

## Why it matters for GreenMind
Quantization, engine swaps, speculative decoding with a draft model, and custom kernels all depend on these rules. Check them before spending hours on an idea.

## Common mistakes
- Server works on your laptop because it silently downloads files; fails offline in evaluation.
- Building a custom quantized artifact when only provided artifacts are permitted.

## Related concepts
[Weight Conversion](107_Weight_Conversion.md) · [Quantization](102_Quantization.md) · [Fine-Tuning and Distillation](108_Fine_Tuning_and_Distillation.md) · [Engine Migration Gate](117_Engine_Migration_Gate.md) · [Reproducibility](87_Reproducibility.md)

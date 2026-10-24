# 108. Fine-Tuning and Distillation

**Stage:** 7 | **Priority:** Advanced / rule-dependent | **Prerequisites:** [Inferencing](1_Inferencing.md), [Quantization](102_Quantization.md)

## In one sentence
Fine-tuning updates a model's weights on new data; distillation trains a smaller "student" model to imitate a larger "teacher" — both change the model itself and are only options if the rules explicitly permit them.

## Plain-English explanation
- **Fine-tuning:** continue training the model (fully or with adapters like LoRA) to change its behavior — e.g., recover accuracy lost to quantization ("quantization-aware training") or make outputs more concise.
- **Distillation:** a big model generates answers/probabilities; a smaller model learns to copy them. The student is faster but usually less capable.

These are training, not inference optimization — expensive, slow, and high-risk in a hackathon timeframe.

## Technical depth
- LoRA adapters can be served by vLLM (`--enable-lora`), but adapters add compute overhead unless merged.
- Quantization-aware training / QAT and "healing" fine-tunes can improve low-bit accuracy.
- Distilled draft models are used for [Speculative Decoding](111_Speculative_Decoding.md) — the draft must share the target's tokenizer.
- Rules commonly forbid changing model behavior, require the original artifact, or limit training compute — verify first.

## Backend-engineer analogy
Rewriting the service logic vs tuning its deployment. Big potential gains, big risk, and it may violate the "don't change the product" contract.

## Why it matters for GreenMind
Know what they are so you can rule them in or out based on the briefing. Likely out of scope unless explicitly allowed.

## Common mistakes
- Spending hackathon time on training when serving config is untuned.
- Using a tuned model without permission.

## Related concepts
[Allowed Artifacts](9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [Pruning](106_Pruning.md) · [Speculative Decoding](111_Speculative_Decoding.md) · [Weight Conversion](107_Weight_Conversion.md)

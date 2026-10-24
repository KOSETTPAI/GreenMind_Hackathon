# 14. Checkpoint

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Parameters and Weights](13_Parameters_and_Weights.md)

## In one sentence
A checkpoint is the saved model artifact: weight files plus config, tokenizer, and chat-template files.

## Plain-English explanation
When you "download a model" from Hugging Face you get a folder like:
- `config.json` — architecture: layer count, hidden size, layer types, vocab size, dtype, max positions.
- `model-0000x-of-0000y.safetensors` — the weights, sharded.
- `tokenizer.json`, `tokenizer_config.json` — the tokenizer and often the **chat template** (Jinja).
- `generation_config.json` — default sampling settings.

That folder *is* the model. Changing any file — even just the chat template — can change outputs.

## Technical depth
- **safetensors** is the standard safe, memory-mappable format; loading is fast and doesn't execute code.
- `config.json` reveals the architecture class (e.g., which layers are attention vs linear/recurrent), essential for a hybrid model.
- Quantized checkpoints add `quantization_config` (method, bits, group size).
- Record **hashes** (e.g., `sha256sum *.safetensors`) so you can prove which artifact produced which result.

## Backend-engineer analogy
An immutable, versioned release artifact (like a container image). Pin it by digest, never by "latest."

## Why it matters for GreenMind
You must serve the organizer-provided MANGO1.5-Qwen3.5-9B checkpoint (or permitted variants). Inspecting `config.json` is the first step to understanding its hybrid layers and what vLLM must support.

## Exercise
Open `config.json` and list: number of layers, layer types, hidden size, vocab size, max context, dtype, and any quantization info.

## Common mistakes
- Editing the chat template and then blaming the kernel for quality changes.
- Not recording which checkpoint revision was used.

## Related concepts
[Chat Templates](28_Chat_Templates.md) · [Tokens and Tokenizer](15_Tokens_and_Tokenizer.md) · [Weight Conversion](107_Weight_Conversion.md) · [Reproducibility](87_Reproducibility.md)

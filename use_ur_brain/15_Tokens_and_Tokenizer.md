# 15. Tokens and Tokenizer

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Checkpoint](14_Checkpoint.md)

## In one sentence
A token is the unit the model processes (often a word piece), and the tokenizer converts text to token IDs and back.

## Plain-English explanation
Models don't read characters or words; they read tokens. "unbelievable" might be `["un", "believ", "able"]`. Common English words are often one token; rare words, code symbols, and non-Latin scripts like Thai often split into more tokens.

Cost scales with tokens, not words: more prompt tokens → more prefill work; more output tokens → more decode steps.

## Technical depth
- Most modern LLMs use **BPE** (byte-pair encoding) or similar subword algorithms, often byte-level so any text can be encoded.
- **Detokenization** is incremental during streaming; multi-byte characters (Thai, emoji) can span tokens, so a streamed chunk may hold a partial character until the next token arrives.
- Different tokenizers give different counts for the same text; Thai has no spaces between words, so tokenization efficiency varies a lot.
- Tokenization runs on the **CPU**. Under heavy load with long prompts, it can become a bottleneck.

## Backend-engineer analogy
Tokenization is a serialization/encoding boundary, like UTF-8 encoding or protobuf: it decides the payload size the downstream system processes.

## Why it matters for GreenMind
Thai requests may cost more tokens per meaning → higher latency and energy. Long RAG prompts → more prefill tokens. CPU tokenization can starve the GPU.

## Exercise
```python
from transformers import AutoTokenizer
tok = AutoTokenizer.from_pretrained("<model_path>")
for s in ["Hello, how are you?", "สวัสดีครับ คุณสบายดีไหม"]:
    ids = tok.encode(s); print(len(ids), ids[:20], tok.convert_ids_to_tokens(ids)[:20])
```
Compare token counts for equivalent English and Thai sentences.

## Common mistakes
- Treating a token as a word.
- Estimating cost from character counts.

## Related concepts
[Token IDs and Vocabulary](16_Token_IDs_and_Vocabulary.md) · [Prompt and Completion Tokens](27_Prompt_and_Completion_Tokens.md) · [Chat Templates](28_Chat_Templates.md) · [CPU and API Worker Capacity](99_CPU_and_API_Worker_Capacity.md)

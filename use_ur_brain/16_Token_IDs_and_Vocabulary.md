# 16. Token IDs and Vocabulary

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Tokens and Tokenizer](15_Tokens_and_Tokenizer.md)

## In one sentence
The vocabulary is the fixed set of tokens a model knows, and each token has an integer ID — the model's actual inputs and outputs are these IDs.

## Plain-English explanation
Think of the vocabulary as a dictionary of ~150k entries (Qwen-family models have vocabularies around 150k tokens; check `vocab_size` in `config.json`). Every entry has a number. Text → list of numbers → model → a score for every number in the dictionary → pick one → convert back to text.

Special tokens also live in the vocabulary: beginning/end of sequence, chat role markers (e.g., `<|im_start|>`), tool-call markers, and "thinking" markers.

## Technical depth
- **Embedding matrix:** `vocab_size × hidden_size`, maps each ID to a vector.
- **LM head:** `hidden_size × vocab_size`, maps the final hidden state to logits over the whole vocabulary — computed every decode step.
- With a large vocab, the LM head is a noticeable chunk of weights and compute, and the logits tensor (`batch × vocab` floats) is non-trivial.
- **EOS token / stop tokens** end generation; if templates or stop settings are wrong, the model may run to `max_tokens` and waste energy.

## Backend-engineer analogy
Like an enum or a dictionary-encoded column: strings are mapped to compact integer codes for processing.

## Why it matters for GreenMind
Special tokens control chat roles, tool calls, and stopping. A mismatch between template and tokenizer can break tool-call parsing or cause runaway generations.

## Common mistakes
- Ignoring special tokens when debugging tool-call or stop failures.
- Assuming the vocabulary is "words."

## Related concepts
[Embeddings and Hidden States](17_Embeddings_and_Hidden_States.md) · [Logits](22_Logits.md) · [Chat Templates](28_Chat_Templates.md) · [Tool Calling](73_Tool_Calling.md)

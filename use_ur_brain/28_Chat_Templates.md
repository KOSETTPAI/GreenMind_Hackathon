# 28. Chat Templates

**Stage:** 1 / 3 | **Priority:** Must know | **Prerequisites:** [Prompt and Completion Tokens](27_Prompt_and_Completion_Tokens.md)

## In one sentence
A chat template converts a list of chat messages (system/user/assistant/tool) and tool definitions into the exact token sequence the model was trained on.

## Plain-English explanation
The API receives JSON like `[{"role":"user","content":"hi"}]`, but the model needs one flat token string with special markers, e.g.:
```
<|im_start|>system
You are helpful.<|im_end|>
<|im_start|>user
hi<|im_end|>
<|im_start|>assistant
```
The template (a Jinja script in `tokenizer_config.json` or `chat_template.jinja`) does this. It also inserts tool schemas and defines how the model should format tool calls and "thinking" sections.

## Technical depth
- vLLM applies the template on the server; `--chat-template` can override it (rarely a good idea).
- Templates may have flags like `enable_thinking` passed via `chat_template_kwargs`.
- Tool calls rely on matching template + **tool-call parser** (`--tool-call-parser`, `--enable-auto-tool-choice`). A mismatch means tool calls show up as plain text instead of structured `tool_calls`.
- Template rendering runs on the CPU per request — small cost, but adds up at high request rates with big tool schemas.

## Backend-engineer analogy
A serializer between your public API schema and an internal wire format. A wrong serializer produces valid-looking but semantically wrong payloads.

## Why it matters for GreenMind
Tool-calling and multi-turn correctness depend on it. Changing it can tank accuracy; a quantization or kernel change may get blamed for what's really a template issue.

## Common mistakes
- Editing the template and attributing quality changes to kernels.
- Using a different engine whose default template differs from the model's.

## Related concepts
[Tool Calling](73_Tool_Calling.md) · [Checkpoint](14_Checkpoint.md) · [OpenAI-Compatible API](72_OpenAI_Compatible_API.md) · [Token IDs and Vocabulary](16_Token_IDs_and_Vocabulary.md)

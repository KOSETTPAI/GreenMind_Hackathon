# 6. Workload Mix

**Stage:** 0 | **Priority:** Must know | **Prerequisites:** [Inferencing](1_Inferencing.md)

## In one sentence
The workload mix is the blend of request types the grader sends — here chat, RAG, agentic tool calls, reasoning, coding, Thai, and long-context — each with a different cost and failure profile.

## Plain-English explanation
Not all requests are equal:

| Type | Typical shape | Main stress |
|---|---|---|
| Chat | short prompt, medium output | decode / TPOT |
| RAG | long prompt (retrieved docs), short-medium output | prefill / TTFT, prefix reuse |
| Agentic / tool calls | multi-turn, structured JSON output | format correctness, repeated prefixes |
| Reasoning | long output ("thinking") | decode time, energy |
| Coding | medium-long output, exactness matters | accuracy under quantization |
| Thai | more tokens per meaning, less-represented language | token cost, quantization sensitivity |
| Long-context | very long prompt | memory, prefill, cache/state size |

A change that helps one category can hurt another.

## Technical depth
- Prompt-length distribution drives [Prefill](53_Prefill.md) cost and TTFT; output-length distribution drives [Decode](54_Decode.md) cost, TPOT, and energy.
- Mixed lengths cause head-of-line blocking: a long prefill can stall decode for others unless [Chunked Prefill](95_Chunked_Prefill.md) is used.
- Always report metrics **per category**, not only aggregate.

## Backend-engineer analogy
Like an API with cheap GETs and expensive report-generation endpoints sharing a pool: tuning for the average request can starve the expensive ones or vice versa.

## Why it matters for GreenMind
Accuracy may be macro-averaged across categories, so a Thai or tool-call regression can cost far more than its share of traffic suggests.

## Common mistakes
- Benchmarking with one prompt repeated.
- Hiding a Thai/coding/tool-call regression inside a fine-looking aggregate.

## Related concepts
[Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md) · [RAG](75_RAG.md) · [Tool Calling](73_Tool_Calling.md) · [Agentic Workloads](74_Agentic_Workloads_and_Multi_Turn.md) · [Tokens and Tokenizer](15_Tokens_and_Tokenizer.md)

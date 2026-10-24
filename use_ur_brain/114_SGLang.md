# 114. SGLang

**Stage:** 8 | **Priority:** Advanced (alternative engine) | **Prerequisites:** [vLLM](113_vLLM.md)

## In one sentence
SGLang is an open-source LLM serving runtime known for RadixAttention prefix caching, fast structured generation, and an efficient scheduler, with an OpenAI-compatible server.

## Plain-English explanation
SGLang does the same job as vLLM — continuous batching, paged caches, OpenAI API — with different design choices. Its standout is **RadixAttention**: a radix-tree cache of prompt prefixes that automatically shares computation across requests (excellent for multi-turn/agentic and RAG with shared prefixes). It's also strong at constrained/structured outputs.

## Technical depth
- Launch: `python -m sglang.launch_server --model-path <path> --port 30000 ...`.
- Features: RadixAttention, chunked prefill, CUDA graphs, torch.compile, quantization support, speculative decoding (EAGLE), tool-call parsers, overlap scheduler (overlaps CPU scheduling with GPU compute).
- **Hybrid model support** (Mamba/Gated DeltaNet) and prefix caching for recurrent state: version-dependent — verify for MANGO.
- Differences in defaults, tool-call formats, streaming chunk behavior, and usage reporting vs vLLM must be tested.

## Backend-engineer analogy
An alternative app server with a smarter built-in cache — potentially faster, but you must re-validate API semantics.

## Why it matters for GreenMind
A plausible alternative if vLLM underperforms on prefix-heavy agentic/RAG traffic — only after passing the [Engine Migration Gate](117_Engine_Migration_Gate.md).

## Common mistakes
- Comparing engines with different default sampling, max lengths, or templates.
- Assuming hybrid architecture support.

## Related concepts
[vLLM](113_vLLM.md) · [Prefix Caching](96_Prefix_Caching.md) · [Engine Migration Gate](117_Engine_Migration_Gate.md) · [Tool Calling](73_Tool_Calling.md)

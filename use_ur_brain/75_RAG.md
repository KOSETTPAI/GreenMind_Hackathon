# 75. RAG (Retrieval-Augmented Generation)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Prompt and Completion Tokens](27_Prompt_and_Completion_Tokens.md)

## In one sentence
RAG inserts retrieved documents into the prompt so the model can answer from them — which makes prompts long and often shares repeated prefixes.

## Plain-English explanation
A RAG request looks like: system prompt + "Here are relevant documents: [doc1] [doc2] [doc3]" + user question. The documents may be thousands of tokens. The answer is often short. So RAG is **prefill-heavy**: TTFT dominates, decode is minor.

In the hackathon, the grader sends RAG-style requests (retrieval is already done; the documents are in the prompt).

## Technical depth
- Cost ≈ prefill of `n_docs × doc_len` tokens + short decode.
- **Prefix sharing:** if the same system prompt or document set repeats across requests, prefix caching can skip recomputation. Document order matters — identical prefixes must match token-for-token from the start.
- **Long-context recall:** quantization or state-compression can hurt the model's ability to find facts buried in long contexts; hybrid recurrent layers compress history, which is why hybrid models keep some full-attention layers.
- Chunked prefill keeps long RAG prompts from stalling decode of other requests.

## Backend-engineer analogy
A query that ships a large payload for a small answer — dominated by upload/parse time, not response time.

## Why it matters for GreenMind
RAG requests are the most likely TTFT SLO violators and the biggest beneficiaries of prefix caching and chunked prefill tuning.

## Common mistakes
- Testing with short prompts only.
- Not checking long-context accuracy after quantization.

## Related concepts
[Prefill](53_Prefill.md) · [TTFT](62_TTFT.md) · [Prefix Caching](96_Prefix_Caching.md) · [Chunked Prefill](95_Chunked_Prefill.md) · [Context Window](26_Context_Window.md)

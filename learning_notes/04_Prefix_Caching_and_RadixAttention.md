# Module 04: Prefix Caching & RadixAttention

---

## 1. What is Prefix Caching?

In real-world applications, incoming user queries are rarely completely isolated and unique. Prompts frequently share common prefix token sequences:
* **System Prompts**: Lengthy instructions defining persona, formatting guidelines, and guardrails.
* **Agentic Tool Definitions**: JSON schemas describing available function calls.
* **Multi-Turn Chat History**: Conversational context repeated across turns 1 through 15.
* **RAG Contexts**: Enterprise documents, PDF pages, or knowledge bases prepended to queries.

```
Request 1: [System Prompt (500 tokens)] + [Tool Definitions (1,500 tokens)] + [User Query A]
Request 2: [System Prompt (500 tokens)] + [Tool Definitions (1,500 tokens)] + [User Query B]
             ▲                                ▲
             └────────────────────────────────┴─── EXACT DUPLICATE COMPUTATION!
```

Without prefix caching, the engine wastes compute re-evaluating those 2,000 prompt tokens on every request.
With **Automatic Prefix Caching (APC)**:
* The engine hashes physical KV cache blocks by their token content and sequence position.
* When Request 2 arrives, the engine performs an $O(1)$ lookup in its Radix tree, finds the existing KV blocks for the first 2,000 tokens, and **skips the prefill calculation completely**.

---

## 2. RadixAttention (SGLang) vs. Block Hashing (vLLM)

### vLLM Block Hashing:
* Hashes tokens in fixed block chunks (typically 16 tokens per block).
* A block is cached if all 16 tokens and its preceding prefix hash match.

### SGLang RadixAttention:
* Organizes all cached KV blocks into a dynamic **Radix Tree** (trie).
* Efficiently supports token-level branching, prefix matching, and LRU (Least Recently Used) cache eviction directly on the GPU.

---

## 3. The Power of Prefix Caching in Multi-Turn Agentic Workloads

In the GreenMind Hackathon benchmark, **60 out of 300 requests were multi-turn agentic tool calls (up to 15 turns)**.

### Mathematical Impact on Latency & Energy:
On a 2,500-token prompt:
* **Cold Prefill (Cache Miss)**:
  * Full matrix multiplication across 2,500 tokens.
  * Time to First Token: $\text{TTFT} \approx \mathbf{2.45\text{ s}}$.
  * Active GPU board draw: $\approx 310\text{ W}$.
* **Warm Prefill (Cache Hit)**:
  * Zero attention computation for cached tokens; only process the new user turn (e.g., 50 tokens).
  * Time to First Token: $\text{TTFT} \approx \mathbf{0.16\text{ s}}$ (Over **15x faster!**).
  * Active GPU board draw: Returns immediately to decode mode ($\approx 200\text{ W}$).

This explains why Attempt 7 in the hackathon saw its $p_{95}\text{ TTFT}$ plummet from **2.47 s to 0.16 s** with an **87% prefix hit rate**!

---

## 4. The Engineering Trap: Why Naive Speculative Decoding (MTP) Killed the Cache

In `final-run2`, the team attempted to enable Multi-Token Prediction (MTP) speculative decoding alongside prefix caching:

```
Result from final-run2 logs:
Prefix Cache Hit Rate collapsed from 44% down to 1.07%!
Energy per request jumped from 190 Joules to 208 Joules!
```

### Why Did This Happen?
1. **Speculative Tree Branching**: MTP draft heads propose multiple candidate tokens simultaneously. If the draft head explores non-deterministic candidate branches, the generated token IDs diverge from standard hash prefixes.
2. **Draft Head Bypass**: In earlier vLLM nightly releases, the speculative decoding module maintained a separate KV buffer that did not feed into the core PagedAttention Radix tree.
3. **The Systems Trade-off**:
   * Saving 20% on decode time via speculative decoding is completely negated if it causes you to **lose a 44% prefix cache hit rate on prefill**.
   * **Rule for AI Systems Engineers**: On workloads with heavy prompt sharing (Agents, RAG, Chat), **Prefix Caching must always take precedence over speculative draft heads**.

# Approach 5: Batched-Token Budget and Chunked Prefill

**Rank:** 5 · **Effort:** low · **Risk:** low

**Goal:** stop long prompts (RAG, up to 32K tokens) from stalling everyone else's token generation, so TPOT and TTFT both stay within SLO at peak.

**One-line thesis:** a long prefill processed in one go blocks the decode steps of every other request. Splitting it into chunks and capping tokens per step keeps decode flowing.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_L` (TPOT) | decode isn't blocked by big prefills | ↑ |
| SLO-met | fewer TPOT misses during RAG / long-context bursts | ↑ |
| TTFT on long prompts | smaller budget → long prompts take more steps | ↓ if budget too small |
| `s_E` | indirect, via more SLO-met requests | ↑ |

Our workload has 60 RAG and 15 long-context (≤ 32K) requests, so this matters.

Concepts: [Chunked Prefill](../use_ur_brain/95_Chunked_Prefill.md) · [Batch Token Budget](../use_ur_brain/93_Batch_Token_Budget.md) · [Prefill](../use_ur_brain/53_Prefill.md) · [TTFT](../use_ur_brain/62_TTFT.md)

---

## 2. Evidence

- vLLM docs: chunked prefill balances prefill and decode work; the batched-token budget trades TTFT against inter-token latency (roadmap Stage 6).

---

## 3. Proposed steps (untested — run on the VM to confirm)

Source: vLLM flags `--enable-chunked-prefill` and `--max-num-batched-tokens`; chunked prefill may already be on by default in recent versions, so check the startup log.

```bash
vllm serve <model> --enable-chunked-prefill --max-num-batched-tokens 4096 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Confirm in the startup log whether chunked prefill is already enabled.
2. Sweep `--max-num-batched-tokens` 2048 → 4096 → 8192.
3. Compare TTFT p95 **normalized by each request's own SLO** and TPOT p95 together.

---

## 4. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Long-prompt TTFT misses | TTFT p95 for RAG / long-context class | raise budget |
| TPOT spikes during long prefills | TPOT p95 | lower budget |
| Hybrid layers disable chunked prefill | startup log warning | skip approach |

---

## 5. Measurement sheet

| Run | Budget | TTFT p95 (norm.) | TTFT p95 RAG | TPOT p95 | SLO-met | E (kJ) | η | Decision |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| C0 | default | | | | | | | reference |
| C1 | 2048 | | | | | | | |
| C2 | 4096 | | | | | | | |
| C3 | 8192 | | | | | | | |

---

## 6. Abandon criteria

No setting beats the default on S beyond noise.

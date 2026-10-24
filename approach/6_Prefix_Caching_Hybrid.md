# Approach 6: Prefix Caching (Hybrid Mode)

**Rank:** 6 · **Effort:** low · **Risk:** medium

**Goal:** skip re-reading shared prompt prefixes, mainly in multi-turn tool-calling and RAG requests, to cut prefill work, TTFT, and energy.

**One-line thesis:** agentic episodes (up to 15 turns) resend the whole conversation every turn. Reusing the cached prefix means only the new part needs prefill.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_E` | less prefill compute (the power-hungry phase) | ↑ |
| TTFT / SLO-met | shorter prefill on later turns | ↑ |
| `A` | outputs shouldn't change | neutral (verify) |

Our workload: 60 agentic tool-calling + 60 RAG requests, so there's plenty of shared text.
The briefing allows normal KV and prefix caching (only caching graded **responses** is banned).

Concepts: [Prefix Caching](../use_ur_brain/96_Prefix_Caching.md) · [Hybrid Cache and Kernels](../use_ur_brain/86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Agentic Workloads](../use_ur_brain/74_Agentic_Workloads_and_Multi_Turn.md)

---

## 2. Evidence

- vLLM docs: prefix caching is **off by default for hybrid models** and needs `--mamba-cache-mode align` ([vLLM docs](https://docs.vllm.ai/en/v0.30.0/features/automatic_prefix_caching/)).
- vLLM's hybrid cache manager sizes attention blocks to match the linear-attention state, so reuse works only in large whole blocks ([vLLM blog](https://vllm.ai/blog/qwen3-next); [community report](https://friendli.ai/models/Twu31/Qwen3.8-27B-AWQ-INT4-MTP-LowLatency)).
- LMCache docs disagree on whether Qwen3.5-style hybrids are supported ([LMCache](https://docs.lmcache.ai/mp/hybrid_models.html)); don't use LMCache, use vLLM's built-in caching.

---

## 3. Go/no-go preconditions

| # | Question | If "no" |
|---|---|---|
| 1 | Does our vLLM version have `--mamba-cache-mode`? | check `vllm serve --help`; skip if missing |
| 2 | Does the startup log say prefix caching is **enabled** (not auto-disabled)? | skip |
| 3 | Do the metrics show cache hits on a multi-turn test? | no reuse → no benefit; skip |

---

## 4. Proposed steps (untested — run on the VM to confirm)

Source: flags from the vLLM v0.30.0 prefix-caching docs; names may differ in our version.

```bash
vllm serve <model> --enable-prefix-caching --mamba-cache-mode align --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Start the server and read the startup log for the prefix-caching status.
2. Send a 3-turn tool-calling conversation; check the cache-hit metric rises.
3. Run Validation; compare TTFT for the agentic and RAG classes and total energy.
4. Optional follow-up: Approach 8 (BF16 Mamba state) may raise the hit rate.

---

## 5. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Silently disabled for this architecture | startup log | skip |
| Low hit rate (block size too large) | cache-hit metric | try Approach 8; otherwise drop |
| Cache overhead uses memory → fewer sequences | cache size in log | re-tune Approach 4 |
| Wrong outputs from state mismatch | accuracy, smoke tests | hard fail; disable |

---

## 6. Measurement sheet

| Run | Prefix cache | Hit rate | TTFT p95 agentic | TTFT p95 RAG | E (kJ) | SLO-met | η | Macro-acc | Decision |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| X0 | off | — | | | | | | | reference |
| X1 | on (align) | | | | | | | | |

---

## 7. Abandon criteria

Not supported, no hits, or any accuracy change.

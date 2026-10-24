# Approach 4: Batch Size (`max_num_seqs`)

**Rank:** 4 · **Effort:** low · **Risk:** low

**Goal:** find the largest number of concurrent sequences that still keeps TPOT p95 ≤ 50 ms at the 4 req/s peak, so each weight read is shared by as many requests as possible.

**One-line thesis:** decode reads all weights once per step regardless of batch size, so more sequences per step means fewer joules per token, until steps get slow enough to break TPOT.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_E` | weight reads amortized over more tokens | ↑ |
| SLO-met / `s_T` | less queueing at peak → fewer TTFT misses | ↑ |
| `s_L` (TPOT) | each step slower as batch grows | ↓ past the sweet spot |
| `A` | no effect | neutral |

Concepts: [Max Active Sequences](../use_ur_brain/94_Max_Active_Sequences.md) · [Batching](../use_ur_brain/55_Batching.md) · [Continuous Batching](../use_ur_brain/56_Continuous_Batching.md) · [Queueing](../use_ur_brain/67_Queueing.md)

---

## 2. Evidence

- Batching is the main decode throughput lever (roadmap Stage 6; vLLM tuning docs).
- Approach 1 (quantization) frees ~8–12 GB of VRAM, which is only useful if this limit is raised.

---

## 3. Proposed steps (untested — run on the VM to confirm)

Source: vLLM's `--max-num-seqs` flag; check the default for our version in `vllm serve --help`.

```bash
vllm serve <model> --max-num-seqs 128 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Sweep `--max-num-seqs` 64 → 128 → 192 → 256, one Validation run each.
2. Stop raising once SLO-met stops improving or TPOT p95 nears 50 ms.
3. **Re-tune** after every big change (quantized model, MTP, power cap); the best value moves.

---

## 4. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| TPOT p95 > 50 ms | latency report | step back one value |
| Preemptions (cache full) | vLLM metrics / logs | raise `--gpu-memory-utilization` or lower this value |
| Out-of-memory at startup | startup crash | lower value |

---

## 5. Measurement sheet

| Run | max_num_seqs | Preemptions | E (kJ) | SLO-met | η | s_E | TTFT p95 | TPOT p95 | Decision |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| B0 | default | | | | | | | | reference |
| B1 | 64 | | | | | | | | |
| B2 | 128 | | | | | | | | |
| B3 | 192 | | | | | | | | |
| B4 | 256 | | | | | | | | |

---

## 6. Abandon criteria

The default already gives the best S within noise; keep the default.

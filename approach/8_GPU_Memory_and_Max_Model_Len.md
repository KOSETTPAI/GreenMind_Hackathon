# Approach 8: GPU Memory Allocation and `max_model_len`

**Rank:** 8 · **Effort:** very low · **Risk:** low

**Goal:** give vLLM as much GPU memory for cache as is safe, and reserve only the context length the test actually needs.

**One-line thesis:** more cache memory → more concurrent sequences and fewer preemptions at peak. Reserving for a longer context than the test uses wastes that memory.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| SLO-met / `s_T` | fewer preemptions and less queueing at peak | ↑ |
| `s_E` | less recompute from preemption | ↑ slightly |
| Stability | too high → out-of-memory crash → whole submission fails | risk |

Concepts: [GPU Memory Allocation](../use_ur_brain/101_GPU_Memory_Allocation.md) · [Context Window](../use_ur_brain/26_Context_Window.md) · [Preemption](../use_ur_brain/97_Preemption.md)

---

## 2. Proposed steps (untested — run on the VM to confirm)

Source: vLLM flags `--gpu-memory-utilization` and `--max-model-len`.

The test has prompts up to 32K plus `max_tokens = 8192`, so `max_model_len` must be at least about **40,960**. Lower values make long requests fail.

```bash
vllm serve <model> --gpu-memory-utilization 0.92 --max-model-len 40960 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Check the startup log for the reported cache size / max concurrency.
2. Try 0.90 → 0.92 → 0.95.
3. Run the full Validation track at the highest value to confirm no out-of-memory crash under peak load.

---

## 3. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| Out-of-memory crash mid-run | server log | step back to the last stable value |
| `max_model_len` too small | requests rejected / errors on long-context class | raise to ≥ 40,960 |

---

## 4. Abandon criteria

No change in preemptions or SLO-met; keep the safer lower value.

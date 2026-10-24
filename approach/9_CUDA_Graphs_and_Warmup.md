# Approach 9: Keep CUDA Graphs On and Warm Up Before the Run

**Rank:** 9 · **Effort:** very low · **Risk:** low

**Goal:** make sure small decode steps aren't slowed by kernel-launch overhead, and that the first graded requests don't pay one-time compile costs.

**One-line thesis:** CUDA graphs replay pre-recorded GPU work with almost no CPU overhead. The hybrid model's Triton kernels compile on first use, so the first requests after startup are slow unless we warm up first.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| TPOT / TTFT on early requests | no compile or launch delay | ↑ |
| SLO-met during the ramp phase | fewer early misses | ↑ |
| `s_E` | less idle-waiting on CPU | ↑ slightly |

Concepts: [CUDA Graphs and Compilation](../use_ur_brain/100_CUDA_Graphs_and_Compilation.md) · [Launch Overhead](../use_ur_brain/41_Launch_Overhead.md) · [Model Loading and Warmup](../use_ur_brain/52_Model_Loading_and_Warmup.md)

---

## 2. Proposed steps (untested — run on the VM to confirm)

Source: vLLM enables CUDA graphs by default; `--enforce-eager` turns them off.

1. Make sure the launch command does **not** include `--enforce-eager`.
2. Check the startup log for CUDA graph capture.
3. After the server is up and **before** submitting, send a few warm-up requests: a short chat, a long (~20K) prompt, a tool call, a Thai prompt.

```bash
curl http://localhost:8000/v1/chat/completions -H "Content-Type: application/json" -d '{"model":"<model>","messages":[{"role":"user","content":"Hello"}],"max_tokens":16}'
```

4. Compare TTFT of the first 10 graded requests with and without warm-up.

Warm-up happens before the graded run, which is ordinary server preparation, not a setting that applies only during the measured window. Confirm with organizers if unsure.

---

## 3. Risks

Low. CUDA graphs use some extra GPU memory; if startup runs out of memory, lower `--gpu-memory-utilization` slightly.

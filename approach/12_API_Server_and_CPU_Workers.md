# Approach 12: API Server and CPU Worker Capacity

**Rank:** 12 · **Effort:** very low · **Risk:** low · **Verdict:** only if CPU-bound

**Goal:** make sure tokenization, streaming, and scheduling on the CPU aren't leaving the GPU idle.

**One-line thesis:** with 16 vCPUs, one API process can become the bottleneck at peak (long prompts, streaming); the GPU then waits and burns idle watts.

Concepts: [CPU and API Worker Capacity](../use_ur_brain/99_CPU_and_API_Worker_Capacity.md) · [Host System](../use_ur_brain/42_Host_System_CPU_RAM_Storage_Network.md)

---

## 1. Proposed steps (untested — run on the VM to confirm)

Source: vLLM `--api-server-count` flag; check it exists in our version.

1. During a Validation run, watch CPU with `htop` and GPU with `nvidia-smi dmon`.
2. **Only if** one CPU core sits at 100% while the GPU has idle gaps and requests are queued:

```bash
vllm serve <model> --api-server-count 2 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

3. Compare TTFT p95 and SLO-met.

---

## 2. Risks

Extra processes use memory and CPU. The briefing requires **one serving process**; confirm with organizers that vLLM's internal API workers count as one.

## 3. Abandon criteria

CPU isn't saturated → skip.

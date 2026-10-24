# Approach 13: Scheduling Policy

**Rank:** 13 · **Effort:** low · **Risk:** low · **Verdict:** probably not

**Goal:** change the order in which queued requests are served so more meet their TTFT SLO.

**Why it ranks low:**
- vLLM's alternative to first-come-first-served is `--scheduling-policy priority`, which uses a per-request `priority` field. The grader's requests won't set it, so every request gets the same priority and nothing changes.
- A custom policy (for example, shortest-prompt-first) would mean modifying vLLM's scheduler: high effort, and it risks starving long requests past their SLO.

Concepts: [Scheduling Policy](../use_ur_brain/98_Scheduling_Policy.md) · [Scheduler and Request Queue](../use_ur_brain/57_Scheduler_and_Request_Queue.md) · [Queueing](../use_ur_brain/67_Queueing.md)

---

## 1. Proposed steps (untested — run on the VM to confirm)

None recommended. Keep the default first-come-first-served policy unless profiling shows long prompts blocking many short ones at peak; in that case tune chunked prefill first (Approach 5).

## 2. Abandon criteria

Already abandoned unless Approach 5 fails to fix TTFT misses at peak.

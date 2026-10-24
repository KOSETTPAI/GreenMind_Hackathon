# Approach 2: Fixed GPU Power Cap

**Rank:** 2 (best value for effort) · **Effort:** very low · **Risk:** low–medium

**Goal:** lower GPU energy over the whole window by capping power draw, while keeping TPOT ≤ 50 ms and the SLO-met count unchanged.

**One-line thesis:** decode is memory-bound, so a lower power limit cuts watts much more than it slows generation. Energy = power × time, and power falls faster than time rises, down to a sweet spot.

> Expected gains come from published studies on other models. Only measured results on our workload count.

---

## 1. Why it helps the score

| Component | Mechanism | Expected direction |
|---|---|---|
| `s_E` | lower watts during busy time; time rises only slightly | ↑ |
| SLO-met count | unchanged if TPOT/TTFT stay within limits | neutral; ↓ if cap too low |
| `s_L`, `s_T` | slightly slower steps | ↓ slightly |
| `A` | no effect on outputs | neutral |

Energy has exponent 0.6; latency and throughput have 0.2 each and saturate at 1. Trading a little speed for energy is usually a win as long as SLOs hold.

Concepts: [GPU Power Caps and Clocks](../use_ur_brain/122_GPU_Power_Caps_and_Clocks.md) · [Watts vs Joules](../use_ur_brain/50_Watts_vs_Joules.md) · [Compute-Bound vs Memory-Bound](../use_ur_brain/39_Compute_Bound_vs_Memory_Bound.md)

---

## 2. Evidence

- A100, LLaMA-65B: 250 W → 175 W gave **~23% less energy** for **~6.7% more time** ([arXiv 2310.03003](https://arxiv.org/pdf/2310.03003)).
- HPC-scale follow-up: 175 W → 5–8% slower, 22–24% less energy; 150 W saved a little more but slowed things noticeably ([arXiv 2402.18593](https://arxiv.org/pdf/2402.18593)).
- A100 decode draws ~50–60% of TDP; prefill 75–100% ([arXiv 2604.10852](https://arxiv.org/pdf/2604.10852)), so the headroom is mainly in decode.
- Energy vs clock is U-shaped: too low wastes energy again because runtime dominates ([arXiv 2509.04827](https://arxiv.org/pdf/2509.04827v1)).
- Long-input requests are frequency-sensitive; short-input/long-output requests are not ([DynamoLLM, arXiv 2408.00741](https://arxiv.org/html/2408.00741v1)). Watch TTFT on our RAG / 32K requests.

---

## 3. Go/no-go preconditions

| # | Question | If "no" |
|---|---|---|
| 1 | Do we have `sudo` for `nvidia-smi` on the VM? | ask organizers; skip approach |
| 2 | Briefing: a fixed power limit is allowed if constant for the whole run | — |
| 3 | What are the card's min/max power limits? | pick the sweep inside that range |

---

## 4. Proposed steps (untested — run on the VM to confirm)

Source: standard `nvidia-smi` options; the wattage range comes from the studies above.

```bash
nvidia-smi -q -d POWER,CLOCK
```
```bash
sudo nvidia-smi -pm 1
```
```bash
sudo nvidia-smi -pl 200
```

1. Sweep **250 → 200 → 175 → 150 W**, one Validation run each, same server config.
2. Keep the cap with the best estimated S (not the lowest watts).
3. **Re-run the sweep at the end** on the final config (quantized model + MTP + batching); the best cap usually moves.
4. Set the cap **before** the submission starts and leave it unchanged until the run ends.

---

## 5. Risks and mitigations

| Risk | Signal | Mitigation |
|---|---|---|
| TPOT p95 > 50 ms at peak | latency report | raise cap one step |
| TTFT misses on long RAG / 32K prompts | TTFT p95 by class | raise cap; tune chunked prefill (Approach 6) |
| Joules go **up** (too slow) | E (kJ) rises vs previous cap | past the U-curve minimum; go back one step |
| Cap lost after reboot | check `nvidia-smi` before each submission | put the cap in the startup script |

---

## 6. Measurement sheet

| Run | Power cap | Avg W | E (kJ) | SLO-met | η | η/η_base | s_E | TTFT p95 | TPOT p95 | Decision |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| P0 | default | | | | | | | | | reference |
| P1 | 250 W | | | | | | | | | |
| P2 | 200 W | | | | | | | | | |
| P3 | 175 W | | | | | | | | | |
| P4 | 150 W | | | | | | | | | |

---

## 7. Abandon criteria

No `sudo` / not permitted, **or** every cap below default lowers SLO-met enough that η doesn't improve beyond noise.

## 8. Pitch angle

"Same answers, X% fewer joules, by running the GPU at its efficient point instead of its peak." Easy to explain and holds at production scale.

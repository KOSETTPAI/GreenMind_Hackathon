# Module 07: Forensic Case Study — The 95.6 Illusion to 100.0

---

## 1. The Forensic Post-Mortem: Why Did Attempt 7 Score 95.6?

During the GreenMind Hackathon, our team witnessed a wild score oscillation that confused everyone on the team:

| Submission | Track | Container State | Score S | $p_{95}\text{ TTFT}$ | $p_{95}\text{ TPOT}$ | SLO-Met | Prefix Cache Hit Rate |
|---|---|---|---:|---:|---:|---:|---:|
| **Attempt 6 (11:27)** | Validation (100 reqs) | Cold Container | **35.6** | 2.47 s | 55 ms | 57 / 100 | 15% |
| **Attempt 7 (11:45)** | Validation (100 reqs) | **Warm Container (Un-restarted!)** | **`95.6`** | **0.16 s** | **18 ms** | **98 / 100** | **87%** |
| **Final Run (11:54)** | Final Test (300 reqs) | Attempt 7 Server under load | **`19.1`** | **2.16 s** | **82 ms** | **127 / 300** | **44%** |
| **Attempt 10 (17:27)**| Validation (100 reqs) | Fresh Container (Cold) | **35.3** | 2.41 s | 66 ms | 54 / 100 | ~15% |

---

## 2. Unmasking the 95.6 Score: The Warm Cache Illusion

### What Really Happened in Attempt 7:
1. Attempt 6 was submitted at 11:27. The server processed all 100 validation questions.
2. The team did **NOT** restart the container before Attempt 7.
3. When Attempt 7 submitted the exact same 100 validation questions 18 minutes later, vLLM's Radix tree found almost every single prompt already cached in GPU memory!
4. The cache hit rate skyrocketed to **87%**:
   * Prefill computation was bypassed entirely $\to p_{95}\text{ TTFT}$ dropped from $2.47\text{ s} \to \mathbf{0.16\text{ s}}$!
   * The GPU was completely relieved of prefill compute $\to p_{95}\text{ TPOT}$ dropped to $\mathbf{18\text{ ms}}$!
   * 98 out of 100 requests met the strict latency SLO $\to$ Score exploded to **95.6**.

### Why It Collapsed to 19.1 on the Final:
* The Validation track only sends **100 requests**.
* The Final track sends **300 requests**, and the 4 req/s burst peak lasts 3x longer.
* When requests 101 to 300 arrived, the cache hit rate dropped from $87\% \to 44\%$.
* Concurrency exploded to **111 concurrent requests**.
* Under default `max_num_batched_tokens = 2048`, prefill chunks collided with ongoing decodes, causing TPOT to blow out to **82 ms** (violating the $\le 50\text{ ms}$ SLO). Over half the requests were disqualified, collapsing the score to **19.1**.

> ⚠️ **Key Takeaway**: A warm validation cache is an artificial benchmark artifact. In production, traffic is bursty, prompts are non-identical, and servers must withstand sustained concurrency without prefill-decode collision!

---

## 3. The 100.0 Engineering Recipe (How the Top Teams Won)

To achieve a **100.0 perfect technical score**, all four terms in the scoring equation must saturate at $1.0$:

$$S = 100 \cdot A \cdot s_E^{0.6} \cdot s_T^{0.2} \cdot s_L^{0.2}$$

```
                ┌────────────────────────────────────────────────────────┐
                │             THE 100.0 PRODUCTION RECIPE                │
                └────────────────────────────────────────────────────────┘
                                            │
        ┌───────────────────┬───────────────┴───────────────┬───────────────────┐
        ▼                   ▼                               ▼                   ▼
   [ A = 1.00 ]       [ s_T = 1.00 ]                  [ s_E = 1.00 ]       [ s_L = 1.00 ]
  (Accuracy Gate)    (Throughput Gate)               (Energy Dominance)   (Latency Target)
        │                   │                               │                   │
  AWQ W4A16 Marlin    --max-num-batched-             GREENMIND_POWER_W=   --attention-backend
  weights maintain    tokens 8192 absorbs            250 slashes active   FLASHINFER keeps
  >99% of baseline    burst prefills, keeping        board Joules below   p95 TPOT < 25ms and
  macro-accuracy.     100/100 requests in SLO.       190 J/req (3x base). p95 TTFT < 0.3s.
```

### The Component Breakdown:

1. **$A = 1.00$ (Accuracy Retention $R \ge 0.98$)**:
   * `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16`: Calibrated with 512 domain-mixed samples. Keeps $R = 0.997 \sim 1.003$ of full BF16 accuracy.

2. **$s_T = 1.00$ (Throughput: 100% of Peak Requests Met SLO)**:
   * Fixes the prefill collision via `--max-num-batched-tokens 8192`. Prompts are digested in 1–2 dense steps, isolating decodes into pure decode mode.

3. **$s_E = 1.00$ (Energy Efficiency $\eta \ge 3\times$ Baseline)**:
   * Full energy marks requires $\le 216\text{ Joules/request}$ on Validation ($\le 204\text{ J}$ on Final).
   * Clamping power from 400 W $\to$ **250 W** (`nvidia-smi -pl 250`) cuts power by 37.5%, driving active energy down to **$\approx 175 - 185\text{ Joules/request}$**!

4. **$s_L = 1.00$ (Latency Saturation)**:
   * FlashInfer backend (`--attention-backend FLASHINFER`) and CUDA graph capture eliminate kernel launch overhead.

$$S = 100 \cdot (1.00) \cdot (1.00)^{0.6} \cdot (1.00)^{0.2} \cdot (1.00)^{0.2} = \mathbf{100.0}$$

---

## 4. Final Systems Engineering Checklist for Production

Before deploying any LLM serving stack into a high-concurrency production environment:

- [ ] **Quantize to hardware strengths**: Use W4A16 Marlin on Ampere (A100); use FP8 on Ada/Hopper (H100).
- [ ] **Match context length to reality**: Set `--max-model-len` to cover full prompt + maximum generation without wasting VRAM.
- [ ] **Eliminate prefill-decode interference**: Tune `--max-num-batched-tokens` to 4096 or 8192 to prevent mixed-step TPOT blowouts.
- [ ] **Enable Radix / Prefix Caching**: Essential for agentic tool calling and multi-turn chat.
- [ ] **Clamp GPU TDP**: Running at 250W–275W saves ~35% energy with virtually zero impact on memory-bound decode latency.
- [ ] **Pre-compile CUDA Graphs**: Always run a warmup request sequence before opening user traffic to prevent cold-start latency penalties.

# GreenMind Hackathon — Repository Overview

Team 17's working repository for the GreenMind AI Hackathon (CMKL University, 24–25 October 2026): serve `MANGO1.5-Qwen3.5-9B` on one A100 so it answers a hidden 300-request workload accurately, within latency SLOs, on as few GPU joules as possible.

This file is the map. It covers what the event measures, the concepts behind the work, every approach the team considered, what is running now (run4) and how it scored, and what to try next.

**Status at 24 Oct 2026, 17:30 (UTC+7):** run4 `full` tier is deployed. Validation `S = 32.8` (below V0's 34.8). First Final `S = 0.0`. Final submissions close **25 October 2026, 11:00**.

---

## 1. The event in one page

### Final ranking

```
F = 0.4 × R1 (technical score S) + 0.6 × R2 (pitch)
```

Only the top eight teams by best Final `S` pitch. The pitch is 7 minutes plus 7 minutes Q&A, judged on technical approach and trade-offs (40%), sustainability impact (40%), and clarity (20%). Before pitching, teams submit a GitHub link with experiments, configs, results, **and failed attempts**, plus slides and a statement of which weights were used.

### Technical score

```
S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2
```

| Symbol | Meaning | Formula |
| --- | --- | --- |
| `A` | Accuracy gate, 0.05–1 | `R = macro-accuracy / baseline`; `A = smoothstep((R − 0.85) / 0.13)`. Full at `R ≥ 0.98`. A task family (≥ 20 items) under 75% of its baseline accuracy multiplies `A` by a penalty |
| `s_E` | Energy | `η = SLO-met requests / GPU joules`; `s_E = clip(ln(η / η_base) / ln 3, 0, 1)` |
| `s_T` | Throughput | Share of **peak-phase** requests (4 req/s) that met SLO |
| `s_L` | Latency | `√( min(1, 1 / p95(TTFT / TTFT_SLO)) × min(1, 50 ms / p95 TPOT) )` |

Energy carries exponent 0.6, so `η` dominates. The untuned BF16 baseline scores `S = 0` by construction (`η = η_base` gives `s_E = 0`).

| Constant | Validation page | Final page |
| --- | --- | --- |
| `η_base` | 0.00154 SLO-met req/J | **0.00163** SLO-met req/J |
| Reference macro-accuracy | 87.2% | 87.8% |
| Full energy marks (3×) | ≈ 216 J per SLO-met request | ≈ 204 J per SLO-met request |

The Final baseline is about 6% harder than the Validation one. **Only the Final counts.** Validation is a practice track for checking that a server works, and its score does not predict the Final: run6 scored 95.6 on Validation and 19.1 on Final, because the Final's longer peak drove concurrency from 35 to 111 running requests and p95 TPOT from 18 ms to 82 ms.

### What counts as SLO-met

All five must hold:

1. Streamed response.
2. No error, no timeout (900 s).
3. Not cut off at 8192 output tokens.
4. TTFT ≤ `0.5 s + 0.25 s × prompt_tokens / 1000` (300 tokens → 0.575 s; 20 000 → 5.5 s).
5. TPOT ≤ 50 ms (skipped for one-token answers).

Failed, late, and cut-off requests still cost joules. Idle GPU energy inside the timed window counts. Work unfinished at 30 minutes fails.

### Hidden workload (Final: 300 requests)

| Class | Requests |
| --- | --- |
| Chat / instructions | 90 |
| RAG / long documents | 60 |
| Agentic tool calling (up to 15 turns) | 60 |
| Reasoning, math, code | 45 |
| Thai | 30 |
| Long context (up to 32K) | 15 |

Open-loop load: ramp 0 → 4 req/s, constant 4 req/s peak, then 1 req/s quiet. Thinking on, `max_tokens = 8192`, `temperature = 0`, `tool_choice = auto`. Validation is 100 requests of the same shape and is indicative only.

Limits: Validation 5 finished submissions per hour, Final 2 per hour.

### Hardware and model

| Item | Value |
| --- | --- |
| GPU | 1 × A100-SXM4 40 GB (PCI passthrough), driver 580 |
| Host | 16 vCPU EPYC 7742, 48 GB RAM, Ubuntu 24.04, Docker |
| VM | `researcher@gm17`, public IP `103.153.118.56` |
| Baseline model | `CMKL/MANGO1.5-Qwen3.5-9B`, BF16, default `vllm serve` |
| Model we serve | `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, served as `mango1.5-awq-w4a16` |
| Architecture | 32-layer hybrid: Gated DeltaNet (linear attention, recurrent state) in 3 of 4 layers, full attention every 4th layer. Only about 8 layers keep a KV cache |
| Quantization | AWQ W4A16 asymmetric, group 128, Marlin kernels on Ampere. MTP draft head kept in BF16 (original Qwen3.5 head; model card reports 64–76% draft acceptance) |

### Rules that bound the search

Banned, with disqualification risk (`approach/18_Not_Allowed.md`): changing clocks or power during a run, settings that apply only in the measured window, caching graded responses, `LD_PRELOAD` or NVML tampering, other GPU work or external calls during a graded run, closed-source software, calibration data containing test questions, and reconstructing the hidden test set. The grader fixes `max_tokens`, temperature, thinking mode, and sampling; the server must not override them. One serving process.

---

## 2. Repository map

| Path | What it is |
| --- | --- |
| `greenmind_ai_hackathon_research_brief.md` | Event facts, workload, scoring, rules, references. The primary source |
| `scoring_criteria.md` | Scoring formulas worked through, with the live constants |
| `GreenMind_Inference_Optimization_Roadmap.md` | Long-form learning roadmap and dependency map of concepts |
| `Score_Improvement_Ranking.md` | Why approaches are ranked as they are (energy budget, idle cost), with sources |
| `aboutmodel.md` | Model card of the AWQ-W4A16-mtp checkpoint |
| `GreenMind_Participant_Briefing.pdf` | Official briefing (untracked) |
| `use_ur_brain/` | 130 concept notes, numbered in learning order |
| `approach/` | 18 optimization approaches, one file each; file number = rank |
| `scripts/` | V0 launcher `start-vllm.sh` and smoke tests (`test-chat.sh`, `test-stream.sh`, `test-tool-calling.sh`) |
| `deployment/README.md` | How V0 was deployed and smoke-tested |
| `experiments/` | One-flag experiment ladder (E1–E7), shared launcher, warmup, power-cap scripts, `log.md`, `results/` |
| `experiments_thyme/` | Alternative harness: one config per approach value (`A00`–`A13`), separate container `thyme-vllm`. Untested |
| `run4/` | **Current approach**: combined server with tiers, preflight, warmup, telemetry, power control |

---

## 3. Concepts

`use_ur_brain/0_Learning_Path_Index.md` orders 130 notes in stages. Each note gives a definition, technical depth, an analogy, why it matters here, and common mistakes.

| Stage | Topics | Why it matters for the score |
| --- | --- | --- |
| 0\. Evaluator | Hard gates, score components, baseline, Validation vs Final, workload mix, measurement window, energy boundary, allowed artifacts, SLO, useful requests | Defines what earns points and what disqualifies |
| 1\. LLM basics | Weights, tokens, attention, MLP, sampling, autoregressive generation, context window, chat templates | Prompt and output token counts drive prefill and decode cost |
| 2\. GPU and precision | SMs, tensor cores, HBM bandwidth, arithmetic intensity, compute- vs memory-bound, FP32/BF16/FP8/INT4, watts vs joules, NVML | Decode at small batch is memory-bound (INT4 helps); at large batch it becomes compute-bound (spec decoding helps less) |
| 3\. Serving | Prefill, decode, continuous batching, scheduler and queue, concurrency, backpressure, streaming, TTFT, TPOT, percentiles, queueing, load phases, open-loop load, tool calling, agentic multi-turn, RAG, KV cache | TTFT is mostly queueing plus prefill; TPOT is decode step time divided by tokens per step |
| 4\. Hybrid architecture | SSM, recurrent state, Mamba, linear attention, delta rule, gating, Gated DeltaNet, hybrid cache | Prefix caching needs `--mamba-cache-mode align`; the KV cache is small, so memory is rarely the limit |
| 5\. Harness | Reproducibility, smoke testing, measurement harness, experiment log, run-to-run variance, profiling | One change per run, logged against a fixed reference |
| 6\. Low-risk tuning | Batched-token budget, max active sequences, chunked prefill, prefix caching, preemption, scheduling policy, API workers, CUDA graphs, memory allocation | The levers run4 uses and the next ones to try |
| 7\. Model-level | Quantization, W4A16, calibration, AWQ, pruning, conversion, distillation, kernel fusion, FlashAttention, speculative decoding, MTP, engines (vLLM, SGLang, TensorRT-LLM, llama.cpp), migration gate | Mostly decided: AWQ checkpoint adopted, engine switch rejected |
| 8\. Score-aware decisions | Accuracy, per-class and macro accuracy, retention, energy per useful request, power caps and clocks, clipping and saturation, bottleneck diagnosis, controlled experiments, submission discipline, final pitch | How to read a History row and choose the next run |

Three ideas carry most of the reasoning:

1. **A late answer is pure cost.** It adds joules and nothing to `η`. Rescuing SLO misses is the cheapest energy win.
2. **Idle joules count.** A shorter busy window matters more than a lower instantaneous watt reading.
3. **Lower watts only after SLO-met is high.** A power cap slows decode, pushes TPOT past 50 ms, and shrinks the numerator of `η`.

---

## 4. Approaches considered

From `approach/README.md`, ranked by expected gain ÷ (effort + risk).

| Rank | Approach | Status |
| --- | --- | --- |
| 1 | Baseline and measurement | V0 measured (S = 34.8). History rows partly missing |
| 2 | Fixed GPU power cap (250 → 200 → 175 W) | Waiting: needs SLO-met ≥ 90/100 |
| 3 | Weight-only quantization | **Adopted**: provided AWQ W4A16 checkpoint |
| 4 | MTP speculative decoding | In run4 `full` (k = 1). Not helping under load (see §6) |
| 5 | `--max-num-seqs` | Deprioritized: peak concurrency estimated at 40–60, under the default |
| 6 | `--max-num-batched-tokens`, chunked prefill | **Not yet tested. Now the top lever** |
| 7 | Prefix caching (hybrid, `align`) | In run4 `full`. Effect not isolated |
| 8 | GPU memory 0.90, `--max-model-len 40960` | In run4. 40960 is required (32K prompt + 8192 output) |
| 9 | Mamba state in BF16 | If time; long-context accuracy risk |
| 10 | CUDA graphs on, warmup | On by default; `run4/warmup.py` before Submit |
| 11 | Fixed clock lock | Maybe, after the power sweep |
| 12 | Extra API servers | Rules say one serving process |
| 13 | FP8 KV cache | Probably not: A100 has no FP8 math, small KV share |
| 14 | Scheduling policy | Grader sets no priority; expected gain zero |
| 15 | External draft model | No: its energy counts |
| 16 | Engine switch | No: migration risk too high for the time left |
| 17 | Pruning, fine-tuning, custom kernels | No |
| 18 | Dynamic clocks, response caching, NVML changes | **Never**: disqualification |

Three launch harnesses implement these:

- `experiments/`: one flag per script on top of V0 (`01-max-model-len` … `07-power-cap`), with `adopted.env` to carry kept wins forward.
- `experiments_thyme/`: one config file per approach value in a separate `thyme-vllm` container, with its own preflight, telemetry, and grader-shaped smoke test. Never run.
- `run4/`: one combined launch with a fallback ladder. Built because the one-flag ladder needs about seven Validations before Final. This is what is deployed.

---

## 5. Current approach: run4

Details: `run4/README.md`, `run4/PLAN.md`, `run4/ENDPOINT_RUNBOOK.md`.

### Server (tier `full`, `run4/profiles/r4-full.args`)

```
CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp
--host 0.0.0.0 --port 8000
--served-model-name mango1.5-awq-w4a16
--trust-remote-code
--gpu-memory-utilization 0.90
--max-model-len 40960
--enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser qwen3
--speculative-config {"method":"mtp","num_speculative_tokens":1}
--enable-prefix-caching --mamba-cache-mode align
```

Image `vllm/vllm-openai:nightly`. No power cap.

| Change from V0 | Intended effect |
| --- | --- |
| `--max-model-len 40960` (was 32768) | Long prompts plus 8192 output fit |
| MTP k = 1 | Fewer decode steps per token: lower TPOT and joules, shorter runaway-math tail |
| Prefix caching, `align` | Less prefill on multi-turn agentic and RAG traffic |
| Memory 0.90 (was 0.85) | Headroom for MTP state, cache blocks, and 40960 context |

### Fallback tiers

| Tier | Profile | Difference |
| --- | --- | --- |
| `full` | `r4-full.args` | Everything above |
| `no-prefix` | `r4-no-prefix.args` | Drops prefix caching |
| `no-mtp` | `r4-no-mtp.args` | Drops MTP |
| `safe` | `e1.args` | E1: V0 + 40960 context |
| `full-k2` | `r4-full-k2.args` | MTP k = 2; needs `CONFIRM_K2=1` |

### Tooling

| File | Role |
| --- | --- |
| `start.sh` | Launches a tier with the same `docker run` as `scripts/start-vllm.sh`, waits for `/v1/models`, saves startup facts to `~/greenmind-runs/<time>_r4-<tier>/`, runs the preflight. Bind defaults to `127.0.0.1`; `BIND=0.0.0.0` publishes publicly; `REPLACE=1` keeps the old bind |
| `preflight.sh`, `preflight_checks.py` | Read-only checks: container state, port bind, exact vLLM args against the profile, served model and context, chat, streaming with usage, streaming tool call, thinking on |
| `check-external.ps1` | From a PC: TCP reach, `/models`, one chat over the public IP |
| `flag-check.sh` | Confirms flags exist in the image without using the GPU |
| `warmup.py` | Grader-shaped warmup, including a two-turn tool episode. Run right before Submit |
| `watch.sh`, `summarize.py` | 1 s telemetry (NVML energy, running/waiting, preemptions, prefix hits, MTP acceptance) and its summary. Validation only |
| `power.sh` | Show, set, or restore one constant power limit |

### Deployment lesson

The grader calls `http://103.153.118.56:8000/v1` from outside the VM. `start.sh` defaults to a loopback bind, which made the health check fail with `ConnectError`. The container now runs with `BIND=0.0.0.0 REPLACE=1 ./run4/start.sh full`. Every relaunch must keep `BIND=0.0.0.0` (or use `REPLACE=1`, which inherits it), and be checked from outside the VM.

---

## 6. Results so far

| Run | Server | S | A | s_E | s_T | s_L | η vs base | J/req | p95 TTFT | p95 TPOT | SLO-met | Accuracy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V0, Validation | `scripts/start-vllm.sh` defaults | 34.8 | – | – | – | – | – | – | – | – | 56/100 | – |
| E1, Validation 07:56 UTC | V0 + 40960 context | not copied | – | – | – | – | – | – | – | – | – | 52/63 visible |
| R4-full, Validation 09:47 UTC | run4 `full` | 32.8 | 1.00 | 0.30 | 0.32 | 0.45 | 1.38× | 235 | 3.12 s | 55 ms | 50/100 | 86.9% |
| R4-full, **Final** 09:40 UTC | run4 `full` | **0.0** | 1.00 | 0.00 | 0.05 | 0.31 | 0.92× | 208 | 3.59 s | 91 ms | 93/300 | 88.4% |

Raw console output: `run4/validation_log.md` (Validation) and `run4/log.md` (Final). E1 details: `experiments/results/2026-10-24T075639Z-validation.md`.

### What the numbers say

**Accuracy is not the problem.** `A = 1.00` and retention is about 1.0 in both runs. The same agentic tasks fail under E1 and R4-full (`ag073_pages_agg`, `ag018_kv_prefix_sum`, `ag032_orders_policy`), so those failures come from the model, not the server.

**The Final scored 0 because efficiency fell under the baseline.** 93 SLO-met requests over about 62.4 kJ is `η ≈ 0.00149`, which is 0.92× the Final baseline of 0.00163. `s_E` clips to 0 and zeroes `S`.

**Late first tokens cause most misses, not slow decoding.** Splitting `s_L` with `s_L² = s_TTFT × s_TPOT`:

| Run | `s_TPOT = 50 / p95 TPOT` | `s_TTFT` | p95 of TTFT ÷ its SLO |
| --- | --- | --- | --- |
| Validation | 0.91 | 0.22 | ≈ 4.5× |
| Final | 0.55 | 0.17 | ≈ 5.7× |

Requests wait in the prefill queue. The startup log shows the likely cause:

```
max_num_scheduled_tokens is set to 2048 based on the speculative decoding settings ...
Consider increasing max_num_batched_tokens
```

At 2048 tokens per scheduler step, a 20–32K-token prompt takes 10–16 steps. Under 4 req/s, long RAG and long-context prompts pile up, and short requests (TTFT SLO about 0.6 s) wait behind them.

**MTP is not paying off under load.** Matching tasks run as fast or slower than under E1 (`mxv2_416_instruction` 12.6 → 14.1 s, `mxv2_425_instruction` 14.8 → 16.7 s, `ag057_calc_chain` 16.8 → 17.5 s). At high concurrency the GPU is compute-bound, so draft verification costs about what it saves, and MTP also triggered the 2048-token scheduler cap. MTP did shorten the math tail: `mxv2_134_math` passed in 61.6 s, where it failed at 75 s under E1.

**R4-full is below V0** (32.8 vs 34.8, 50 vs 56 SLO-met). The run4 decision table says to drop a tier.

**The Final may have shared the GPU with the Validation.** The Final's requests began at 09:42:30 and the Validation started at 09:47:19. If the 300-request Final was still running, both loads hit the same server, which would explain its 91 ms TPOT and 0.05 `s_T`. Confirm on the grader. The Final was also submitted before any Validation of this configuration, which skipped `run4/PLAN.md` step 8.

### Energy headroom

| Scenario | SLO-met | Joules | η vs base | `s_E` |
| --- | --- | --- | --- | --- |
| R4-full Validation | 50/100 | ≈ 23.5 kJ | 1.38× | 0.30 |
| Same joules, more SLO-met | 90/100 | ≈ 23.5 kJ | ≈ 2.49× | ≈ 0.83 |
| Final at the same J/request | 270/300 | ≈ 62.4 kJ | ≈ 2.65× (Final base) | ≈ 0.89 |

Raising SLO-met is worth far more than shaving joules.

---

## 7. Next approaches and implementation plan

Goal for the remaining time: Final `S` = 99.9 against the Final baseline (η_base 0.00163, macro-accuracy 87.8%). The live schedule, the run folders, and the 99.9 arithmetic are in [CYCLE_PLAN.md](CYCLE_PLAN.md). The ladder below is the earlier plan. It is superseded: run6 already scored 95.6 on Validation and 19.1 on the Final, and the next folders are `run17-val1` onward.

### Step 0: housekeeping (no submission)

1. Check on the grader whether the Final that counts is the latest or the best. If it is the latest, do not submit another Final until a Validation clearly beats V0.
2. Check whether the Final and Validation overlapped. Never submit while another run is in progress.
3. Restore the run4 ledger: `git checkout run4/log.md`, move the Final console paste to its own file (for example `run4/final_log.md`), and fill the Submissions table from History. Copy the E1 History row too.
4. Record the image digest: `docker inspect mango-vllm --format '{{.Image}}'`.

### Step 1: local load replay to test configs without spending Validations

Validation is capped at 5 per hour and is noisy. A local replay at the grader's arrival rate ranks configs faster. Use synthetic prompts, never test questions.

1. Run `./run4/watch.sh` during the next Validation, then `python3 run4/summarize.py`. Take the prompt-length and output-length distributions, peak running/waiting counts, prefix-hit rate, and MTP acceptance from vLLM's `/metrics`.

2. Replay a similar load from inside the container:

   ```bash
   docker exec mango-vllm vllm bench serve \
     --base-url http://127.0.0.1:8000 --model mango1.5-awq-w4a16 \
     --dataset-name random --random-input-len 4000 --random-output-len 1500 \
     --request-rate 4 --num-prompts 300
   ```

   Set the lengths from step 1. Check flag names with `--help`; nightly builds change them.

3. Compare configs on p95 TTFT, p95 TPOT, and the share of requests meeting both SLOs. Submit only the winner.

Never run this while a graded run is in progress. It says nothing about accuracy, so Validations still confirm.

### Step 2: Validation ladder, one change each

| \# | Config | Change | Hypothesis | Keep if |
| --- | --- | --- | --- | --- |
| 1 | `no-mtp` (exists) | Drop MTP | MTP costs compute at high batch and caps the scheduler at 2048 tokens. Without it, TTFT drops and TPOT stays near 50 ms | SLO-met and `S` beat R4-full (50/100, 32.8) |
| 2 | Winner of #1 + `--max-num-batched-tokens 8192` | Bigger prefill budget per step | Long prompts prefill in 4 steps instead of 16, so short requests stop queueing. Main TTFT lever | SLO-met up and p95 TPOT ≤ about 50 ms |
| 3 | Winner + `--max-num-batched-tokens 4096` | Smaller budget | Only if #2 pushed TPOT over 50 ms: trade some TTFT back for TPOT | Better `S` than #2 |
| 4 | Winner ± prefix caching (`no-prefix` tier) | Isolate prefix caching | `align` mode raised the attention block size to 528 tokens and padded 12.5% of KV memory. Check its hit rate pays for that | Hit rate is non-zero and `S` holds |
| 5 | Winner + MTP k = 1, if #1 lost | Re-add MTP with the larger budget | With the scheduler budget raised, MTP may help again | Higher `S` and clean tool calls |
| 6 | Power cap 250 → 200 → 175 W (`run4/power.sh`) | Constant cap set before launch | Fewer joules at the same SLO-met | Only once SLO-met ≥ 90/100; keep the cap with the best `S` |
| 7 | Confirmation Validation, then **one Final** | Nothing changes | Reproduces the best row | `warmup.py` passes right before Submit; GPU idle otherwise |

Candidates to try only if the ladder stalls, after checking flag support with `vllm serve --help`:

- `--max-num-partial-prefills`, `--max-long-partial-prefills`, `--long-prefill-token-threshold`: let short prompts prefill alongside a long one, which targets exactly the short-request TTFT misses. Support in vLLM's V1 engine varies by version.
- `--gpu-memory-utilization 0.92`: only if `summarize.py` shows preemptions.
- `--mamba-ssm-cache-dtype bfloat16` (approach 9): only if concurrency at 40960 turns out to limit the peak.

Not worth trying now: `--max-num-seqs` caps (TTFT is the problem, and a cap adds queueing), FP8 KV cache, extra API servers, engine switches, new quantizations.

### Implementing a new tier

`start.sh` only accepts the tiers in its `case` statement, and `preflight.sh` rejects any container whose arguments differ from its profile. To add, for example, `no-mtp` plus an 8192 budget:

1. Copy `run4/profiles/r4-no-mtp.args` to `run4/profiles/r4-no-mtp-mbt8k.args` and add one line: `--max-num-batched-tokens 8192`.

2. Add a case to `run4/start.sh`:

   ```bash
   no-mtp-mbt8k) PROFILE_FILE="$HERE/profiles/r4-no-mtp-mbt8k.args" ;;
   ```

   and add the tier name to the "Unknown tier" message.

3. On the VM, without touching the running server:

   ```bash
   ./run4/flag-check.sh no-mtp-mbt8k
   ```

4. Launch with the public bind kept, then verify from outside:

   ```bash
   BIND=0.0.0.0 REPLACE=1 ./run4/start.sh no-mtp-mbt8k
   curl -sS --max-time 10 http://103.153.118.56:8000/v1/models   # from your laptop
   python3 run4/warmup.py
   ./run4/watch.sh        # second shell, Validation only
   ```

5. Submit one Validation. Afterwards, run `python3 run4/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track validation` and log the History row and summary in `run4/log.md`.

### Decision rules

| Result vs the best row so far | Next |
| --- | --- |
| `start.sh` says NOT READY | Next config, no submission spent |
| SLO-met or `S` lower | Revert that change |
| `S` higher, SLO-met under 90/100 | Keep, continue the ladder |
| `S` higher, SLO-met ≥ 90/100 | Keep, then the power sweep |
| Any family accuracy drop | Revert |

### Rough timeline

| When | What |
| --- | --- |
| 24 Oct evening | Step 0, telemetry on one Validation, local replay, ladder steps 1–3 |
| 24 Oct night | Ladder steps 4–5, power sweep if SLO-met ≥ 90 |
| 25 Oct morning, before 10:00 | Confirmation Validation, then one Final with nothing changed in between and nothing else on the GPU |
| 25 Oct 11:00 | Final submissions close |

---

## 8. Pitch preparation

The pitch is 60% of the final score, and judges weigh trade-offs and failed experiments. The repo already holds most of that material:

- **Baseline comparison:** V0 → E1 → R4-full → the configs above, each with its History row.
- **Failed experiments, with reasons:** R4-full's MTP regression under load, the loopback-bind health-check failure, and the Final scored at 0.0 and why.
- **Sustainability argument:** joules per SLO-met request against the baseline (about 649 J on the Validation baseline). The target is ≤ 216 J.
- **Artifacts:** only the provided weights are used (`CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`), so the weights statement is short.

---

## 9. Open questions

- Does the Final ranking use the latest or the best Final?
- Did the 09:40 Final overlap the 09:47 Validation?
- Does the timed energy window end at the last completion or at a fixed schedule end? This decides how much the runaway-math tail costs.
- How do the 0.05 accuracy floor and the family penalty combine, and does "family" mean the six briefing classes or the finer task-id families?
- The E1 and V0 History rows (`A`, `s_E`, `s_T`, `s_L`, joules, p95 TTFT and TPOT) are still not copied.
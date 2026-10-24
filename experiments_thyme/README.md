# experiments_thyme — Removing CPU-caused GPU idle gaps

**Status: untested.** Nothing here has been run. The files were written and checked statically: no scripts executed, no Docker, no VM. Every flag below must pass `scripts/preflight.sh` on the VM before use.

**One-line thesis:** at the 4 req/s peak, vLLM runs roughly 100–250 streams at once. Between GPU steps the CPU schedules, prepares inputs, detokenizes and streams every one of them. The A100 waits during that time while still drawing well above idle power. Overlapping or shrinking that CPU work shortens GPU busy time without changing the model, so energy per on-time request falls and the accuracy factor A is untouched.

---

## 1. Why this is a different approach

| Existing approach | What it covers | What this adds |
|---|---|---|
| [10 CUDA graphs + warm-up](../approach/10_CUDA_Graphs_and_Warmup.md) | Keep graphs on (no `--enforce-eager`), warm up | Check that graphs actually **cover the peak batch size** and size them to fit (T3) |
| [12 API server / CPU workers](../approach/12_API_Server_and_CPU_Workers.md) | More API processes, only if one core is saturated | Overlap engine-core CPU work with GPU work (**async scheduling**, T1), less streaming work per token (**stream interval**, T2), and a way to **measure the gap** (telemetry) |
| 2–9 (power, quantization, MTP, batching, caching) | Fewer watts, fewer bytes, fewer steps | Orthogonal: makes each step's wall time closer to its GPU time. Stacks on top of them |

`experiments/` contains only `instructions.md` ("Follow approaches"), so nothing there is duplicated.

---

## 2. Mechanism and hypothesis

In the default (synchronous) engine loop, each decode step is:

```
CPU: schedule → prepare inputs ─┐                       ┌─ sample bookkeeping → detokenize → stream
GPU:                            └── forward pass ───────┘          (GPU waits here)
```

A W4A16 9B model makes the GPU part short: about 4 ms is the bandwidth floor ([approach 3 §3.1](../approach/3_Weight_Only_Quantization_With_Accuracy_Guardrail.md)), and real steps run 10–30 ms at large batch. CPU work grows with the number of running sequences, so the waiting share is largest exactly at peak, when the GPU is clocked up and drawing far more than its ~55 W idle.

| Config | Change (one per step) | Hypothesis |
|---|---|---|
| **T0** | Same serving flags as `scripts/start-vllm.sh` | Reference. Measure "util while busy" and peak running requests |
| **T1** | `--async-scheduling` | Engine prepares step N+1 while the GPU runs step N → GPU util while busy ↑, TPOT ↓, energy ↓ |
| **T2** | T1 + `--stream-interval 4` | One SSE event per 4 tokens instead of per token → less API-server CPU at ~200 streams → fewer stalls |
| **T3** | Winner + `--compilation-config` with full CUDA graphs captured up to 512 | Only if peak running requests exceed the largest captured graph size: those steps currently skip full graphs and pay launch overhead |
| **T4** | T1 + MTP k=1 | Compatibility check: some vLLM versions refuse async scheduling with speculative decoding |

---

## 3. Expected scoring impact (estimates to replace with measurements)

Using the illustrative model from approach 3 §3.2, `E ≈ T × (P_idle + (P_active − P_idle) × busy_fraction)`, with `P_idle` 55 W, `P_active` 280 W, and busy fraction 0.6:

| GPU busy time saved | Mean power | η gain | Δ s_E | S change if s_E ≈ 0.5 |
|---:|---:|---:|---:|---:|
| 5% | 190 → 183 W | 1.04× | +0.03 | ≈ +4% |
| 10% | 190 → 176 W | 1.08× | +0.07 | ≈ +8% |
| 15% | 190 → 170 W | 1.12× | +0.10 | ≈ +12% |

(S change = `((s_E + Δ) / s_E)^0.6`.)

| Factor | Direction | Why |
|---|---|---|
| `A` | neutral | Same model, same math, temperature 0. Batch composition can already change greedy outputs in the baseline, so check per-class accuracy anyway |
| `s_E` (0.6) | ↑ small–medium | Shorter busy time; more on-time requests if TPOT was near 50 ms |
| `s_T` (0.2) | ↑ or neutral | Faster steps at peak → fewer late requests |
| `s_L` (0.2) | ↑ or neutral | TPOT p95 ↓. T2 risk: TTFT if the first token were buffered (smoke test checks this) |

The gain is real only if T0 telemetry shows a gap. **If T0's util while busy is already ≥ 97%, stop: there is nothing to recover.**

---

## 4. Files

```
experiments_thyme/
  README.md                       this file
  configs/T0..T4_*.conf           one change per config (bash: sourced by the scripts)
  scripts/lib.sh                  defaults = scripts/start-vllm.sh; shared helpers
  scripts/preflight.sh            flag/field check against the image, no GPU used
  scripts/launch.sh               start container "thyme-vllm" + write a run record
  scripts/stop.sh                 remove thyme-vllm only (refuses other containers)
  scripts/smoke_grader_shape.py   streaming + thinking on + Thai + 2-turn tool call; TTFT/TPOT vs SLO
  scripts/telemetry.sh            1 s samples: power, util, clocks, running/waiting, KV use, tokens
  scripts/summarize_telemetry.py  energy estimate, util while busy, peak running, J/token
  results/log.md                  one row per run
  results/runs/<utc>_<config>/    created by launch.sh: config, exact command, image digest, vLLM version
```

---

## 5. How to run (on the VM, when the team is ready)

```bash
cd ~/GreenMind_Hackathon
experiments_thyme/scripts/preflight.sh experiments_thyme/configs/T0_reference.conf
experiments_thyme/scripts/launch.sh    experiments_thyme/configs/T0_reference.conf
docker logs -f thyme-vllm              # wait for "Application startup complete"
python3 experiments_thyme/scripts/smoke_grader_shape.py
experiments_thyme/scripts/telemetry.sh experiments_thyme/results/runs/<run>/telemetry.csv
# ... submit Validation in the grader UI, wait for it to finish, Ctrl-C telemetry ...
python3 experiments_thyme/scripts/summarize_telemetry.py experiments_thyme/results/runs/<run>/telemetry.csv
experiments_thyme/scripts/stop.sh
```

Repeat for T1, T2, then T3 (only if its condition holds), then T4 if the team uses MTP. Log every run in [results/log.md](results/log.md).

**Decision rule:** keep a change only if the grader's Validation S (or η with A unchanged) improves by more than the T0-vs-T0 noise measured in [approach 1](../approach/1_Baseline_and_Measurement_Prerequisite.md), and per-class accuracy does not drop.

### Gates

| # | Check | If it fails |
|---|---|---|
| 1 | Preflight finds the flag | Drop that config |
| 2 | Preflight help shows `--async-scheduling` already defaults to on | T1 = T0. Measure the effect the other way: T0 with `EXTRA_ARGS=(--no-async-scheduling)` |
| 3 | Smoke test passes and TTFT is not worse than T0 | Drop T2 (stream interval delaying the first token) |
| 4 | T4 starts | Async scheduling and MTP are exclusive on this version: pick by Validation S |
| 5 | Grader TPOT is per-request mean ((end − first token) / (tokens − 1)), not per-chunk gap | If the grader measures gaps between chunks, T2 makes them 4× longer: **drop T2** |

---

## 6. Baseline preserved

- `scripts/start-vllm.sh`, `scripts/test-*.sh`, `experiments/` and `approach/` are **unchanged**.
- `lib.sh` defaults copy the original script's values: image `vllm/vllm-openai:nightly`, model `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, served name `mango1.5-awq-w4a16`, bind `127.0.0.1:8000`, memory 0.85, max length 32768, `qwen3_coder` tool parser, `qwen3` reasoning parser, `--trust-remote-code`.
- Differences from the original launch: container name `thyme-vllm` (so it can't collide with `mango-vllm`), no `--restart unless-stopped` (a crashing experimental config shouldn't restart in a loop), two labels, and a refusal to start if anything else is using the GPU.
- The official scoring baseline (BF16 MANGO, default `vllm serve`) is not this repo's T0. T0 is the team's current deployment, so each thyme change is measured against what the team actually serves.

### Two issues inherited from the original script (flagged, deliberately not changed in T0)

1. **`MAX_MODEL_LEN=32768`.** Long-context prompts go up to 32K and `max_tokens` is 8192, so some requests may be rejected. Approach 8 recommends ≥ 40960. Change it in `lib.sh` for all configs at once, never in only one config, or the A/B mixes two changes.
2. **`BIND_ADDR=127.0.0.1`.** The grader calls `http://<vm-ip>:<port>/v1`. The team's deployment notes say the health check passed, so they may be using a proxy or tunnel. Confirm how before setting `BIND_ADDR=0.0.0.0`.

---

## 7. Rule compliance

- Open-source vLLM flags only, set at launch and constant for the whole run. Nothing applies only during the measured window.
- One serving process on our own GPU. No response caching, no LD_PRELOAD, no NVML changes.
- `telemetry.sh` only reads `nvidia-smi` and `GET /metrics`. To stay clearly within "no other workloads during a graded run", use it on **Validation runs only**, not on Final.

---

## 8. Ideas considered and rejected

| Idea | Potential | Why not here |
|---|---|---|
| Server-side thinking budget (force `</think>` after N tokens) | Large: thinking tokens dominate output energy | The grader fixes thinking mode and `max_tokens`. Overriding them server-side looks like changing grader-fixed parameters, and risks the reasoning class. **Ask organizers in writing before anyone tries it** |
| Abort requests that have already missed their TTFT SLO | Saves energy on requests worth zero | Aborted requests most likely count as wrong for accuracy (hits A and the class check), and it reads as gaming the metric |
| N-gram (prompt-lookup) speculative decoding | Good for RAG and tool calls that copy the prompt | vLLM runs one speculative method at a time, so it competes with MTP (approach 4). Worth a try only if MTP fails |

## Sources

- vLLM engine arguments (`--async-scheduling`, `--stream-interval`, `--compilation-config`): `vllm serve --help=all` on the pinned image is the authority; names change between versions.
- vLLM CUDA graphs design doc (cudagraph modes, capture sizes): https://docs.vllm.ai/en/latest/design/cuda_graphs.html
- Energy model and idle floor: [approach 3 §3.2](../approach/3_Weight_Only_Quantization_With_Accuracy_Guardrail.md); concept note [99 CPU and API worker capacity](../use_ur_brain/99_CPU_and_API_Worker_Capacity.md).

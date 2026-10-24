# run4 log

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. `η = SLO-met / joules`. Blank or "missing" cells are not zeros; copy them from grader History.

| Track | `η_base` (SLO-met req/J) | Reference macro-accuracy | Full energy marks (3×) |
|---|---:|---:|---:|
| Validation | 0.00154 | 87.2% | ≈ 216 J per SLO-met request |
| Final | 0.00163 | 87.8% | ≈ 204 J per SLO-met request |

Raw grader console output lives in [results/](results/). Server-side evidence (startup logs, `/metrics` snapshots) lives in `~/greenmind-runs/` on the VM and, once copied, in [runs/](runs/).

## Reference: E1 (Validation 2026-10-24 07:56:39 UTC)

| Field | Value |
|---|---|
| Server | V0 plus `--max-model-len 40960` (`run4/profiles/e1.args`) |
| `S`, `A`, `s_E`, `s_T`, `s_L` | missing |
| SLO-met | missing |
| Joules | missing |
| p95 TTFT, p95 TPOT | missing |
| Visible accuracy | 52 of 63 visible requests. `math` 1/4, agentic 11/17 |
| Note | The three last `math` requests ran 72–82 s, likely 8192-token cutoffs. See `experiments/results/2026-10-24T075639Z-validation.md` |

## Submissions

Times are grader "Started" times in UTC. All runs so far use image `vllm/vllm-openai@sha256:cb12c3016938a4ee98ed176ac833984089460689a0982cff4b5a60bb45b3cded` (vLLM `0.32.1rc1.dev361+g83c078d95`), no power cap (400 W default).

| # | Time (UTC) | Track | Tier | `S` | `A` | R | `s_E` | `s_T` | `s_L` | η vs base | J/req | Joules (derived = J/req × requests) | SLO-met | p95 TTFT | p95 TPOT | Accuracy | Raw output | Decision |
|---:|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|
| 1 | 2026-10-24 09:40:51 | Final | full | **0.0** | 1.00 | 1.007 | 0.00 | 0.05 | 0.31 | 0.92× | 208 | ≈ 62,400 | 93/300 | 3.59 s | 91 ms | 88.4% | [final1](results/2026-10-24T094051Z-final1-r4-full.md) | Below Final baseline efficiency. Possible overlap with the 09:47 Validation (unconfirmed) |
| 2 | 2026-10-24 09:47:19 | Validation | full | 32.8 | 1.00 | 0.997 | 0.30 | 0.32 | 0.45 | 1.38× | 235 | ≈ 23,500 | 50/100 | 3.12 s | 55 ms | 86.9% | [validation5](results/2026-10-24T094719Z-validation5-r4-full.md) | Below V0 (34.8, 56/100). Bottleneck: TTFT (see below) |
| 3 | pending | Validation | full-lpt1056 | | | | | | | | | | | | | | | |

### Reading `s_L` for rows 1 and 2

`s_L² = s_TTFT × s_TPOT`, with `s_TPOT = 50 ms / p95 TPOT`.

| Row | `s_TPOT` | `s_TTFT` (derived) | p95 of TTFT ÷ its SLO (derived) |
|---:|---:|---:|---:|
| 1 (Final) | 0.55 | 0.17 | ≈ 5.7× |
| 2 (Validation) | 0.91 | 0.22 | ≈ 4.5× |

TTFT misses dominate both runs.

## Server-side metrics: tier `full`, rows 1 and 2 combined

Source: `/metrics` of the `full` container (started 2026-10-24 09:35:34 UTC), captured 10:51:13 UTC after both runs, before it was replaced. The counters cover both rows plus a few preflight and warmup calls, about 996 requests in total (agentic episodes make several calls per task). Snapshot: [runs/evidence/metrics-r4-full-after-final1-val5-20261024T105113Z.txt](runs/evidence/metrics-r4-full-after-final1-val5-20261024T105113Z.txt). That container's full log, covering both runs: [runs/20261024-175317_r4-full-lpt1056/previous-container.log](runs/20261024-175317_r4-full-lpt1056/previous-container.log).

| Metric | Value |
|---|---|
| Requests finished `stop` / `length` / `error` / `abort` | 810 / 186 / 0 / 0 |
| Preemptions | 0 |
| MTP draft acceptance | 158,852 / 173,663 = **91.5%** |
| Prefix-cache hit rate | 11,616 / 1,115,335 tokens = **1.0%** |
| Prompt tokens, total and mean | 1,115,335; 1,120 per request |
| Prompt length | 84% ≤ 1,000 tokens; 55 requests > 5,000; 11 > 20,000 |
| Generation tokens, total and mean | 333,023; 334 per request. 62% ≤ 200 tokens; 12 requests > 5,000 |
| `max_tokens` sent by the grader | 338 requests ≤ 2,000; 658 between 5,000 and 10,000 (8192) |
| Server TTFT | mean 0.65 s; 70% ≤ 0.5 s; 78% ≤ 1.0 s; 93% ≤ 2.5 s |
| Queue time (arrival → first scheduled) | mean 0.30 s; 205 requests > 0.3 s; 121 > 1.0 s |
| Prefill time | mean 0.29 s; 92% ≤ 0.5 s |
| Per-step inter-token latency | mean 51 ms per step (≈ 1.9 tokens per step with MTP); 29% of steps > 50 ms, 6% > 200 ms |

Interpretation, as hypotheses:

- **Queueing.** Requests queue without preemption or cache pressure. That points to head-of-line blocking: on an A100 the scheduler budget defaults to 2,048 tokens per step (confirmed in the vLLM source in this image), and a long prompt in prefill takes all of it for many steps.
- **MTP.** MTP works per step (91.5% acceptance), so removing it is not the first fix.
- **Prefix caching.** It contributes almost nothing (1% hits), while `align` mode forces a 528-token attention block.

## Startup facts per tier

| Tier | Started? | MTP active | Prefix caching enabled | Max concurrency at 40960 | `max_num_batched_tokens` | `max_num_seqs` | Notes |
|---|---|---|---|---|---|---|---|
| full | yes, 09:35 UTC | yes, k = 1 | yes, `align` (528-token attention block, 3 padding layers) | 13.89× (568,731 KV tokens) | 2048 (A100 default; warning "max_num_scheduled_tokens is set to 2048") | 256 (A100 default) | `--mamba-cache-mode` flag is deprecated; `align` is applied automatically with prefix caching |
| full-lpt1056 | yes, 10:53 UTC; `READY` 10:58 UTC | yes, k = 1 | yes, `align` (528-token block, 3 padding layers) | 13.89× (568,731 KV tokens) | 2048 (same warning) | 256 | Engine config shows `long_prefill_token_threshold: 1056`. Record: [runs/20261024-175317_r4-full-lpt1056](runs/20261024-175317_r4-full-lpt1056/) |

## Experiment notes

### full-lpt1056 (row 3)

- **Parent:** `full` (rows 1 and 2).
- **Single change:** `--long-prefill-token-threshold 1056`, which is two 528-token blocks.
- **Hypothesis:** while other requests are eligible, a prompt longer than 1,056 tokens prefills at most 1,056 tokens per step. Short prompts, 84% of traffic and with TTFT SLOs of 0.75 s or less, get scheduled the step they arrive instead of queueing behind a long prefill. Expect queue time, p95 TTFT ÷ SLO, and long-step stalls to fall, raising SLO-met, `s_T` and `s_L`.
- **Risk:** long prompts take more steps to prefill. A 20K prompt needs about 19 steps against a TTFT SLO of 5.5 s.
- **Keep if:** `S` and SLO-met beat row 2 (32.8, 50/100) with `A` unchanged.
- **Deployment checks (2026-10-24 10:58 UTC):**
  - `start.sh` preflight PASSED: args match the profile; chat, streaming with usage, streaming tool call and thinking-on streaming all pass. Two warnings: dirty tree, `0.0.0.0` exposure.
  - From outside the VM, `/v1/models` and chat over `103.153.118.56:8000` pass.
  - `warmup.py` FAILED on `tool-turn2`. After the tool result the model answers without a `<think>` block, and the `qwen3` reasoning parser files the whole answer ("The weather in Bangkok is currently 33°C and humid.", 14 tokens) under `reasoning_content`, leaving `content` empty. It reproduces on every attempt at temperature 0. The new flag cannot affect it: the prompt is 348 tokens, and the cap is off when one request runs alone. The `full` tier shares the model, parser and template, but its earlier preflight never ran a second tool turn.
  - `flag-check.sh` cannot read `vllm serve --help` in a throwaway container without a GPU. The flag was verified with `docker exec mango-vllm vllm serve --help=SchedulerConfig` on the same image.

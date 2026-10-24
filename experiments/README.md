# Experiments

Independent one-change launches for the server scored in `scoring_criteria.md`. `scripts/start-vllm.sh` is V0 and stays unchanged. These scripts copy that command and add the single delta named in each directory.

Run them on the Ubuntu VM. This repository does not start Docker from the authoring machine.

## Score these scripts are aiming at

```
S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2
η = SLO-met requests / GPU joules
s_E = clip( ln(η / η_base) / ln 3 , 0, 1 )
```

Only the Final counts, and it has its own baseline. Never mix the two.

| Constant | Validation (practice) | **Final (graded)** |
|---|---|---|
| Baseline efficiency `η_base` | `0.00154` SLO-met requests/J | **`0.00163`** SLO-met requests/J |
| Full energy marks (3×) | `η ≥ 0.00462`, about 216 J per SLO-met request | **`η ≥ 0.00489`**, about 204 J per SLO-met request |
| Reference macro-accuracy | `87.2%` | **`87.8%`** |
| Full `A` before a class penalty | retention `≥ 0.98`, about `85.5%` | retention `≥ 0.98`, about `86.0%` |
| TTFT SLO | `0.5 + 0.25 × prompt_tokens / 1000` seconds |
| TPOT SLO | `50 ms`, skipped for one-token answers |
| Peak used for `s_T` | constant 4 requests/second |
| Round cap | 30 minutes; unfinished requests fail |

`s_T` and `s_L` saturate at 1. Energy has exponent 0.6. Idle joules count. A missed SLO still adds joules and adds nothing to the numerator of `η`.

Both pairs are on the live grader page: `0.00154` / `87.2%` for Validation, `0.00163` / `87.8%` for the Final. Validation only checks that a server works. Its 100-request load never reaches the Final's peak concurrency, so a high Validation score does not predict the Final (run6: 95.6 Validation, 19.1 Final).

V0, from the defaults in `scripts/start-vllm.sh`:

| Field | Value |
|---|---|
| `S` | 34.8 |
| SLO-met | 56/100 |
| `A`, `s_E`, `s_T`, `s_L`, joules, p95 TTFT, p95 TPOT | Not yet copied from grader History |
| Checkpoint | `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp` |
| Served name | `mango1.5-awq-w4a16` |
| Context | 32768 |
| GPU memory utilization | 0.85 |
| MTP, prefix caching, power cap | off |

If `A`, `s_T`, and `s_L` were all 1, `s_E` would be about 0.17 and efficiency about 1.21× baseline. That is a ceiling on how to read 34.8, not a measurement. Copy the History row into `log.md` before the next flag change.

### What the 44 misses are worth

At constant joules, and only in the hypothetical where `A = s_T = s_L = 1`:

| SLO-met | Efficiency vs `η_base` | `s_E` | `S` |
|---:|---:|---:|---:|
| 56/100 | ~1.21× | ~0.17 | 34.8 |
| 80/100 | ~1.73× | ~0.50 | ~66 |
| 100/100 | ~2.16× | ~0.70 | ~81 |

Rescuing SLO misses moves `S` through the numerator of `η` and, when those misses are in the peak, through `s_T`. A watt cut that pushes TPOT over 50 ms shrinks that numerator. That is why the power cap waits until SLO-met is at least 90/100.

## Run order

One Validation per change. Revert a change that lowers SLO-met or `S`. Validation allows 5 finished submissions per hour. Final allows 2. Final closes on 25 October 2026 at 11:00. Do not retune on Final.

| Step | Script | Single change from the current kept server | Expected score effect |
|---:|---|---|---|
| 0 | none | Copy the V0 History row into `log.md` | No submission |
| 1 | `01-max-model-len/start.sh` | `--max-model-len 40960` | Can raise SLO-met if long prompts are erroring or cutting off at 8192 tokens |
| 2 | `02-batched-tokens/start.sh 4096` | `--max-num-batched-tokens 4096` | Can raise TPOT-bound SLO-met; can worsen long-prompt TTFT if the budget is too small |
| 2b | `02b-chunked-prefill/start.sh` | `--enable-chunked-prefill`, only when the log says it is off | Same trade as step 2, and only if the nightly build still accepts the flag |
| 3 | `03-mtp/start-k1.sh` | MTP, `num_speculative_tokens` 1 | Can lower decode joules and TPOT when drafts are accepted. `k=2` and `k=3` are separate scripts and wait for a win at `k=1` |
| 4 | `04-prefix-caching/start.sh` | `--enable-prefix-caching --mamba-cache-mode align` | Can cut prefill joules and TTFT on multi-turn and RAG traffic when the log shows hits |
| 5 | `05-gpu-memory/start.sh 0.90` | utilization `0.90`, then `0.92`, then `0.95` | Fewer preemptions while p95 TPOT stays under 50 ms. An OOM abort fails the round |
| 6 | `06-max-num-seqs/start.sh` | one of 64, 128, 192, 256 | More tokens per weight read until TPOT reaches 50 ms |
| 7 | `07-power-cap/set-power-cap.sh` | constant 250 W, then 200 W, then 175 W | Lowers watts after SLO-met is already at least 90/100 |
| 8 | warmup + one confirmation Validation, then one Final | no new flag | `10-warmup/warmup.sh` only prepares graphs before the window |

Exact commands: [vm-sequence.md](vm-sequence.md).

A combined server that stacks steps 1, 3, 4, and 5 in one launch is planned in [../run4/PLAN.md](../run4/PLAN.md), for the case where the one-flag ladder does not fit before Final closes.

## How a later step keeps an earlier win

`experiments/adopted.env` starts empty, so each script differs from V0 by one flag.

After a Validation is kept, set that one value in `adopted.env` and launch the next script with `ADOPT_PREVIOUS=1`. The launcher then applies the kept flags plus the new script's one delta. Clear a knob in `adopted.env` before a script replaces that same knob (`0.90` then `0.92`, or MTP `k=1` then `k=2`).

The launcher also exits if `MAX_MODEL_LEN`, `GPU_MEMORY_UTILIZATION`, `MAX_NUM_SEQS`, `MAX_NUM_BATCHED_TOKENS`, `SPECULATIVE_CONFIG`, `PREFIX_CACHING`, `ENABLE_CHUNKED_PREFILL`, or `EXTRA_VLLM_ARGS` is set in the shell. `scripts/start-vllm.sh` only honors the first two of those. Unset them so a leftover export cannot change an experiment.

`DRY_RUN=1` prints the vLLM arguments and does not call `docker run`.

## Flags every experiment keeps

These match the scored container:

- Image `vllm/vllm-openai:nightly`, or a `vllm/vllm-openai@sha256:` pin. Record the digest. The V0 digest was not saved.
- Model `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`
- Served name `mango1.5-awq-w4a16`
- `--trust-remote-code`
- `--enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser qwen3`
- Publish `127.0.0.1:8000`
- Container name `mango-vllm`
- CUDA graphs left on. No script passes `--enforce-eager`.

The image entrypoint is already `vllm serve`. The arguments start with the model id, as in `scripts/start-vllm.sh`.

Confirm a new flag with `vllm serve --help` inside the image before a graded run. Nightly names move. A server that exits on an unknown flag is not a submission.

## Before every Submit

```bash
bash scripts/test-chat.sh
bash scripts/test-stream.sh
bash scripts/test-tool-calling.sh
bash experiments/10-warmup/warmup.sh
bash experiments/07-power-cap/show-power.sh
bash experiments/watch-run.sh
```

Stop `watch-run.sh` when the grader finishes. The chat and stream tests disable thinking. The warmup enables it, which is the grader path.

## Not given a launch script

| Idea | Why it stays out | Score if it were tried anyway |
|---|---|---|
| Another quantization or a BF16 rebuild | V0 is already the AWQ W4A16 MTP checkpoint. Approach 3 is adopted. | A new checkpoint can move every component, including `A`, and would no longer be a one-flag experiment |
| Mamba state dtype BF16 | Approach 9, after prefix caching has a hit-rate result | Might raise concurrency and cache hits. Long-context `A` can fall |
| Fixed clock lock | Approach 11, and only after the power-cap sweep | No source in the repo shows a lock beating a constant cap. Prefill TTFT can miss |
| `--api-server-count` | Approach 12. The rules say one serving process | Only a TTFT gain if a core is saturated and the GPU is idle. Confirm the rule first |
| FP8 KV cache | Approach 13. About 8 of 32 layers have a KV cache, and the A100 has no FP8 tensor cores | Small concurrency gain, long-context accuracy risk |
| Scheduling policy | Approach 14. The grader does not set request priority | Expected `S` change is zero |
| External draft model | Approach 15. Its energy counts | Extra weights can erase the MTP gain |
| Another engine | Approach 16 | Migration has to pass streaming, tools, accuracy, and energy parity. Out of the time left before Final |
| Pruning, fine-tuning, custom kernels | Approach 17 | Accuracy can fall below the 98% retention line, and training does not fit the remaining window |
| Dynamic clocks, response caching, NVML changes | Approach 18 | Disqualification |

## Measurement

Write the hypothesis before Submit. The hypotheses for this queue are already in [log.md](log.md). Fill results from History. Keep a failed row.

`watch-run.sh` stores `nvidia-smi dmon` and `/metrics` under `~/greenmind-watch/`. It does not set clocks or a power limit.

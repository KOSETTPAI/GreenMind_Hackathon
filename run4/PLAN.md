# run4 — combined optimized server (plan)

Implemented. How to run it: [README.md](README.md). This file keeps the reasoning.

One launch that stacks the approaches with the best expected score, served on the same endpoint as the graded E1 container. Nothing in `scripts/`, `experiments/`, or `experiments_thyme/` changes.

Final grader submissions close on 25 October 2026 at 11:00. Validation allows 5 finished submissions per hour, Final allows 2. The one-flag ladder in `experiments/` needs about seven Validations before Final. run4 submits the combined server first and keeps a short fallback ladder for a regression.

## Endpoint contract

| Item | Value |
|---|---|
| Container | `mango-vllm`, `--restart unless-stopped`, `--gpus all`, `--ipc=host` |
| Publish | `0.0.0.0:8000:8000` by default, matching the graded E1 container (`scripts/start-vllm.sh` publishes `127.0.0.1`). `BIND=127.0.0.1` if the team decides otherwise |
| API | `http://127.0.0.1:8000/v1`, `/v1/chat/completions`, `/v1/models` |
| Served model name | `mango1.5-awq-w4a16` |
| Checkpoint | `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp` |
| Image | `vllm/vllm-openai:nightly`, pinned to the digest recorded on the VM |
| Always on | `--trust-remote-code --enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser qwen3` |

`scripts/test-chat.sh`, `test-stream.sh`, and `test-tool-calling.sh` run against run4 with no change.

## Combined configuration (R4-full)

| Flag | V0 | run4 | Source | Why it is in |
|---|---|---|---|---|
| `--max-model-len` | 32768 | **40960** | Approach 8, E1, A08a | A 32K prompt plus `max_tokens = 8192` needs 40960. Without it, long requests error |
| `--speculative-config` | off | **`{"method":"mtp","num_speculative_tokens":1}`** | Approach 4, E3, A04 | Fewer decode steps per token. Loops and repetitive text accept drafts well, which shortens the 8192-token tail |
| `--enable-prefix-caching --mamba-cache-mode align` | off | **on** | Approach 7, E4, A07 | Agentic episodes (up to 15 turns) and RAG resend shared text on every request. Prefix hits cut prefill joules and TTFT |
| `--gpu-memory-utilization` | 0.85 | **0.90** | Approach 8, E5, A08b | Headroom for MTP draft state, prefix-cache blocks, and 40960 context together. 0.92 and 0.95 add OOM risk to a combined first run |
| `--max-num-batched-tokens` | unset | **unset; default recorded from the startup log** | Approach 6 | The miss type (TTFT or TPOT) is unknown, and so is this nightly's default. `start.sh` prints the value. 2048 or 4096 becomes a new profile once per-request data says which SLO fails |
| `--max-num-seqs` | unset | unset | Approach 5 | Peak concurrency is about 40–60 requests. The usual default of 256 does not bind |
| Power cap | none | **none in R4-full** | Approach 2 | Stays out until SLO-met is at least 90/100 |

### Left out, and why

| Approach | Reason |
|---|---|
| Mamba state BF16 (`--mamba-ssm-cache-dtype bfloat16`, A09) | Long-context accuracy risk, and `longctx` is currently 5/5. Revisit only if the startup log's max concurrency at 40960 is under about 60 |
| FP8 KV cache (A13) | About 8 of 32 layers keep a KV cache. A100 has no FP8 math. Small gain, accuracy risk |
| `--api-server-count` (A12) | Rules say one serving process. Only useful if a CPU core saturates |
| Clock lock (A11) | No evidence it beats a constant power cap. Prefill TTFT risk |
| FP8 or BF16 weights (A03a/A03b) | More bytes per decode step than AWQ. Only a fallback if the History `A` shows an agentic or other family penalty traced to quantization |
| Scheduling policy, draft model, engine switch, pruning | Approaches 14–17. No expected gain before Final |
| Server-side output cap or sampling override | The grader fixes `max_tokens`, temperature, thinking mode, and sampling. Not allowed |

## Expected score effect (hypotheses)

| Lever | `s_E` | `s_T` / `s_L` | `A` |
|---|---|---|---|
| 40960 context | Up if long requests were failing | Up for rescued peak requests | Long answers now complete |
| MTP k=1 | Up: fewer weight reads per token, shorter cutoff tail | TPOT down, if acceptance holds at a batch of about 50 | Flat at temperature 0. A tool-JSON or family regression is a revert |
| Prefix caching | Up on multi-turn agentic and RAG traffic | TTFT down on later turns | Flat. Any answer change is a revert |
| Memory 0.90 | Small up: fewer preemptions | Up if preemptions were dropping requests | Flat |

The tail is the largest single lever visible in the latest Validation. Three runaway `math` requests decode for about 70 s after everything else finished. If the timed window ends at the last completion, that tail is on the order of 10 kJ of a budget of at most about 30 kJ (estimate, see `experiments/results/2026-10-24T075639Z-validation.md`). Those requests still fail at 8192 tokens. MTP shortens that tail. A constant power cap would cut it further, once SLO-met allows a cap.

No numeric `S` forecast: there is no MANGO acceptance rate, cache-hit rate, or per-request SLO breakdown in the repo yet.

## Files

Listed in [README.md](README.md#files). Tiers are a `start.sh` argument, and each tier's arguments live in `profiles/r4-<tier>.args`, which is also what the preflight checks against.

### Fallback tiers in `start.sh`

| Tier | Flags | When to use it |
|---|---|---|
| `full` | All of R4-full | First submission |
| `no-prefix` | R4-full without prefix caching | Startup rejects prefix caching with MTP on this hybrid model, the log says prefix caching disabled itself, or `full` regresses |
| `no-mtp` | R4-full without MTP | Startup rejects MTP, tool calls fail with it, or `no-prefix` still regresses |
| `safe` | 40960 context only | Both levers fail. Same server as the measured E1 run |

## Submission order on the VM

1. Copy the History row of the 07:56 UTC Validation (E1, context 40960) into `experiments/log.md`. That row is the reference run4 has to beat.
2. From that run's jsonl, read `finish_reason` and `completion_tokens` for `mxv2_124/134/109_math`, and the TTFT and TPOT of the SLO misses. That decides the token-budget variant.
3. `./run4/flag-check.sh full`, then `REPLACE=1 ./run4/start.sh full`. It waits for `/v1/models`, saves the startup log and prints its key lines (MTP, prefix caching, max concurrency at 40960, batched-token default), then runs the preflight with the same profile. Run `run4\check-external.ps1` from a PC.
4. `python3 run4/warmup.py`, start `./run4/watch.sh`, then submit one Validation of R4-full.
5. If SLO-met or `S` is below the best previous row, drop down one tier per submission.
6. If SLO-met is at least 90/100: set a constant 250 W cap, then 200 W, then 175 W, one Validation each, keeping the best `S`.
7. If spec acceptance is high and tool calls are clean, try MTP k=2 as one variant.
8. One confirmation Validation of the best config, run `warmup.py` before Submit, then one Final. No changes between those two.

## Open inputs

- The History row of the E1 Validation (07:56 UTC).
- Whether the timed energy window ends at the last completion or at a fixed schedule end. That decides how much the cutoff tail costs.
- The baseline per-family accuracy, needed to know whether agentic at about 65% visible is near the 75% family threshold.

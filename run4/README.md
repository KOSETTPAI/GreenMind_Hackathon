# run4 — combined server

One launch that stacks the approaches with the best expected score on top of the measured E1 server, with a fallback ladder if it regresses. `scripts/`, `experiments/`, and `experiments_thyme/` are unchanged. Background and reasoning: [PLAN.md](PLAN.md). Endpoint checks: [ENDPOINT_RUNBOOK.md](ENDPOINT_RUNBOOK.md).

Nothing here has run on the VM yet. Each step below says what proves it worked.

## Tiers

| Tier | Profile | Change from E1 | Use |
|---|---|---|---|
| `full` (default) | `profiles/r4-full.args` | MTP k=1, prefix caching with `--mamba-cache-mode align`, memory 0.90 | First submission |
| `no-prefix` | `profiles/r4-no-prefix.args` | MTP k=1, memory 0.90 | `full` won't start, the log says prefix caching disabled itself, or `full` regresses |
| `no-mtp` | `profiles/r4-no-mtp.args` | Prefix caching, memory 0.90 | MTP won't start, breaks tool calls, or `no-prefix` regresses |
| `safe` | `profiles/e1.args` | none | Both levers failed. The measured E1 server |
| `full-k2` | `profiles/r4-full-k2.args` | `full` with two draft tokens | Only after `full` beats E1. Needs `CONFIRM_K2=1` |

Pick a tier with an argument (`./run4/start.sh no-prefix`) or `RUN4_TIER=no-prefix`. Every tier keeps the endpoint: container `mango-vllm`, host port 8000, served name `mango1.5-awq-w4a16`, checkpoint `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, context 40960, `--trust-remote-code`, `--enable-auto-tool-choice --tool-call-parser qwen3_coder --reasoning-parser qwen3`. `start.sh` refuses a profile that breaks any of those.

The profile is the single source of truth. `start.sh` launches exactly its arguments, and `preflight.sh` fails if the running container has one more, one fewer, or a different value.

### Same method as `scripts/start-vllm.sh`

`start.sh` runs the same `docker run` as `scripts/start-vllm.sh`: container `mango-vllm`, `--restart unless-stopped --gpus all --ipc=host`, the Hugging Face cache mount, and `-p 127.0.0.1:${PORT}:8000`. It reads the same variables (`CONTAINER_NAME`, `PORT`, `VLLM_IMAGE`). It also refuses to replace an existing container. Only the vLLM arguments differ, and they come from the tier's profile.

`MODEL_ID`, `SERVED_MODEL_NAME`, `GPU_MEMORY_UTILIZATION`, and `MAX_MODEL_LEN` come from the profile. A leftover export of one of them that disagrees with the profile stops the launch, so an old `MAX_MODEL_LEN=40960` from E1 is fine, but `0.85` on a 0.90 tier is not.

**Bind.** The default is `127.0.0.1`, as in `scripts/start-vllm.sh`. With `REPLACE=1` and no `BIND` set, `start.sh` keeps the bind of the container it replaces, so a working endpoint keeps working. `BIND=0.0.0.0` publishes on all interfaces. The chosen bind is stored in a container label, and the preflight checks against it.

## Run order on the VM

```bash
cd ~/GreenMind_Hackathon
chmod +x run4/*.sh

# 1. Flags exist in the image (no GPU, the current server keeps running)
./run4/flag-check.sh full

# 2. Replace E1 with R4-full (no argument = full); keeps E1's bind, waits, runs the preflight
REPLACE=1 ./run4/start.sh
#    or, exactly like scripts/start-vllm.sh:
#    docker rm -f mango-vllm && ./run4/start.sh

# 3. Right before Submit
python3 run4/warmup.py
./run4/watch.sh            # second shell, Validation only; Ctrl-C when the grader finishes
```

Submit only when `start.sh` printed `READY` and `warmup.py` printed `WARMUP PASSED`. If the bind is `0.0.0.0`, also run `run4\check-external.ps1` from your PC.

A later standalone `./run4/preflight.sh` picks the tier and bind from the container's labels, so it needs no variables.

After the grader finishes:

```bash
python3 run4/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <SLO-met from History>
```

Copy the History row and the summary into [log.md](log.md).

## Decision rules

| Result vs the best row so far | Next |
|---|---|
| `start.sh` says NOT READY | Next tier down, no submission spent |
| SLO-met or `S` lower | Next tier down, one Validation each |
| `S` higher, SLO-met under 90/100 | Keep. Try `full-k2` only if MTP acceptance is high and tool calls are clean |
| `S` higher, SLO-met at least 90/100 | Keep, then the power sweep |
| Any family accuracy drop in History | Revert that tier |

Power sweep, on the kept tier, one Validation each:

```bash
CONFIRM_SLO=at-least-90 ./run4/power.sh set 250    # then 200, then 175
./run4/power.sh restore                            # between runs, never during one
```

Keep the cap with the best `S`, not the lowest watts. Then one confirmation Validation, run `warmup.py` before Submit, and one Final with nothing changed in between. Final grader submissions close 25 October 2026 at 11:00.

## What each tier is expected to do

| Lever | Expected effect | Proven by |
|---|---|---|
| MTP k=1 | Fewer decode steps per token: lower TPOT and joules, and a shorter tail when the three `math` requests run to 8192 tokens | Startup log mentions the MTP or speculative config. `summarize.py` shows MTP acceptance |
| Prefix caching (`align`) | Less prefill on multi-turn agentic and RAG requests: lower TTFT and joules | Startup log shows prefix caching enabled. `summarize.py` shows a non-zero hit rate |
| Memory 0.90 | Headroom for MTP state, cache blocks, and 40960 context together. Fewer preemptions | Startup log's maximum concurrency at 40960. `summarize.py` shows zero or fewer preemptions |
| Power cap | Fewer joules at the same SLO-met | Grader joules fall while SLO-met holds |

There is no numeric `S` forecast. The repo has no MANGO acceptance rate, cache hit rate, or E1 History row yet.

Not used, with reasons in PLAN.md: `--max-num-seqs` (peak concurrency of about 40–60 is under the usual default of 256), BF16 Mamba state, FP8 KV cache, extra API servers, clock lock, other weights, other engines. Capping output length or changing sampling on the server would override grader-fixed parameters and is not allowed.

## Files

| File | Purpose |
|---|---|
| `start.sh` | Launch a tier, wait, capture startup facts, run the preflight. Records go to `~/greenmind-runs/<time>_r4-<tier>/`, with `latest` pointing to the newest |
| `profiles/*.args` | Exact vLLM arguments per tier |
| `flag-check.sh` | Flags exist in the image, using a throwaway container without GPU |
| `preflight.sh`, `preflight_checks.py` | Endpoint and configuration checks. Also run standalone: `PROFILE=r4-full ./run4/preflight.sh` |
| `check-external.ps1` | Public endpoint check from a PC |
| `warmup.py` | Grader-shaped warmup with a two-turn tool episode, thinking on |
| `watch.sh`, `summarize.py` | Telemetry: NVML energy counter, running and waiting, preemptions, prefix hits, MTP acceptance |
| `power.sh` | Show, set, or restore one constant power limit |
| `log.md` | One row per run4 submission |

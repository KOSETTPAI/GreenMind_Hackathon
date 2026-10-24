# Shared launch scripts

`run5` onward use the scripts here, including `run17-val1` through `run30-final4`. `run4` keeps its own copies and its own profiles. Do not point a run4 launch at this directory.

Each later run is one change from its parent. The live order is `CYCLE_PLAN.md`. The profile in that run's folder is the whole vLLM argument list. `start.sh` launches exactly those arguments, and `preflight.sh` fails if the container has a different set.

| Script | Role |
|---|---|
| `start.sh` | `docker run`, wait for `/v1/models`, save a record under `~/greenmind-runs/<time>_<run>/`, run the preflight. Called by `<run>/start.sh`. Publishes `0.0.0.0:8000` unless `BIND` is set |
| `preflight.sh` | Read-only. Checks the container against the profile, then chat, streaming, a tool call, and thinking-on streaming |
| `preflight_checks.py` | The checks. Also rejects a profile that breaks the endpoint contract |
| `flag-check.sh` | Confirms every profile flag exists in `vllm serve --help`. Prints help only, so the running server keeps serving. Not during a graded window |
| `warmup.py` | Grader-shaped warmup, including a two-turn tool call. Run after `READY`, before Submit, never during a graded window |
| `watch.sh`, `summarize.py` | One-second telemetry and its summary. Validation only. `summarize.py` requires `--track final` or `--track validation`, which picks that track's baseline (Final 0.00163, Validation 0.00154) |
| `power.sh` | One constant power limit. Called by `run15` and `run26-val8`. Never during a graded window |
| `check-external.ps1` | From a PC: TCP, `/models`, and one chat to the public IP |
| `replay.py` | Final-shaped synthetic load: 300 requests, ramp to 4 req/s, a 45 s peak, then 1 req/s. Prompt and output sizes are sampled from our own server's `/metrics` histograms. Prints SLO-met, peak-phase SLO share, p95 TTFT ÷ SLO, p95 TPOT, joules and an estimated `S`, with A assumed 1. GPU workload: never during a Validation or Final. It aborts if the server already has running or waiting requests |

## Current status (2026-10-24 19:30 UTC+7)

| Run | Validation | Final |
|---|---|---|
| run4 full | 32.8 (50/100) | 0.0 (93/300) |
| run5 | 35.6 (57/100) | none |
| run6 | **95.6** (98/100) | **19.1** (127/300) |

Cycle 1 has used its first two Validations (run5, run6) and its first Final (run6, 19.1). Remaining this hour: three Validations, then one Final. The schedule is [CYCLE_PLAN.md](../CYCLE_PLAN.md). The target is Final `S` = 99.9 against the Final baseline.

run6 holds on Validation and falls apart on the Final. The Final's peak drove 111 requests running at once against 35 on the Validation, and p95 TPOT rose from 18 ms to 82 ms. Diagnosis: [run6/ANALYSIS.md](../run6/ANALYSIS.md).

run6 did not actually turn prefix caching off. This image enables it by default, and the default hit 87% (Validation) and 44% (Final) of prompt tokens. Profiles built on run6 keep it on. Do not add `--enable-prefix-caching`.

### This cycle (parent run6)

| Run | Change from run6 | Launch guard | Purpose |
|---|---|---|---|
| [run17-val1](../run17-val1/README.md) | `--max-num-seqs 64` | none | Cap the decode batch. Same profile as run16. **Submit this one** |
| [run18-val2](../run18-val2/README.md) | `--max-num-seqs 32` | none | Tighter cap. Binds even on Validation, whose peak was 35 |
| [run19-val3](../run19-val3/README.md) | cap 64 + `--long-prefill-token-threshold 2048` | none | Cap plus long-prefill splitting |
| [run20-final1](../run20-final1/README.md) | the replay winner, default cap 64 | `CONFIRM_FINAL1=1` | Cycle 1's second Final |

Validation saturates at 98/100 and does not reach Final concurrency, so it cannot rank the caps. Replay each candidate with the same `--seed`, then spend `run20-final1` on the best:

```bash
REPLACE=1 ./run17-val1/start.sh && python3 lib/warmup.py
python3 lib/replay.py --label val1 --track final
```

The replay uses random words. Its prefix hits come only from `--reuse-prob`, and it has no agentic multi-turn episodes, so its absolute numbers will not equal the grader's. Use it to rank configurations against each other. Later cycles (`run21-val4` through `run30-final4`) stay behind their `CONFIRM_` guards until final1 is recorded.

## Ladder

| Run | Plan | Parent | The one change | Launch guard |
|---|---|---|---|---|
| [run5](../run5/README.md) | V1 | `run4` full | Remove MTP. Prefix caching stays on | none |
| [run6](../run6/README.md) | V2 | run5 | Turn prefix caching off | none |
| [run7](../run7/README.md) | V3 | run6 | `--max-num-batched-tokens 4096` | none |
| [run8](../run8/README.md) | V4 | run7 | budget `8192` | none |
| [run9](../run9/README.md) | V5 | run8 | `--long-prefill-token-threshold 4096` | none |
| [run10](../run10/README.md) | V6 | run8 | budget `16384` | `CONFIRM_V6=1` |
| [run11](../run11/README.md) | V7 | run8 | Add MTP k=1. Caching stays off | `CONFIRM_V7=1` |
| [run12](../run12/README.md) | V7 k=2 | run11 | `num_speculative_tokens` 2 | `CONFIRM_K2=1` |
| [run13](../run13/README.md) | V8 | run8 | `--gpu-memory-utilization 0.92` | `CONFIRM_V8=1` |
| [run14](../run14/README.md) | cache follow-up | run5 | `--enable-mamba-shared-prefix-checkpoint` | `CONFIRM_SHARED_PREFIX=1` |
| [run15](../run15/README.md) | V9 | the kept server | Power cap 250 W, then 200 W, then 175 W. No new vLLM arguments | `CONFIRM_SLO=at-least-90` |

V10 in the plan is a repeat of whichever run won. Relaunch that same folder. It does not get a new profile.

`run7` through `run15` were written when run6 was thought to have caching off. It does not: the image default is on, and that default is what scored 95.6. Those folders are not the next launches. The next launches are `run17-val1` onward, and each of them keeps the run6 argument list.

## Launch

On the VM, only when the GPU is idle and no Validation or Final is running:

```bash
cd ~/GreenMind_Hackathon
./run5/flag-check.sh
REPLACE=1 ./run5/start.sh
python3 lib/warmup.py
./lib/watch.sh          # second shell, Validation only
```

`start.sh` prints `READY` only after the preflight passes. Then check `http://103.153.118.56:8000/v1` from outside the VM (`lib/check-external.ps1` on Windows). Submit by hand. Record the History row in that run's `log.md`.

A conditional run refuses to start until its guard variable is set, for example `CONFIRM_V6=1 ./run10/start.sh`.

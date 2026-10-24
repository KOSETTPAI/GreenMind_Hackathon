# Shared launch scripts

`run5` onward use the scripts here, including `final-run1` through `final-run7`. `run4` keeps its own copies and its own profiles. Do not point a run4 launch at this directory.

Each later run is one change from its parent. The live order is `CYCLE_PLAN.md`. The profile in that run's folder is the whole vLLM argument list. `start.sh` launches exactly those arguments, and `preflight.sh` fails if the container has a different set.

| Script | Role |
|---|---|
| `start.sh` | Set the power limit from `GREENMIND_POWER_W` (or restore the default), `docker run`, wait for `/v1/models`, save a record under `~/greenmind-runs/<time>_<run>/`, run the preflight. Called by `<run>/start.sh`. Publishes `0.0.0.0:8000` unless `BIND` is set |
| `preflight.sh` | Read-only. Checks the container against the profile, then chat, streaming, a tool call, and thinking-on streaming |
| `preflight_checks.py` | The checks. Also rejects a profile that breaks the endpoint contract |
| `flag-check.sh` | Confirms every profile flag exists in `vllm serve --help`. Prints help only, so the running server keeps serving. Not during a graded window |
| `warmup.py` | Grader-shaped warmup, including a two-turn tool call. Run after `READY`, before Submit, never during a graded window |
| `watch.sh`, `summarize.py` | One-second telemetry and its summary. Validation only. `summarize.py` requires `--track final` or `--track validation`, which picks that track's baseline (Final 0.00163, Validation 0.00154) |
| `power.sh` | Manual power limit (`show`, `set`, `restore`). The cycle runs set power through `start.sh` instead. Never during a graded window |
| `check-external.ps1` | From a PC: TCP, `/models`, and one chat to the public IP |
| `replay.py` | Final-shaped synthetic load: 300 requests, ramp to 4 req/s, a 45 s peak, then 1 req/s. Prompt and output sizes are sampled from our own server's `/metrics` histograms. Prints SLO-met, peak-phase SLO share, p95 TTFT ÷ SLO, p95 TPOT, joules and an estimated `S`, with A assumed 1. GPU workload: never during a Validation or Final. It aborts if the server already has running or waiting requests |

## Current status (2026-10-24 21:00 UTC+7)

| Grader Final | Server | S | SLO-met | p95 TTFT | p95 TPOT |
|---|---|---|---|---|---|
| #1 | run4 full | 0.0 | 93/300 | 3.59 s | 91 ms |
| #2 | run5's container ("run6") | **19.1** | **127/300** | 2.16 s | 82 ms |
| #3 | final-run1, cap 64 | 0.0 | 87/300 | 6.54 s | 67 ms |
| #4 | final-run2, cap 64 + MTP | 0.0 | 81/300 | 7.82 s | 63 ms |

run6 was never launched: its flag-check failed, so `&&` stopped, and run5's container kept serving. The Validation's 100 prompts are the first 100 of the Final, so a second Validation on that container hit the prefix cache (95.6). The cap moved the failure to TTFT. MTP dropped prefix-cache hits to ~1%. Details: [CYCLE_PLAN.md](../CYCLE_PLAN.md).

### Remaining Finals

Next launch is [freshrun1](../freshrun1/README.md): the 19.1 flag set, cold. MTP off, no cap, card default power. Its `flag-check.sh` calls [lib/flag-check.sh](flag-check.sh).

| Folder | Change from the base | Rule |
|---|---|---|
| [final-run3](../final-run3/README.md) | `--max-num-batched-tokens 8192`, cache flags omitted | Already launched. History row was not copied |
| [freshrun1](../freshrun1/README.md) | cold 19.1 flags: explicit prefix cache, image-default step size, MTP off, no cap | Next |
| [final-run4](../final-run4/README.md) | same flags as freshrun1 | Same profile, earlier copy |
| [final-run5](../final-run5/README.md) | best of final-run3 and final-run4 | 250 W only if p95 TPOT ≤ 40 ms |
| [final-run6](../final-run6/README.md), [final-run7](../final-run7/README.md) | repeat the best | |

`replay.py` is optional. Its prompts are random words, so its absolute numbers will not equal the grader's.

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

`run7` through `run15` were written when run6 was thought to have caching off. It does not: the image default is on, and that default is what scored 95.6. Those folders are not the next launches. The next launches are `final-run1` onward, and each of them keeps the run6 argument list.

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

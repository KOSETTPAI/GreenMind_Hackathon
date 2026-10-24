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

## Current status (2026-10-24 19:30 UTC+7)

| Run | Validation | Final |
|---|---|---|
| run4 full | 32.8 (50/100) | 0.0 (93/300) |
| run5 | 35.6 (57/100) | none |
| run6 | **95.6** (98/100) | **19.1** (127/300) |

Finals so far: run4 (#1, 0.0) and run6 (#2, 19.1). Next is `final-run1` (grader Final #3). Validations are optional works-checks of that server. The schedule is [CYCLE_PLAN.md](../CYCLE_PLAN.md). The target is Final `S` = 99.9 against the Final baseline.

run6 holds on Validation and falls apart on the Final. The Final's peak drove 111 requests running at once against 35 on the Validation, and p95 TPOT rose from 18 ms to 82 ms. Diagnosis: [run6/ANALYSIS.md](../run6/ANALYSIS.md).

run6 did not actually turn prefix caching off. This image enables it by default, and the default hit 87% (Validation) and 44% (Final) of prompt tokens. Profiles built on run6 keep it on. Do not add `--enable-prefix-caching`.

### Next runs (parent run6)

`final-run1` through `final-run7`, in the order in [CYCLE_PLAN.md](../CYCLE_PLAN.md). Each folder runs on its own: no launch guard, no replay. Its `start.sh` sets `GREENMIND_POWER_W` (empty means the card default, which `lib/start.sh` restores if an earlier run lowered it).

| Final | Folder | vLLM change from run6 | Power |
|---|---|---|---|
| final1 | [final-run1](../final-run1/README.md) | `--max-num-seqs 64` | default |
| final2 | [final-run2](../final-run2/README.md) | cap 64 + MTP k=1 | default |
| final3 | [final-run3](../final-run3/README.md) | cap 96 + MTP k=1 | default |
| final4 | [final-run4](../final-run4/README.md) | cap 96 + MTP k=1 | 250 W |
| final5 | [final-run5](../final-run5/README.md) | cap 96 + MTP k=1 | 225 W |
| final6 | [final-run6](../final-run6/README.md) | cap 96 + MTP k=2 | 250 W |
| final7 | [final-run7](../final-run7/README.md) | cap 96 + MTP k=1, or the best earlier Final | 250 W |

There are no separate Validation folders. A Validation slot, if used, runs on the next `final-runN` container as a works-check.

`replay.py` is optional. Its prompts are random words, its prefix hits come only from `--reuse-prob`, and it has no agentic multi-turn episodes, so its absolute numbers will not equal the grader's.

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

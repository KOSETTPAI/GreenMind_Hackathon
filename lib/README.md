# Shared launch scripts

`run5` through `run15` use the scripts here. `run4` keeps its own copies and its own profiles. Do not point a run4 launch at this directory.

Each later run is one change from its parent, taken from `GreenMind_Experimentation_Plan.md`. The profile in that run's folder is the whole vLLM argument list. `start.sh` launches exactly those arguments, and `preflight.sh` fails if the container has a different set.

| Script | Role |
|---|---|
| `start.sh` | `docker run`, wait for `/v1/models`, save a record under `~/greenmind-runs/<time>_<run>/`, run the preflight. Called by `<run>/start.sh`. Publishes `0.0.0.0:8000` unless `BIND` is set |
| `preflight.sh` | Read-only. Checks the container against the profile, then chat, streaming, a tool call, and thinking-on streaming |
| `preflight_checks.py` | The checks. Also rejects a profile that breaks the endpoint contract |
| `flag-check.sh` | Confirms every profile flag exists in `vllm serve --help`. No GPU, safe while a server is running |
| `warmup.py` | Grader-shaped warmup, including a two-turn tool call. Run after `READY`, before Submit, never during a graded window |
| `watch.sh`, `summarize.py` | One-second telemetry and its summary. Validation only |
| `power.sh` | One constant power limit. `run15` is the only run that should call it |
| `check-external.ps1` | From a PC: TCP, `/models`, and one chat to the public IP |

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

`run7` and everything after it is written as if prefix caching lost (run6). The measured hit rate on `run4` full was 1.0% of prompt tokens, which is why that is the default. If run5 scores higher, copy `run5/profile.args` into the kept branch and change only the line that run's README names.

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

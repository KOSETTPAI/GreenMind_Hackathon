# GreenMind Hackathon — Endpoint Runbook

Do not start a benchmark unless every required check below passes. A failed check costs minutes. A broken Validation or Final costs a submission slot and up to 30 minutes.

## Known configuration

| Item | Value |
|---|---|
| VM | `researcher@gm17` |
| Repository on the VM | `~/GreenMind_Hackathon` |
| Container | `mango-vllm` |
| Served model ID | `mango1.5-awq-w4a16` |
| Checkpoint | `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp` |
| Local API | `http://127.0.0.1:8000/v1` |
| Public API | `http://103.153.118.56:8000/v1` |
| E1 `--max-model-len` | `40960` (V0 is `32768`) |

## What has been verified, and what has not

Verified once: local inference returned `ENDPOINT_OK`, and Docker showed port 8000 published on `0.0.0.0`.

Not verified by that: reachability from outside the VM, and whether the next container launch has the intended flags.

**Bind.** `run4/start.sh` uses the `scripts/start-vllm.sh` method: `127.0.0.1:${PORT}:8000` by default. With `REPLACE=1` and no `BIND`, it keeps the bind of the container it replaces. It records the bind in the container label `greenmind.bind`. The preflight expects, in order: `EXPECTED_BIND` if set, that label, then `127.0.0.1`. A container whose actual binding differs from that expectation fails. Docker once reported `0.0.0.0` for the E1 container, so check `docker port mango-vllm` before replacing it.

## Files

| File | Where it runs | What it proves |
|---|---|---|
| `run4/preflight.sh` | VM | Docker, container state, port binding, exact vLLM arguments against a profile, served model and context, non-streaming reply, streaming with usage, a streaming tool call, and streaming with thinking on |
| `run4/preflight_checks.py` | VM, called by the script | The individual checks. Standard library only |
| `run4/profiles/*.args` | VM | The full vLLM argument list each experiment must have, and nothing more |
| `run4/check-external.ps1` | Your PC | TCP reach, `/models`, and one chat completion over the public IP |

`preflight.sh` is read-only. It never starts, stops, or reconfigures a container, and never touches clocks or the power limit. Its requests are small, but they still run on the GPU. Finish it before clicking Submit, never during a graded window.

Each run saves `preflight.log`, `inspect.json`, and `container-tail.log` under `~/greenmind-preflight/<timestamp>/`, outside the repository.

## Mandatory procedure before each benchmark

1. On the VM:

   ```bash
   cd ~/GreenMind_Hackathon
   docker inspect mango-vllm --format '{{json .Config.Cmd}}'
   ```

2. Confirm those arguments are the experiment you mean to run. E1 is V0 plus `--max-model-len 40960`. Nothing else is added: no `--max-num-seqs 32` or other tuning flag slipped in.

3. Run the preflight. `run4/start.sh` already does this after launch. A container from `run4/start.sh` carries labels, so no variables are needed. For other containers, name the profile and bind:

   ```bash
   ./run4/preflight.sh                                   # run4 container, or E1 on 127.0.0.1
   EXPECTED_BIND=0.0.0.0 ./run4/preflight.sh             # E1 published on all interfaces
   PROFILE=v0 ./run4/preflight.sh                        # scripts/start-vllm.sh defaults
   ```

   `EXPECTED_MAX_LEN` is still accepted, but it must agree with the profile. A different context length means a different profile, not a looser check.

4. If it prints `RESULT: PREFLIGHT FAILED`, stop. Fix the first `[FAIL]`, then rerun the whole script.

5. If the bind is `0.0.0.0`, check from your PC in PowerShell. A loopback bind cannot answer an outside client, so this check would fail by design:

   ```powershell
   powershell -ExecutionPolicy Bypass -File run4\check-external.ps1
   ```

   Use `-ExpectedMaxLen 32768` for V0. A local pass is not proof of public reachability.

6. Start the benchmark only when both report PASSED.

## Exit codes

| Code | `preflight.sh` | `check-external.ps1` |
|---|---|---|
| 0 | Ready | Reachable, expected model served |
| 1 | Do not benchmark | Do not benchmark |
| 2 | Usage error: bad profile, or `EXPECTED_MAX_LEN` contradicts the profile | — |

`[WARN]` lines do not block. A `0.0.0.0` bind always produces the exposure warning. Uncommitted changes in the repository and a thinking-on request that uses its whole 1024-token budget are also warnings, not failures.

## Adding an experiment

Copy `run4/profiles/e1.args` to a new file, change only that experiment's flags, and pass `PROFILE=<name>`. A run4 combined server gets its own profile, for example `r4-full.args`, with every flag it launches with. The preflight then rejects a container missing one of those flags or carrying an extra one.

## Troubleshooting

### Container missing or stopped

```bash
docker ps -a
docker logs --tail 100 mango-vllm
```

Do not start a second container on port 8000. The preflight fails if another container publishes the same host port.

### Port not published as expected

```bash
docker port mango-vllm
docker inspect mango-vllm --format '{{json .HostConfig.PortBindings}}'
```

Port bindings are fixed when the container is created. Changing them means removing and relaunching it, then rerunning every check.

### Arguments do not match the profile

The preflight lists each missing flag, wrong value, and unexpected flag. Relaunch with the intended experiment script. Do not edit the profile to match a container launched by mistake.

### `/models` fails locally

```bash
docker logs --tail 100 mango-vllm
curl -v --max-time 15 http://127.0.0.1:8000/v1/models
```

The model may still be loading. Look for startup errors, GPU memory errors, and port conflicts.

### `/models` works but inference fails

Read the response body the preflight prints and `container-tail.log`. Check that the request's model ID matches `--served-model-name` and that initialization finished.

### The tool-call check fails

The grader requires tool calling with `tool_choice=auto`. Confirm `--enable-auto-tool-choice --tool-call-parser qwen3_coder` are in the container arguments. Do not submit.

### Local works, external fails

Test from your PC, not from the VM. Check the cloud security rules, the VM firewall, and the Docker bind. A request to the public IP from inside the VM can fail on NAT loopback even when outside clients succeed.

## Benchmark discipline

- One experimental change per run, unless the run is the planned run4 combined server with its own profile.
- Keep the preflight record folder and the grader History row together for each run.
- Record model ID, context length, every non-default flag, image digest, power limit, and result in `experiments/log.md`.
- A passing preflight proves basic readiness. It says nothing about SLOs or energy under load.
- The API is unauthenticated. Restrict port 8000 to trusted addresses before leaving it open.

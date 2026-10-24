# experiments_thyme — Running the approach/ experiments

Launch configs and helper scripts for testing the ranked approaches in [approach/](../approach/README.md) on the A100 VM, one change per run.

**Status: untested.** Nothing here has been run. The files were checked statically: syntax, and a dry resolve of every config's `vllm serve` arguments. Flag names come from the approach files, which take them from the vLLM docs. Run `scripts/preflight.sh` on the VM before trusting a config.

---

## Files

```
experiments_thyme/
  README.md                       this file
  configs/README.md               approach → config map, run order, what has no config and why
  configs/_stack.conf             current winner of every approach (starts = scripts/start-vllm.sh)
  configs/A00_stack.conf          the stack unchanged: reference for the next test
  configs/A01–A13_*.conf          one config per tested value, each changing one thing vs the stack
  scripts/lib.sh                  defaults = scripts/start-vllm.sh; shared helpers
  scripts/preflight.sh            checks the config's flags exist in the vLLM image (no GPU used)
  scripts/apply-gpu-settings.sh   sets or resets power cap / clock lock before launch (approaches 2, 11)
  scripts/launch.sh               starts container "thyme-vllm" + writes a run record
  scripts/stop.sh                 removes thyme-vllm only (refuses other containers)
  scripts/smoke_grader_shape.py   streaming + thinking on + Thai + 2-turn tool call; TTFT/TPOT vs SLO
  scripts/telemetry.sh            1 s samples: power, util, clocks, running/waiting, KV use, tokens
  scripts/summarize_telemetry.py  energy estimate, util while busy, peak running, J/token, MTP acceptance
  results/log.md                  one row per Validation run
  results/runs/<utc>_<config>/    created by launch.sh: config, _stack.conf, exact command, image digest, vLLM version
```

## One run

```bash
S=experiments_thyme/scripts
C=experiments_thyme/configs/A02_power_200w.conf
$S/preflight.sh $C
$S/apply-gpu-settings.sh $C          # every config: sets its cap/clock or resets to defaults
$S/launch.sh $C
docker logs -f thyme-vllm            # wait for "Application startup complete"
python3 $S/smoke_grader_shape.py     # contract check + warm-up (approach 10)
$S/telemetry.sh experiments_thyme/results/runs/<run>/telemetry.csv &
# ... Validation submission in the grader UI; when it finishes: kill %1 ...
python3 $S/summarize_telemetry.py experiments_thyme/results/runs/<run>/telemetry.csv
$S/stop.sh
```

Log the run in [results/log.md](results/log.md). If it won by more than the A00-vs-A00 noise, with no per-class accuracy drop, write its value into [configs/_stack.conf](configs/_stack.conf). The order to follow is in [configs/README.md](configs/README.md).

---

## Baseline preserved

- `scripts/start-vllm.sh`, `scripts/test-*.sh`, `experiments/` and `approach/` are **unchanged**.
- `lib.sh` defaults and the starting `_stack.conf` copy the original script's values: image `vllm/vllm-openai:nightly`, model `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, served name `mango1.5-awq-w4a16`, bind `127.0.0.1:8000`, memory 0.85, max length 32768, `qwen3_coder` tool parser, `qwen3` reasoning parser, `--trust-remote-code`. The dry resolve of `A00_stack` gives exactly the original flags.
- Differences from the original launch:
  - Container name `thyme-vllm`, so it can't collide with `mango-vllm`.
  - No `--restart unless-stopped`, so a crashing config doesn't restart in a loop.
  - Run labels.
  - It refuses to start if the GPU is in use, or if the power limit doesn't match the config.
- `A01_baseline_bf16` reproduces the official scoring baseline (BF16, vLLM defaults) separately from the stack.

### Two issues inherited from the original script (flagged, not changed in the stack)

1. **`MAX_MODEL_LEN=32768`.** Long-context prompts go up to 32K and `max_tokens` is 8192, so some requests may be rejected. `A08a_max_len_40960` tests the fix. Run it early if long-context requests error.
2. **`BIND_ADDR=127.0.0.1`.** The grader calls `http://<vm-ip>:<port>/v1`. The team's deployment notes say the health check passed, so they may be using a proxy or tunnel. Confirm how before setting `BIND_ADDR=0.0.0.0` in `_stack.conf`.

## Rule compliance

- Open-source vLLM flags only, set at launch and constant for the whole run. Power cap and clock lock are applied before launch and never changed during a run.
- One serving process on our own GPU. No response caching, no LD_PRELOAD, no NVML changes.
- `telemetry.sh` only reads `nvidia-smi` and `GET /metrics`. To stay clearly within "no other workloads during a graded run", use it on **Validation runs only**, not on Final.

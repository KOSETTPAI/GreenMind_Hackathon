# VM sequence

Run from the repository root on the VM. Each launch refuses to delete `mango-vllm`. Remove the previous container deliberately, then start the next one.

Unset leftover serving variables first:

```bash
unset GPU_MEMORY_UTILIZATION MAX_MODEL_LEN MAX_NUM_SEQS MAX_NUM_BATCHED_TOKENS
unset ENABLE_CHUNKED_PREFILL SPECULATIVE_CONFIG PREFIX_CACHING EXTRA_VLLM_ARGS
```

`experiments/adopted.env` stays empty until a Validation is kept.

## 0. Record V0

Copy the grader History row for the existing `scripts/start-vllm.sh` run into `experiments/log.md`. No new container and no submission.

Record the image digest on the VM:

```bash
docker inspect --format '{{.Image}}' mango-vllm
```

Check whether chunked prefill is already on:

```bash
docker logs mango-vllm 2>&1 | less
```

## 1. Context length

```bash
docker rm -f mango-vllm
bash experiments/01-max-model-len/start.sh
```

Smoke-test, start `bash experiments/watch-run.sh`, submit one Validation, then fill the E1 row. Keep `HELD_MAX_MODEL_LEN=40960` only if SLO-met and `S` do not fall. A flat pass count still keeps 40960, because a 32K prompt plus `max_tokens=8192` needs 40960.

## 2. Batched-token budget

Isolated from V0, leave `adopted.env` empty. After a kept E1:

```bash
# experiments/adopted.env
HELD_MAX_MODEL_LEN=40960
```

```bash
docker rm -f mango-vllm
ADOPT_PREVIOUS=1 bash experiments/02-batched-tokens/start.sh 4096
```

`2048` and `8192` are later single-value runs. Read History before another value. Clear `HELD_MAX_NUM_BATCHED_TOKENS` before replacing the budget.

Skip the next script when the log already shows chunked prefill enabled. Otherwise:

```bash
docker rm -f mango-vllm
CONFIRM_CHUNKED=log-says-off ADOPT_PREVIOUS=1 bash experiments/02b-chunked-prefill/start.sh
```

Do not submit if the flag is rejected or the log says chunked prefill stayed off.

## 3. MTP

Confirm `--speculative-config` in `vllm serve --help` before this step. The method string is `mtp`. If startup rejects it, record the log and stop. Switching to `qwen3_next_mtp` would be a different experiment, and it is not one of these scripts.

```bash
docker rm -f mango-vllm
ADOPT_PREVIOUS=1 bash experiments/03-mtp/start-k1.sh
```

Submit only after tool calls and `bash experiments/10-warmup/warmup.sh` succeed. Record the acceptance counter from `http://127.0.0.1:8000/metrics`.

`k=2` and `k=3` wait until a smaller `k` raises `S` and tool calls still parse. Clear `HELD_SPECULATIVE_TOKENS` first:

```bash
docker rm -f mango-vllm
CONFIRM_K=2 ADOPT_PREVIOUS=1 bash experiments/03-mtp/start-k2.sh
```

## 4. Prefix caching

```bash
docker rm -f mango-vllm
ADOPT_PREVIOUS=1 bash experiments/04-prefix-caching/start.sh
bash experiments/04-prefix-caching/check-hits.sh
```

Submit only when the startup log says prefix caching is enabled and `check-hits.sh` exits 0. A disabled cache or a zero hit increase is not a submission.

## 5. GPU memory, then active sequences

Both wait until a History row shows p95 TPOT under 50 ms. Start memory at `0.90`. Clear `HELD_GPU_MEMORY_UTILIZATION` before `0.92` or `0.95`.

```bash
docker rm -f mango-vllm
CONFIRM_TPOT=under-50ms ADOPT_PREVIOUS=1 bash experiments/05-gpu-memory/start.sh 0.90
```

An out-of-memory startup is a revert.

Read the V0 log's default `max_num_seqs` before the first explicit value. Skip a value that is already the default. If that default is already above 64 and p95 TPOT is under 50 ms, the first step is the next allowed value above the default. Clear `HELD_MAX_NUM_SEQS` between values.

```bash
docker rm -f mango-vllm
CONFIRM_TPOT=under-50ms ADOPT_PREVIOUS=1 bash experiments/06-max-num-seqs/start.sh 64
```

Stop the sweep when SLO-met stops rising or p95 TPOT nears 50 ms.

## 6. Power cap

Only after SLO-met is at least 90/100 on the kept server. The cap is host-side and stays constant for the whole window. Record `RECORDED_PREVIOUS_LIMIT_W` from the script output.

```bash
bash experiments/07-power-cap/show-power.sh
CONFIRM_SLO=at-least-90 bash experiments/07-power-cap/set-power-cap.sh 250
```

That prints the current limit and does not change it. Apply with `CONFIRM=1` added, before Submit, then leave it alone. Next values are 200 W, then 175 W. 150 W is not in this sequence.

Between runs, restore the recorded limit:

```bash
CONFIRM=1 bash experiments/07-power-cap/restore-power-cap.sh 400
```

Use the recorded number. `400` is only the usual A100-SXM4-40GB limit.

## 7. Confirmation, then Final

One more Validation of the kept configuration, with `bash experiments/10-warmup/warmup.sh` after the server is ready and before Submit. Then one Final. No new flag on that pair.

`WARMUP_LONG=1` adds an approximately 20k-word prefill so long-context kernels compile. Skip it if the energy window includes pre-submit traffic.

## Flag check

Before the first use of a flag that V0 does not already pass:

```bash
docker run --rm --entrypoint vllm vllm/vllm-openai:nightly serve --help
```

If that entrypoint form fails, the image's own entrypoint is the one `scripts/start-vllm.sh` already uses. Read `--help` from a shell in that image and compare the flag name with the experiment script before Submit.

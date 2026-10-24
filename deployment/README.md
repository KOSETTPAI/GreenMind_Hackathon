# GreenMind Inference Deployment

## Tested environment

- GPU: NVIDIA A100-SXM4-40GB
- OS: Ubuntu 24.04
- Serving: Docker + vLLM OpenAI-compatible server
- Model: CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp
- Served model ID: mango1.5-awq-w4a16
- API: /v1/chat/completions
- Maximum model length on the scored run: 32768 (too small for a 32K prompt plus 8192 output tokens; the next run sets 40960)
- Tool calling: qwen3_coder parser
- Reasoning parser: qwen3
- Speculative decoding: off on the scored run, even though the checkpoint name includes MTP
- Prefix caching: off on the scored run
- Power cap: none on the scored run

## Container configuration

The initial working deployment used:

- Image: vllm/vllm-openai:nightly
- GPU memory utilization: 0.85
- Port: 8000
- Hugging Face cache: ~/.cache/huggingface
- Automatic tool choice enabled

The nightly image is mutable. Record the exact image digest and vLLM version
when reproducing or comparing performance results. The digest for the scored
run below was not saved.

## Scored run

Indicative Validation of the defaults in `scripts/start-vllm.sh`:

- `S = 34.8`
- SLO-met = 56/100
- `A`, `s_E`, `s_T`, `s_L`, joules, and p95 latency are still blank in `experiments/log.md` until History is copied

Those 44 misses are the first problem. The launch does not set MTP, prefix caching, a batched-token budget, or a power cap. GPU memory utilization is 0.85. Leave the power cap off until a later Validation reaches at least 90/100 SLO-met.

This repo cannot see the VM's Docker daemon. Sync the script to the VM, recreate the container there, and submit on the grader. The step list is `experiments/vm-sequence.md`.

## Start a new deployment

Review `scripts/start-vllm.sh` before running it. The script binds its published
port to localhost by default. The grader health check already passed on that
bind, so leave it. An existing container named `mango-vllm` must be removed
on the VM first (`docker rm -f mango-vllm`); the script will not replace it.

Defaults match the scored server. `scripts/start-vllm.sh` reads `MAX_MODEL_LEN` (default `32768`), `GPU_MEMORY_UTILIZATION` (default `0.85`), and the identity variables `MODEL_ID`, `SERVED_MODEL_NAME`, `VLLM_IMAGE`, `PORT`, and `CONTAINER_NAME`.

It does not read `MAX_NUM_SEQS`, `MAX_NUM_BATCHED_TOKENS`, `ENABLE_CHUNKED_PREFILL`, `SPECULATIVE_CONFIG`, or `PREFIX_CACHING`. Exporting those variables does not change the scored server.

Later one-flag experiments are the scripts in `experiments/`. The first context-length change is the same server either way:

```bash
docker rm -f mango-vllm
MAX_MODEL_LEN=40960 ./scripts/start-vllm.sh
```

```bash
unset MAX_MODEL_LEN GPU_MEMORY_UTILIZATION
docker rm -f mango-vllm
bash experiments/01-max-model-len/start.sh
```

Follow `experiments/vm-sequence.md` after that. Each experiment script adds one flag to the V0 command. An existing `mango-vllm` container is left in place until you remove it.

Confirm a new flag with `vllm serve --help` inside the image before a graded run. Nightly flag names can differ.

## Diagnostics

Check model discovery:

    curl -fsS http://127.0.0.1:8000/v1/models

Inspect container logs:

    docker logs --tail 100 mango-vllm

Run API tests on the VM after the model is loaded, and before Submit:

    bash scripts/test-chat.sh
    bash scripts/test-stream.sh
    bash scripts/test-tool-calling.sh
    bash experiments/10-warmup/warmup.sh

`test-chat.sh` and `test-stream.sh` send `enable_thinking: false`. The grader turns thinking on. `experiments/10-warmup/warmup.sh` is the graded-path check: streaming requests with thinking enabled, including a tool call. If it fails, or if tool calls fail, do not submit. After the prefix-caching experiment, also run `bash experiments/04-prefix-caching/check-hits.sh` and submit only when it exits 0.

For a remote endpoint, set BASE_URL explicitly, for example:

    BASE_URL=http://YOUR_VM_HOST:8000/v1 ./scripts/test-chat.sh

Before clicking Submit, start `bash experiments/watch-run.sh`. It records `nvidia-smi dmon` and snapshots of `http://127.0.0.1:8000/metrics`. Stop it when the grader finishes. Keep `docker logs` as well. A host power cap, when a later step calls for one, is documented in `experiments/07-power-cap/README.md`. Run that on the VM host, not inside the container.

## Initial smoke-test results

- Model discovery: passed
- Non-streaming chat: passed
- Streaming response and usage: passed
- Automatic tool-call generation: passed
- Official grader health check: passed

These are initial smoke tests, not a claim that the full benchmark passed.
The first official result is the indicative Validation above. Record later
Validation and Final rows in `experiments/log.md`.

## Security

- Never commit passwords, API keys, SSH private keys, or grader credentials.
- Do not commit Hugging Face caches or model weights.
- Restrict access to the serving API according to organizer instructions.
- Keep the GPU dedicated to the hackathon evaluation during graded runs.

# GreenMind Inference Deployment

## Tested environment

- GPU: NVIDIA A100-SXM4-40GB
- OS: Ubuntu 24.04
- Serving: Docker + vLLM OpenAI-compatible server
- Model: CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp
- Served model ID: mango1.5-awq-w4a16
- API: /v1/chat/completions
- Maximum model length configured: 32768
- Tool calling: qwen3_coder parser
- Reasoning parser: qwen3

## Container configuration

The initial working deployment used:

- Image: vllm/vllm-openai:nightly
- GPU memory utilization: 0.85
- Port: 8000
- Hugging Face cache: ~/.cache/huggingface
- Automatic tool choice enabled

The nightly image is mutable. Record the exact image digest and vLLM version
when reproducing or comparing performance results.

## Start a new deployment

Review scripts/start-vllm.sh before running it. The script binds its published
port to localhost by default for safer access. Configure networking according
to the official grader requirements.

## Diagnostics

Check model discovery:

    curl -fsS http://127.0.0.1:8000/v1/models

Inspect container logs:

    docker logs --tail 100 mango-vllm

Run API tests:

    ./scripts/test-chat.sh
    ./scripts/test-stream.sh
    ./scripts/test-tool-calling.sh

For a remote endpoint, set BASE_URL explicitly, for example:

    BASE_URL=http://YOUR_VM_HOST:8000/v1 ./scripts/test-chat.sh

## Initial smoke-test results

- Model discovery: passed
- Non-streaming chat: passed
- Streaming response and usage: passed
- Automatic tool-call generation: passed
- Official grader health check: passed

These are initial smoke tests, not a claim that the full benchmark passed.
Record Validation and Final results separately.

## Security

- Never commit passwords, API keys, SSH private keys, or grader credentials.
- Do not commit Hugging Face caches or model weights.
- Restrict access to the serving API according to organizer instructions.
- Keep the GPU dedicated to the hackathon evaluation during graded runs.

# Warmup before Submit

Approach 10. This is preparation, not a serving-flag experiment. No launch script here passes `--enforce-eager`, so CUDA graphs stay at the vLLM default.

## What it sends

`warmup.sh` streams three short graded-path requests with thinking enabled: a numeric question, a Thai question, and a tool call. It exits non-zero when the tool stream has no `tool_calls` field.

```bash
bash experiments/10-warmup/warmup.sh
```

`WARMUP_LONG=1` adds one prefill of about 20,000 copies of the word `context`, then eight output tokens. That is there so a long-prefill kernel can compile before the first graded long prompt. It is not a measured 20K-token count.

## Expected scoring impact

Triton kernels and CUDA graphs are captured on first use. Requests during the ramp can miss TTFT or TPOT while that compile happens, and those misses still count in `η` and can count in `s_T`.

Warmup can raise early SLO-met only when its joules sit outside the grader window. The energy boundary in this repo is the NVML counter for the evaluation, and idle inside that window counts. If the counter includes this script, the long prefill adds joules and can lower `η`. Run the short warmup immediately before Submit, record whether the window had already started, and skip `WARMUP_LONG` when that is unclear.

`A` is unchanged if these prompts are discarded by the grader. A tool-call failure here is a reason to skip Submit. `scripts/test-chat.sh` and `scripts/test-stream.sh` disable thinking, so they do not cover this path.

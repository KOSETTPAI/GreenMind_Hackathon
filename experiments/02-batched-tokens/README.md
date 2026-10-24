# E2 — batched-token budget

Approach 6. Run this after E1 has a History row.

## Change

One new flag, `--max-num-batched-tokens`. V0 does not set it. The first value to submit is `4096`. `2048` and `8192` are later one-value runs.

```bash
bash experiments/02-batched-tokens/start.sh 4096
```

With E1 kept:

```bash
ADOPT_PREVIOUS=1 bash experiments/02-batched-tokens/start.sh 4096
```

This script does not pass `--enable-chunked-prefill`. That is E2b.

## Expected scoring impact

The workload's long prompts are the prefill bursts. A long prefill in one step stalls other requests' decode. TPOT above 50 ms fails SLO condition 5, and those failures still consume energy.

| Component | Expected direction | Condition |
|---|---|---|
| SLO-met and `s_L` | Up | V0 misses are TPOT stalls during long prefills, and 4096 is below the current step size |
| `s_E` | Up | More SLO-met requests per joule, including fewer decode stalls |
| `s_T` | Up | Peak-phase requests that were TPOT failures start passing |
| TTFT on long prompts | Worse if 4096 is too small | TTFT SLO is `0.5 + 0.25 × prompt_tokens / 1000` (2.0 s at 6K tokens, 5.5 s at 20K) |
| `A` | Unchanged | The checkpoint and parsers stay the same |

If the nightly default is already 4096, expect a flat score and keep the explicit flag only for reproducibility. Read the startup log before calling it a win. Clear `HELD_MAX_NUM_BATCHED_TOKENS` before submitting 2048 or 8192.

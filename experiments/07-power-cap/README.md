# E7 — fixed GPU power cap

Approach 2. This is a host setting, not a vLLM flag. It is not the next run while V0 is 56/100 SLO-met.

## Change

One constant cap for the whole graded window. The sweep is `250`, then `200`, then `175` watts. `150` is outside this sequence.

```bash
bash experiments/07-power-cap/show-power.sh
CONFIRM_SLO=at-least-90 bash experiments/07-power-cap/set-power-cap.sh 250
CONFIRM_SLO=at-least-90 CONFIRM=1 bash experiments/07-power-cap/set-power-cap.sh 250
```

The first `set-power-cap.sh` invocation prints `RECORDED_PREVIOUS_LIMIT_W` and does not change the card. `CONFIRM=1` applies it. Run both on the VM host, outside the container, before Submit. Leave the cap untouched until the grader finishes.

Restore between runs with the recorded number:

```bash
CONFIRM=1 bash experiments/07-power-cap/restore-power-cap.sh RECORDED_WATTS
```

The restore script accepts 300 through 450 W. The A100-SXM4-40GB limit is usually 400 W. Persistence mode is turned on with the cap and left on.

Server flags stay at the kept configuration in `adopted.env`. Do not put the cap in that file.

## Expected scoring impact

Published A100 results on other models, cited in approach 2, saw about 23% less energy and about 7% more time from 250 W down toward 175 W. Those are not MANGO measurements. Decode is the memory-bound phase, so a cap can cut watts more than it stretches the step. Prefill and long TTFT limits remain sensitive to clocks.

| Component | Expected direction | Condition |
|---|---|---|
| `s_E` | Up | SLO-met stays put while joules fall. Exponent 0.6 is why this is worth doing late |
| SLO-met, `s_T`, `s_L` | Down if the cap is too low | p95 TPOT over 50 ms, or long-prompt TTFT over `0.5 + 0.25 × prompt_tokens / 1000`, shrinks the numerator of `η` |
| `A` | Unchanged | The weights and sampling stay the same |

Do not start the sweep before SLO-met is at least 90/100. A slower decode on today's 56/100 server fails more TPOT checks and can lower `S` even if the watt reading looks better. Energy is the integral of power over the whole window, idle included. A lower watt reading with a longer window can be more joules.

The cap has to stay constant for the entire run. Changing it after the grader starts is the dynamic case approach 18 forbids. Clocks are not locked here.

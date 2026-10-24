# E2b — chunked prefill flag

Approach 6, split from the token budget so the two effects can be scored separately.

## Change

One new flag: `--enable-chunked-prefill`. The token budget is untouched by this script.

```bash
CONFIRM_CHUNKED=log-says-off bash experiments/02b-chunked-prefill/start.sh
```

The confirm string means the previous server log says chunked prefill is off. If it is already on, skip this Validation.

## Expected scoring impact

Same mechanism as E2: long prefills stop blocking decode, so TPOT and peak SLO-met can rise. A long prompt then takes more steps, so its TTFT can rise toward its own SLO.

Recent vLLM nightlies sometimes enable chunked prefill by default and reject `--enable-chunked-prefill`. An unrecognized-argument exit is an invalid startup. Do not submit it, and do not replace the flag inside this script.

`A` should stay put. Revert when SLO-met or `S` falls, or when the log says the hybrid model disabled the feature.

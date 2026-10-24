# E5 — GPU memory utilization

Approach 8, after the latency and MTP steps. V0 uses `0.85`.

## Change

One replacement of `--gpu-memory-utilization`. Allowed values are `0.90`, then `0.92`, then `0.95`.

```bash
CONFIRM_TPOT=under-50ms ADOPT_PREVIOUS=1 bash experiments/05-gpu-memory/start.sh 0.90
```

The confirm string means a History row already shows p95 TPOT under 50 ms. Clear `HELD_GPU_MEMORY_UTILIZATION` before the next value. `0.85` is the baseline, not a step in this sweep.

## Expected scoring impact

The extra fraction of the 40 GB card becomes KV and recurrent-state cache. Fewer preemptions means less recomputation and less queueing at 4 req/s.

| Component | Expected direction | Condition |
|---|---|---|
| SLO-met and `s_T` | Up | Preemptions were dropping peak requests, and p95 TPOT is still under 50 ms |
| `s_E` | Slightly up | Less recompute, with a similar busy window |
| `s_L` | Down if the GPU is already at the TPOT ceiling | More concurrent state can slow each step past 50 ms |
| `A` | Unchanged | |
| Whole submission | Invalid | An out-of-memory crash leaves unfinished requests failed at the 30 minute cap |

Start at `0.90`. A crash at `0.95` spends one of the five hourly Validation slots. Revert to the last value that stayed up for the whole run.

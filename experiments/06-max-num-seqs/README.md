# E6 — max active sequences

Approach 5. V0 does not pass `--max-num-seqs`, so the nightly default is unknown until the V0 log is copied.

## Change

One new flag. Allowed values: `64`, `128`, `192`, `256`.

```bash
CONFIRM_TPOT=under-50ms ADOPT_PREVIOUS=1 bash experiments/06-max-num-seqs/start.sh 128
```

Read the default from the V0 startup log first. Skip a value equal to that default. Clear `HELD_MAX_NUM_SEQS` before the next value. The confirm string means p95 TPOT is already under 50 ms. Raising concurrency while TPOT is already over the SLO makes more of the 44 misses, not fewer.

## Expected scoring impact

Decode reads the weights once per step. More sequences in that step share the read, so joules per token can fall. Each step also gets slower. The score peak is the largest concurrency whose p95 TPOT stays under 50 ms and whose SLO-met count is still rising.

| Component | Expected direction | Condition |
|---|---|---|
| `s_E` | Up | Weight traffic is amortized and SLO-met does not fall |
| `s_T` and SLO-met | Up, then down | Queueing falls until TPOT or preemptions miss the SLO |
| `s_L` | Down as the batch grows | Stop at the value before p95 TPOT reaches 50 ms |
| `A` | Unchanged | |

`64` can be a decrease from the nightly default. That would raise queueing and can worsen TTFT. Record the default before the first run. Re-tune this knob again after MTP, because draft state uses memory per sequence.

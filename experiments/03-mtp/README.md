# E3 — MTP speculative decoding

Approach 4. The checkpoint name already includes `mtp`. V0 leaves speculative decoding off.

## Change

One flag, `--speculative-config`, with method `mtp`.

| Script | Draft tokens | When |
|---|---:|---|
| `start-k1.sh` | 1 | Next MTP run |
| `start-k2.sh` | 2 | After `k=1` raises `S` and tool calls still parse. Requires `CONFIRM_K=2` |
| `start-k3.sh` | 3 | After a smaller `k` raises `S`. Requires `CONFIRM_K=3` |

```bash
ADOPT_PREVIOUS=1 bash experiments/03-mtp/start-k1.sh
```

Clear `HELD_SPECULATIVE_TOKENS` before `k=2` or `k=3`. Two MTP configs cannot stack.

If startup rejects method `mtp`, stop. `qwen3_next_mtp` is named in approach 4 as another vLLM method and is not what these scripts pass. Trying it is a new experiment and needs its own log row.

## Expected scoring impact

The MTP head drafts `k` tokens and the target model verifies them. Accepted drafts turn one weight read into several output tokens. Verification that disagrees costs extra work.

| Component | Expected direction | Condition |
|---|---|---|
| `s_E` | Up | Mean acceptance is high enough that decode GPU-seconds fall |
| `s_L` TPOT | Up | More output tokens per step, and p95 TPOT moves toward or under 50 ms |
| `s_T` | Up or flat | The 4 req/s peak has large batches, where verification can spend the gain |
| SLO-met | Up when TPOT was the miss | Down if extra memory causes preemptions or the process fails tool calls |
| `A` | Flat at temperature 0 | Any macro or tool-JSON regression is a revert. Full `A` before the class factor is about 85.5% |

There is no MANGO acceptance rate in this repo, so there is no numeric `S` forecast. Record the acceptance metric from `/metrics`.

Do not submit a process that fails `bash scripts/test-tool-calling.sh` or `bash experiments/10-warmup/warmup.sh`. The reasoning parser stays `qwen3` on every MTP launch.

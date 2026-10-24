# run4 log

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. `η = SLO-met / joules`, `η_base = 0.00154`. Blank cells are not zeros; copy them from grader History.

## Reference: E1 (Validation 2026-10-24 07:56:39 UTC)

| Field | Value |
|---|---|
| Server | V0 plus `--max-model-len 40960` (`run4/profiles/e1.args`) |
| `S`, `A`, `s_E`, `s_T`, `s_L` | |
| SLO-met | |
| Joules | |
| p95 TTFT, p95 TPOT | |
| Visible accuracy | 52 of 63 visible requests. `math` 1/4, agentic 11/17 |
| Note | The three last `math` requests ran 72–82 s, likely 8192-token cutoffs. See `experiments/results/2026-10-24T075639Z-validation.md` |

## Submissions

| # | Time (UTC) | Tier | Power limit | Image digest | `S` | `A` | `s_E` | `s_T` | `s_L` | SLO-met | Joules | p95 TTFT | p95 TPOT | MTP acceptance | Prefix hit rate | Preemptions | Decision |
|---:|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | | full | default | | | | | | | | | | | | | | |

## Startup facts per tier

Copy from `~/greenmind-runs/<run>/startup.log` and `start.sh` output.

| Tier | Started? | MTP active | Prefix caching enabled | Max concurrency at 40960 | `max_num_batched_tokens` | `max_num_seqs` | Notes |
|---|---|---|---|---|---|---|---|
| full | | | | | | | |

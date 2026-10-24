# Experiment log

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`.

`η = SLO-met / joules`, `s_E = clip(ln(η / η_base) / ln 3, 0, 1)`. Full `A` before the class factor starts at `R ≥ 0.98`.

| Track | `η_base` | Reference macro-accuracy | Retention `R` |
|---|---|---|---|
| Validation (practice) | 0.00154 | 87.2% | macro-accuracy / 0.872 |
| **Final (graded, the only one that counts)** | **0.00163** | **87.8%** | macro-accuracy / 0.878 |

Every row below is a Validation row, so its `η / 0.00154` column uses the Validation baseline.

Blank cells are not zeros. Copy them from grader History.

## V0 — scored baseline

| Field | Value |
|---|---|
| ID | V0 |
| Script | `scripts/start-vllm.sh` |
| Track | Validation, indicative |
| Model | `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp` |
| Served name | `mango1.5-awq-w4a16` |
| Image | `vllm/vllm-openai:nightly` |
| Image digest | not recorded |
| GPU memory utilization | 0.85 |
| max_model_len | 32768 |
| max_num_seqs | vLLM default, not recorded |
| max_num_batched_tokens | unset |
| Chunked prefill | not recorded from the log |
| MTP | off |
| Prefix caching | off |
| Power cap | none |
| `S` | 34.8 |
| SLO-met | 56/100 |
| Macro-accuracy | |
| `A` | |
| Joules | |
| `η` | |
| `η / 0.00154` | |
| `s_E` | |
| `s_T` | |
| `s_L` | |
| p95 TTFT | |
| p95 TPOT | |
| Decision | Baseline for every diff below. Next launch is E1 only |

## E1 — Validation 2026-10-24 07:56:39 UTC

| Field | Value |
|---|---|
| Grader file | `team-team17-validation-20261024T075639-0ad015-r1.jsonl` |
| Server config | `experiments/01-max-model-len/start.sh`: V0 plus `--max-model-len 40960` |
| History row (`S`, `A`, `s_E`, `s_T`, `s_L`, SLO-met, joules, p95 TTFT, p95 TPOT) | not copied yet |
| Visible accuracy | 52 of 63 visible requests scored 1.00 |
| Weakest visible families | `math` 1/4, agentic 11/17 |
| Notable | Requests 98–100 (`math`) took 72.5–81.5 s; every other visible request finished within 29.7 s. Likely 8192-token cutoffs that also stretch the energy window |
| Detail | [results/2026-10-24T075639Z-validation.md](results/2026-10-24T075639Z-validation.md) |
| Decision | Keep 40960 (required for a 32K prompt plus 8192 output tokens). Fill the History row before comparing `S` with V0. run4 builds on this server |

## Hypotheses written before the runs

| ID | Single change | Hypothesis | Result | Decision |
|---|---|---|---|---|
| E1 | `--max-model-len 40960` | A 32K prompt plus 8192 output tokens cannot fit in 32768, so some of the 44 misses are context errors or cutoffs. Fitting them raises the numerator of `η`. | Ran 07:56 UTC. Visible `longctx` 5/5. History row not copied yet | Keep |
| E2 | `--max-num-batched-tokens 4096` | Long prefills are blocking decode and failing the 50 ms TPOT check. A 4096 token step budget raises peak SLO-met without a matching rise in joules. | | |
| E2b | `--enable-chunked-prefill` | Chunked prefill is off in the previous log. Enabling it moves the same TPOT failures into SLO-met. | | |
| E3 | MTP `k=1` | Accepted draft tokens cut decode steps, joules, and TPOT, while temperature 0 verification holds `A` and tool JSON. | | |
| E3b | MTP `k=2` | `k=1` raised `S` and tool calls still parsed. One more draft token still pays for itself at the 4 req/s peak. | | |
| E3c | MTP `k=3` | The previous `k` raised `S`. Three draft tokens still pay for themselves. | | |
| E4 | prefix caching, `mamba-cache-mode align` | Shared agent and RAG prefixes cut prefill joules and TTFT, and the startup log shows hits. | | |
| E5 | `--gpu-memory-utilization 0.90` then `0.92` then `0.95` | Extra cache cuts preemptions while p95 TPOT is still under 50 ms, so SLO-met rises. | | |
| E6 | `--max-num-seqs` one of 64, 128, 192, 256 | A larger decode batch amortizes each weight read until p95 TPOT nears 50 ms. | Deprioritized: about 40–60 concurrent requests at peak, under the usual default of 256 | |
| E7 | constant 250 W, then 200 W, then 175 W | With SLO-met already at least 90/100, a lower constant cap cuts joules more than it adds time. | | |

## Row template

| Field | Value |
|---|---|
| ID | |
| Date | |
| Script and arguments | |
| `ADOPT_PREVIOUS` | |
| Image digest | |
| Power limit | |
| Hypothesis | |
| Macro-accuracy and weakest class | |
| SLO-met | |
| Joules, `η`, `η / 0.00154`, `s_E` | |
| `s_T`, `s_L`, p95 TTFT, p95 TPOT | |
| `A`, `S` | |
| Preemptions, errors, acceptance or cache hits | |
| Decision | keep, revert, or invalid startup |

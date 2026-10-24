# Experiment log

Score: `S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`.

`η = SLO-met / joules`, `η_base = 0.00154`, `s_E = clip(ln(η / 0.00154) / ln 3, 0, 1)`.

Reference macro-accuracy `87.2%`. Retention `R = macro-accuracy / 0.872`. Full `A` before the class factor starts at `R ≥ 0.98`.

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

## Hypotheses written before the runs

| ID | Single change | Hypothesis | Result | Decision |
|---|---|---|---|---|
| E1 | `--max-model-len 40960` | A 32K prompt plus 8192 output tokens cannot fit in 32768, so some of the 44 misses are context errors or cutoffs. Fitting them raises the numerator of `η`. | | |
| E2 | `--max-num-batched-tokens 4096` | Long prefills are blocking decode and failing the 50 ms TPOT check. A 4096 token step budget raises peak SLO-met without a matching rise in joules. | | |
| E2b | `--enable-chunked-prefill` | Chunked prefill is off in the previous log. Enabling it moves the same TPOT failures into SLO-met. | | |
| E3 | MTP `k=1` | Accepted draft tokens cut decode steps, joules, and TPOT, while temperature 0 verification holds `A` and tool JSON. | | |
| E3b | MTP `k=2` | `k=1` raised `S` and tool calls still parsed. One more draft token still pays for itself at the 4 req/s peak. | | |
| E3c | MTP `k=3` | The previous `k` raised `S`. Three draft tokens still pay for themselves. | | |
| E4 | prefix caching, `mamba-cache-mode align` | Shared agent and RAG prefixes cut prefill joules and TTFT, and the startup log shows hits. | | |
| E5 | `--gpu-memory-utilization 0.90` then `0.92` then `0.95` | Extra cache cuts preemptions while p95 TPOT is still under 50 ms, so SLO-met rises. | | |
| E6 | `--max-num-seqs` one of 64, 128, 192, 256 | A larger decode batch amortizes each weight read until p95 TPOT nears 50 ms. | | |
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

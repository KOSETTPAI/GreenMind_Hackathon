# Hackathon Evaluation Test — Scoring Criteria

## 1. Overview

The hackathon ranks submissions with one technical score:

```
S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2
```

- `S` — technical score.
- `A` — accuracy factor, from 0.05 to 1.
- `s_E` — energy score.
- `s_T` — throughput score.
- `s_L` — latency score.

The factors multiply. Energy has the largest exponent. Throughput and latency saturate at 1.

## 2. Evaluation tracks

| Track | Requests | Purpose | Counts toward the graded result? |
|---|---:|---|---|
| Validation | 100 | Practice and iteration. The score is indicative only. | No |
| Final Test | 300 | One graded evaluation round. | Yes. Final is the only graded result. |

- Each round is capped at 30 minutes.
- Requests unfinished at the cap count as failed.
- Validation allows 5 finished submissions per hour. Final allows 2 per hour.
- Final grader submissions close on 25 October 2026 at 11:00.

## 3. Baseline and energy target

The baseline is the untuned model served with default vLLM in BF16.

The live grader page shows one baseline for this event:

| Parameter | Active value |
|---|---|
| Baseline energy efficiency (`η_base`) | `0.00154` SLO-met requests/J |
| Energy multiplier for full marks (`K`) | `3×` |
| Full energy marks | `η ≥ 0.00462` (about 216 J per SLO-met request) |
| Reference macro-accuracy | `87.2%` |

An earlier note of the Final header used `0.00163` SLO-met requests/J and `87.8%` macro-accuracy. That pair is not the live page. Use `0.00154` and `87.2%` unless a Final page shows the other pair again.

Energy efficiency:

```
η = SLO-met requests / GPU energy in joules
```

- Energy is the NVML counter.
- Idle energy is included.
- Full energy marks are `3×` baseline efficiency.

```
s_E = clip( ln(η / 0.00154) / ln 3 , 0, 1 )
```

| Efficiency relative to baseline | Energy score (`s_E`) |
|---|---:|
| `1.00×` | `0.00` |
| `1.25×` | `0.20` |
| `1.50×` | `0.37` |
| `2.00×` | `0.63` |
| `2.50×` | `0.83` |
| `3.00×` or higher | `1.00` |

The untuned baseline scores `S = 0` because `s_E = 0` at `η = η_base`.

## 4. What counts as SLO-met

A request counts only when all five conditions pass:

1. The response is streamed, so TTFT can be observed.
2. There is no error or timeout. The timeout is 900 seconds.
3. The response is not cut off at 8,192 output tokens.
4. TTFT is within `0.5 + 0.25 × prompt_tokens / 1000` seconds.
5. TPOT is at most 50 ms. This condition is skipped for one-token answers.

Examples: 300 prompt tokens → 0.575 s TTFT; 6,000 → 2.0 s; 20,000 → 5.5 s.

Failed, late, and cut-off requests still add joules and add nothing to the numerator. Work still running at 30 minutes fails.

## 5. Accuracy factor (`A`)

```
R = your macro-accuracy / 0.872
x = clip( (R - 0.85) / 0.13 , 0, 1 )
smoothstep(x) = 3x^2 - 2x^3
A = max( 0.05, smoothstep(x) × c_f )
```

`c_f` is the weakest-class factor:

```
c = weakest class accuracy / baseline accuracy for that class
c_f = smoothstep( clip( (c - 0.50) / 0.25 , 0, 1 ) )
```

- `R ≥ 0.98` gives `A = 1` before a class penalty. That is macro-accuracy of about `85.5%`.
- `R ≤ 0.85` reaches the floor `A = 0.05`. The factor is never exactly 0 from the retention curve alone.
- A class with at least 20 questions and retention under 75% of its own baseline applies `c_f`. The class factor is 1 at 75% retention and 0 at 50% retention.
- Beating the reference macro-accuracy does not add points.

One briefing ambiguity remains: the accuracy floor is 0.05, while the class factor is described as reaching 0 at 50% class retention. Confirm how those two combine, and how classes with fewer than 20 questions are treated, if a run is close to either edge.

## 6. Throughput score (`s_T`)

```
s_T = peak-phase requests that passed SLO / peak-phase requests that arrived
```

- Only the constant 4 requests/second peak phase counts.
- Late, failed, and cut-off requests count as not served.
- `s_T` saturates at 1 when every peak request passes SLO.
- The exponent is 0.2, so a mediocre peak pass rate moves `S` less than the same misses move `s_E`. Those misses are also missing from `η`.

## 7. Latency score (`s_L`)

```
s_L,TTFT = min( 1, 1 / p95(TTFT / TTFT_SLO) )
s_L,TPOT = min( 1, 50 ms / p95(TPOT) )
s_L = sqrt( s_L,TTFT × s_L,TPOT )
```

- TTFT is divided by each request's own TTFT SLO before the percentile.
- TPOT target is 50 ms.
- `s_L` saturates at 1 once both tails are inside target. Further speed still helps energy and SLO-met count.

## 8. How to read a score

```
S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2
```

1. Energy carries exponent 0.6. Rescuing a failed request raises `η` and can raise `s_T` or `s_L`.
2. Accuracy multiplies the whole score. Full credit starts at 98% retention.
3. Throughput and latency saturate at 1.
4. Idle joules count, so a shorter busy window matters, not a lower watt reading by itself.
5. A power cap that pushes TPOT over 50 ms shrinks the numerator of `η`. Cap power only after SLO-met is already high.

## 9. Measured starting point

Indicative Validation of the defaults in `scripts/start-vllm.sh` (AWQ W4A16 checkpoint, speculative decoding off, `max_model_len` 32768, GPU memory utilization 0.85):

| Field | Value |
|---|---|
| `S` | 34.8 |
| SLO-met | 56/100 |
| `A`, `s_E`, `s_T`, `s_L`, joules, p95 TTFT, p95 TPOT | Not yet copied from grader History |

If `A`, `s_T`, and `s_L` were all 1, then `s_E ≈ 0.17` and efficiency would be only about `1.2×` baseline. If accuracy or latency is worse than that, energy is better than `1.2×` and the score is being spent on those factors. Copy the History row before the next flag change. The ledger is `experiments/log.md`.

## 10. Still unresolved

- How the 0.05 accuracy floor combines with a class factor of 0.
- How classes with fewer than 20 questions affect `c_f`.
- Whether a future Final page replaces `0.00154` / `87.2%` with another header.

The image digest of `vllm/vllm-openai:nightly` for the 34.8 run was not recorded. Record it on the VM before comparing later runs.

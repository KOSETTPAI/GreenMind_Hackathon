# run5 / run6: why Validation reached 95.6 and the Final only 19.1

All three runs used the same image (`sha256:cb12c301…`, vLLM 0.32.1rc1.dev361) and no power cap. The run6 Validation and the run6 Final ran back to back on the same container, with no relaunch.

| Run | Track | S | SLO-met | A | sE | sT | sL | η vs base | J/req | p95 TTFT | p95 TPOT |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| run5 (V1) | Validation | 35.6 | 57/100 | 1.00 | 0.31 | 0.38 | 0.50 | 1.41× | 264 | 2.47 s | 55 ms |
| run6 (V2) | Validation | **95.6** | 98/100 | 1.00 | 0.93 | 0.98 | 1.00 | 2.78× | 229 | 0.16 s | 18 ms |
| run6 | **Final** | **19.1** | 127/300 | 1.00 | 0.15 | 0.16 | 0.50 | 1.18× | 221 | 2.16 s | **82 ms** |

The telemetry in this table and the next one was parsed from the `watch.sh` samples pasted into `run5/log.md`, `run6/log.md` and `run6/final-test.md`. The energy column was empty, so joules come from the grader.

| Run | Busy window | Peak running | Mean running | Peak waiting | Peak KV use | Preemptions | Prefix-cache hits | Mean power while busy |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| run5 Validation | ~154 s | 66 | 11.3 | 10 | 30% | 0 | 15% | ~286 W |
| run6 Validation | ~200 s of load | **35** | 2.5 | 0 | 16% | 0 | **87%** | ~270 W |
| run6 Final | ~271 s | **111** | 25.4 | 7 | 55% | 0 | **44%** | ~303 W |

## 1. Accuracy and energy per request are not the problem

On the Final, `A = 1.00` with R 0.975. Joules per request barely moved: 221 on the Final, 229 on the Validation. What collapsed was the number of requests that met every SLO: 127 of 300. That count is the numerator of η.

- Final η = 127 / (221 × 300 J) ≈ 0.00192 SLO-met/J. That is 1.18× the Final baseline of 0.00163, so sE = 0.15.
- The same joules with 270 of 300 SLO-met would be about 2.5× the Final baseline, sE ≈ 0.83, and S somewhere around 80. This is a derived estimate, not a measurement.

## 2. The Final failed on TPOT at a much higher concurrency

- `sT = 0.16`: only 16% of peak-phase requests met their SLO.
- `sL = 0.50`. Splitting it: `s_TPOT = 50 / 82 = 0.61`, so `s_TTFT ≈ 0.25 / 0.61 = 0.41`, which puts the p95 of TTFT ÷ its SLO near 2.4×. TPOT and TTFT both fail, but TPOT is new. On the Validation, p95 TPOT was 18 ms.
- **Peak running requests were 111 on the Final against 35 on the Validation.** The Final's 4 requests/s peak lasts long enough for decode batches to reach about three times the Validation's size.
- End-to-end latency on the visible Final lines rises from about 5 s on requests 1–50 to 20–26 s on requests 101–300. On the Validation it stayed at 4–7 s.

This is a feedback loop. A bigger batch makes each decode step slower. Slower steps keep each request alive longer. By Little's law (concurrency = arrival rate × time in system), longer-lived requests at a fixed 4 req/s mean more requests running at once. Above roughly 70 running, p95 TPOT crosses 50 ms. That figure is a linear interpolation between 18 ms at 35 running and 82 ms at 111 running; it was not measured directly. Past that point nearly every peak request fails the TPOT check, even though its answer is correct.

Two smaller causes:

- The Final's prefix-cache hit rate was 44%, against 87% on the Validation. More real prefill is mixed into decode steps, which slows them further.
- The Final ends with long-running requests (124.8 s and 87.9 s on the last two lines). They keep the energy window open after the peak.

**Validation no longer separates good configurations from bad ones.** At 98/100 and sL = 1.00 it is saturated, and it never reaches Final-like concurrency. Compare candidates with Final submissions, or with the Final-shaped replay in `lib/replay.py`.

## 3. Correction: run6 did not turn prefix caching off

run6 removed `--enable-prefix-caching --mamba-cache-mode align`. Its telemetry still shows `prefix_cache_hits_total` rising: 327,888 hits on the Validation and 325,248 on the Final. On this image prefix caching is on by default. run6 differs from run5 only in how prefix caching is configured, not in whether it is on.

The default configuration hit far more often (87% on the Validation) than run5's explicit flags (15%). It also beat run4 full, where MTP and explicit caching together hit about 1%. That gap, which cut prefill work, is the most likely reason run6's Validation jumped from 35.6 to 95.6. Why the defaults hit more is not proven. A likely cause is finer-grained hashing that the explicit `align` path does not use; run6's startup log on the VM would show the effective settings.

So every later profile built on run6 (run7 to run14) also has prefix caching on. Their READMEs describe the parent as "caching off". The single change each one makes is still correct.

## 4. What to change next

The server has to keep p95 TPOT under 50 ms while about 110 requests arrive faster than they finish. Ranked by expected effect and risk:

1. **Cap the decode batch: `--max-num-seqs 64`** (run16). Batches stop growing into the zone where TPOT exceeds 50 ms. Requests beyond the cap wait for a slot. Some of them will miss TTFT, but uncapped, almost all peak requests already miss TPOT. At 64 running, TPOT should be around 40 ms by the interpolation above. Decode throughput (batch ÷ TPOT) stays about the same, 64 / 0.04 ≈ 110 / 0.082 ≈ 1,350 tokens/s, so the cap mostly redistributes failures from "everyone slow" to "a few late starters".
2. **Tighter cap: `--max-num-seqs 32`** ([run18-val2](../run18-val2/README.md)). 32 sits under the Validation peak of 35, so queueing can show up even on Validation. Use it if 64 still leaves p95 TPOT over 50 ms.
3. **Looser cap: `--max-num-seqs 96`** ([run22-val5](../run22-val5/README.md)). Use it if 64 queues too much, with TTFT ÷ SLO getting worse while TPOT has room.
4. **Cap plus long-prefill threshold** ([run19-val3](../run19-val3/README.md)): 64 plus `--long-prefill-token-threshold 2048`. While waiting requests are admitted, a long prompt's prefill no longer takes over a whole step, which helps both the TTFT of short prompts and the TPOT spikes.
5. **MTP k=1 on top of the cap** ([run25-val7](../run25-val7/README.md)), conditional and later. On run4 full, MTP accepted 91.5% of drafts, about 1.9 tokens per step, which would cut TPOT at a fixed batch. But run4 combined MTP with prefix caching and hit only about 1%. Prefix caching is now the biggest single win, so this is worth a slot only if the replay or a Final keeps the hit rate near run6's level.

The submission order is [CYCLE_PLAN.md](../CYCLE_PLAN.md). Keep the power cap ([run26-val8](../run26-val8/README.md)) waiting. At 127/300 SLO-met, a lower cap would only raise TPOT.

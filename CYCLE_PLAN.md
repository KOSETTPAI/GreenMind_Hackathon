# Final plan

Goal: the highest Final `S`, scored against the Final baseline (η_base 0.00163, reference macro-accuracy 87.8%). Only Finals count. The user's target is above 80. Five Finals remain: `final-run3` to `final-run7`.

## Finals so far

| Grader Final | Server | S | SLO-met | p95 TTFT | p95 TPOT | J/request | Prefix hits |
|---|---|---|---|---|---|---|---|
| #1 | run4 full (MTP, explicit caching) | 0.0 | 93/300 | 3.59 s | 91 ms | 208 | ~1% |
| #2 | "run6", actually **run5's container**, after two Validations | **19.1** | **127/300** | 2.16 s | 82 ms | 221 | 44% (warm) |
| #3 | final-run1: cap 64 | 0.0 | 87/300 | 6.54 s | 67 ms | 190 | 8–17% |
| #4 | final-run2: cap 64 + MTP k=1 | 0.0 | 81/300 | 7.82 s | 63 ms | 208 | **1.07%** |

## What the logs show (read from the VM, 2026-10-24 21:00)

1. **run6 was never launched.** `./run6/flag-check.sh && REPLACE=1 ./run6/start.sh` failed at flag-check, so `&&` stopped. The run5 container (started 11:21 UTC) served run5's Validation (11:27), the "run6" Validation (11:46) and the "run6" Final (11:54). There is no run6 record under `~/greenmind-runs/`, and run17-val1's `previous-inspect.json` names run5.
2. **The Validation's 100 requests are the first 100 of the Final.** The 10-second "Avg prompt throughput" sequence at the start of a Final repeats the Validation's: cold, 597/3227/4079/1326/3844 (run5 Validation) against 600/3245/4058/1330/3846 (final-run1 Final); warm, 289.6/212.6/276.8/302.0/210.0/252.8 for both the "run6" Validation and the "run6" Final. The 95.6 Validation was a second pass over prompts already in the prefix cache. The 127/300 Final was cheap for its first third for the same reason.
3. **The cap moved the failure from TPOT to TTFT.** At cap 64, requests waited 2.06 s on average in the queue (`request_queue_time_seconds` 1,374 s over 666 calls). p95 TPOT only fell from 82 ms to 63–67 ms.
4. **MTP disables prefix caching here.** final-run2 hit 7,920 of 740,937 prompt tokens (1.07%), the same ~1% as run4 full. MTP also cost more energy (208 against 190 J/request).
5. **The peak is a throughput problem.** With 64 running at the final-run1 peak, the engine prefilled 5–8k prompt tokens/s and generated only 620–1,660 tokens/s, which is 38–100 ms per token. Pure decode steps ran at 9–12 ms per token with 8–15 running. Mixed prefill-plus-decode steps are what make TPOT slow.

## What S above 80 requires

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`, with `A ≈ 1` (accuracy has held at 85.6–88.4%). Roughly **240/300 SLO-met at ≤ ~210 J per request** gives `S ≈ 80–86`. 230/300 gives about 78. The best so far is 127/300. Even 300/300 at the run6 energy (~66 kJ) only reaches `S ≈ 96`. 99.9 needs every request in SLO and about 205 J per SLO-met request.

No configuration tested so far is close. The remaining lever with evidence behind it is throughput at the peak, not caps, MTP, or power.

## The five remaining Finals

All on the same base: prefix caching on by default, MTP off, no `--max-num-seqs` cap, 400 W unless stated.

| Order | Folder | Change from the base | Launch rule |
|---|---|---|---|
| 1 | [final-run3](final-run3/README.md) | `--max-num-batched-tokens 8192` | Next |
| 2 | [final-run4](final-run4/README.md) | budget 8192 + `--performance-mode throughput` | Only if final-run3 SLO-met > 127. Otherwise launch `./run6/start.sh` (the plain base) |
| 3 | [final-run5](final-run5/README.md) | the better of final-run3 and final-run4 | 250 W only if its p95 TPOT was ≤ 40 ms |
| 4 | [final-run6](final-run6/README.md) | repeat the best | Copy the best profile and power line |
| 5 | [final-run7](final-run7/README.md) | repeat the best | Must finish before 25 Oct 2026 11:00 |

Why a budget of 8192: the A100 default of 2048 spreads prefill across many slow mixed steps. 8192 clears pending prefill in fewer steps, leaving more fast decode-only steps, which lowers average TPOT. It also starts queued prompts sooner, which lowers TTFT. The SLO checks each request's average TPOT, so a few longer steps cost less than many slow ones.

## Validation on the same container

The best Final so far came after a Validation on the same container, and that Validation put the Final's first 100 prompts in the prefix cache. Before doing that on purpose, ask the organizers whether it is allowed. Without that confirmation, launch fresh and submit the Final directly. A Validation on a different container (or before a relaunch) is only a works-check.

## Every Final

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main     # only between runs
./final-run3/flag-check.sh && REPLACE=1 ./final-run3/start.sh
python3 lib/warmup.py
./lib/watch.sh                                                    # second terminal, just before Submit
# Submit the Final. When it finishes, Ctrl-C watch.sh, then:
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

Read the result against the run6 Final: SLO-met (127), p95 TTFT (2.16 s), p95 TPOT (82 ms). Paste the History row and `docker logs mango-vllm | grep "Avg prompt throughput"` into the folder's `log.md`.

## Rules

- `BIND` stays `0.0.0.0`. One serving process.
- Never relaunch, warm up, replay, or change power while a Validation or Final is running.
- Name the track next to every η, `s_E`, or retention.

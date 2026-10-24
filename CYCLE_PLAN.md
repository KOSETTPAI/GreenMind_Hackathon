# Cycle plan

Goal: **Final `S` = 99.9**, scored against the Final baseline (η_base 0.00163, reference macro-accuracy 87.8%). Validation is a works-check. It does not rank configurations and it does not count. Four hours remain, one cycle per hour. Cycle 1 has finished steps 1–3.

Only the Final counts. Name the track next to every η, `s_E`, or retention.

## Where this hour stands

| Step | What | Status |
|---|---|---|
| 1 | Two Validations | Done. run5 scored 35.6, run6 scored 95.6 |
| 2 | Analyze | Done. [run6/ANALYSIS.md](run6/ANALYSIS.md) |
| 3 | One Final | Done. run6 scored **19.1** (127/300, p95 TPOT 82 ms, 111 running) |
| 4 | Analyze | Done. The Final fails because the decode batch grows past ~70 running and p95 TPOT crosses 50 ms |
| 5 | Three Validations | **Next.** `run17-val1`, `run18-val2`, `run19-val3` |
| 6 | Analyze | Replay all three with `--track final` and the same seed. Rank by SLO-met, then p95 TPOT, then joules |
| 7 | One Final | `run20-final1`, the replay winner |

## What 99.9 actually requires

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. With `A = s_T = s_L = 1`, `S = 99.9` needs `s_E ≈ 0.9983`, which is `η ≈ 2.995 × 0.00163 ≈ 0.00488`: about **205 J per SLO-met request**, and essentially every one of the 300 requests inside both SLOs. That is at most about **61.5 kJ** over the graded window.

The run6 Final reported 221 J per request. Held constant across 300 requests that is about 66 kJ. Even 300/300 SLO-met inside that budget is only ~2.78× the Final baseline, `s_E ≈ 0.93`, `S ≈ 96`. Rescuing SLO-met gets the score into the mid-90s. The last points need that rescue **and** a few percent fewer joules, which is the power cap, and only after p95 TPOT is under 50 ms with room to spare. A power cap while TPOT is already over 50 ms lowers SLO-met and the score falls.

## Rules for every launch

- One change from the parent. The parent of everything below is run6: prefix caching left at the image default, which is on. Do not add `--enable-prefix-caching` or `--mamba-cache-mode`.
- `BIND` stays `0.0.0.0`. One serving process. No power change during a graded window.
- A Validation answers "does this server still work". The Final, or `python3 lib/replay.py --track final`, answers "does the cap hold TPOT".
- Replay only while the GPU is idle. It aborts if requests are running.
- Copy the History row into the run's `log.md` before launching the next one.

## Cycle 1, remaining

| Order | Folder | Single change from run6 | Submit when |
|---|---|---|---|
| 1 | [run17-val1](run17-val1/README.md) | `--max-num-seqs 64` | Now. Same server as run16; submit this folder |
| 2 | [run18-val2](run18-val2/README.md) | `--max-num-seqs 32` | After val1's row is copied. 32 is below the Validation peak of 35, so queueing can show up here |
| 3 | [run19-val3](run19-val3/README.md) | cap 64 + `--long-prefill-token-threshold 2048` | After val2 |
| 4 | [run20-final1](run20-final1/README.md) | the replay winner; default is cap 64 | After the replay. `CONFIRM_FINAL1=1` |

```bash
./run17-val1/flag-check.sh && REPLACE=1 ./run17-val1/start.sh && python3 lib/warmup.py
# Submit the Validation. When it finishes and the GPU is idle:
python3 lib/replay.py --label val1 --track final
```

Repeat the launch, warmup, Validation, and replay for `run18-val2` (`--label val2`) and `run19-val3` (`--label val3`). Then:

```bash
# if the winner was not val1, copy its profile.args over run20-final1/profile.args first
CONFIRM_FINAL1=1 REPLACE=1 ./run20-final1/start.sh && python3 lib/warmup.py
```

## Cycle 2, after final1

Launch only the branch the final1 row points at. Each of these refuses to start without its `CONFIRM_` variable.

| Folder | Launch only if | Single change |
|---|---|---|
| [run21-val4](run21-val4/README.md) | final1 p95 TPOT still above 50 ms | `--max-num-seqs 24` |
| [run22-val5](run22-val5/README.md) | final1 met TPOT but SLO-met fell because requests queued past TTFT | `--max-num-seqs 96` |
| [run23-final2](run23-final2/README.md) | the cycle-2 replay picked a winner | that winner; default cap 64 |
| [run26-val8](run26-val8/README.md) | final1 (or final2) SLO-met is high and p95 TPOT is under 50 ms with room | power cap 250 W, then 200 W. No relaunch |
| [run24-val6](run24-val6/README.md) | TPOT is under 50 ms and the remaining misses are TTFT | cap kept, `--max-num-batched-tokens 8192` |
| [run25-val7](run25-val7/README.md) | SLO-met is high and joules are the remaining gap | cap kept, MTP k=1. Drop it if prefix hits collapse |
| [run27-final3](run27-final3/README.md) | the best of those is known | that profile, or the same server left at the best power cap |

Order inside the hour: the two cap branches that final1 justifies (val4, val5), then final2, then the three energy and TTFT checks (val8, val6, val7), then final3. Skip a folder when its condition is not met and spend the slot on the next one that is.

## Cycle 3

| Folder | Launch only if | Single change |
|---|---|---|
| [run28-val9](run28-val9/README.md) | the 8192 budget improved TTFT and TPOT still has room | `--max-num-batched-tokens 16384`, cap kept |
| [run29-val10](run29-val10/README.md) | MTP k=1 raised the Final score and tool calls stayed clean | `num_speculative_tokens` 2 |
| [run30-final4](run30-final4/README.md) | the cycle-3 winner is known | that profile |

Power steps 200 W and 175 W reuse `run26-val8/power.sh`. One Validation each, and only if the previous wattage held SLO-met and improved efficiency. Restore between runs, never during one.

## Cycle 4

No new profile. Relaunch the best folder exactly as it was, change nothing, and use the two Finals to repeat it. Use the Validations only to confirm the server is up. The last Final must finish before 25 Oct 2026 11:00 Bangkok.

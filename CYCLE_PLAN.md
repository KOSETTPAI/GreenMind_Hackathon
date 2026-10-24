# Final plan

Goal: **Final `S` = 99.9**, scored against the Final baseline (η_base 0.00163, reference macro-accuracy 87.8%). Only Finals count. Seven Finals remain: `final-run1` to `final-run7`, two per hour, plus one this hour.

| Grader Final | Server | S | SLO-met |
|---|---|---|---|
| #1 | run4 full | 0.0 | 93/300 |
| #2 | run6 | 19.1 | 127/300 |
| #3 | **final-run1** (next) | | |

Every `final-runN` folder runs on its own: no launch guard, no replay, no dependency on an earlier result. Its `start.sh` sets the vLLM arguments and the GPU power limit, and puts the power back to the card default when the run has none.

## The seven Finals

All are run6 plus the lines shown. Prefix caching stays at the image default (on). Do not add `--enable-prefix-caching` or `--mamba-cache-mode`.

| Order | Folder | vLLM lines added to run6 | Power | What it fixes |
|---|---|---|---|---|
| 1 | [final-run1](final-run1/README.md) | `--max-num-seqs 64` | default | TPOT: keeps the decode batch under ~70 running |
| 2 | [final-run2](final-run2/README.md) | cap 64, MTP k=1 | default | Throughput: the peak queue that a cap alone leaves |
| 3 | [final-run3](final-run3/README.md) | cap 96, MTP k=1 | default | TTFT: fewer requests queue past their limit |
| 4 | [final-run4](final-run4/README.md) | cap 96, MTP k=1 | 250 W | Energy |
| 5 | [final-run5](final-run5/README.md) | cap 96, MTP k=1 | 225 W | More energy |
| 6 | [final-run6](final-run6/README.md) | cap 96, MTP k=2 | 250 W | Fewer steps per answer |
| 7 | [final-run7](final-run7/README.md) | cap 96, MTP k=1, or the best earlier Final | 250 W | Repeat the best server |

When: final-run1 closes this hour. final-run2 and final-run3 in hour 2, final-run4 and final-run5 in hour 3, final-run6 and final-run7 in hour 4. The last Final must finish before 25 Oct 2026 11:00 Bangkok.

## Why this order reaches for 99.9

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. With `A = s_T = s_L = 1`, 99.9 needs `s_E ≈ 0.9983`, so `η ≈ 2.995 × 0.00163 ≈ 0.00488`: about **205 J per SLO-met request** and essentially all 300 requests inside both SLOs. That is at most about **61.5 kJ** for the graded window.

The run6 Final reported 221 J per request. Even 300/300 SLO-met at that energy is only ~2.78× the Final baseline, `S ≈ 96`. So:

1. **TPOT first.** run6 reached 111 running and p95 TPOT of 82 ms. From the run6 Validation (35 running, 18 ms), p95 TPOT crosses 50 ms near 70 running.
2. **Throughput.** At 4 req/s a capped server finishes fewer requests per second than arrive, so a queue forms and queued requests miss TTFT. MTP k=1 (91.5% draft acceptance on run4 full) finishes requests faster, lowers TPOT, and uses fewer joules per token. With MTP the cap can loosen to 96.
3. **Energy last.** A power limit trims the last few percent of joules. It only helps once TPOT has headroom.

`--long-prefill-token-threshold 2048` is not used. This image already caps each scheduler step at 2048 tokens, so that threshold changes nothing.

## Validation slots

Validations do not count and do not rank servers. Use at most one per Final, as a works-check of the server you are about to submit: launch `final-runN`, submit a Validation, then submit the Final on the **same container** without relaunching. The other Validation slots in the hour can stay unused.

Two optional glances at that works-check:

- **final-run2** (first MTP server): compare the prefix hit rate in `summarize.py` with run6's 87% on Validation. If it is below about 50%, or accuracy is under 86%, MTP is hurting caching. Submit final-run1's profile again instead, and use it for final-run3 too.
- **Power-limited runs** (final-run4 onward): if p95 TPOT on the Validation is already above about 35 ms, that wattage will not hold at the Final peak. Use the previous Final's server instead.

## Every Final

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main     # only between runs
./final-run1/flag-check.sh && REPLACE=1 ./final-run1/start.sh
python3 lib/warmup.py
./lib/watch.sh                                                    # second terminal, just before Submit
# optional: Submit Validation, wait, record. Then Submit Final on the same container.
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final
```

`start.sh` may ask for the sudo password when it changes the power limit. Copy the History rows into the folder's `log.md`.

## Rules

- `BIND` stays `0.0.0.0`. One serving process.
- Never relaunch, replay, warm up, or change power while a Validation or Final is running.
- Name the track next to every η, `s_E`, or retention.
- `lib/replay.py --track final` is still available for a Final-shaped load test while the GPU is idle. Nothing depends on it.

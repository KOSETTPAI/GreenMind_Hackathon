# Cycle plan

Goal: **Final `S` = 99.9**, scored against the Final baseline (η_base 0.00163, reference macro-accuracy 87.8%). Validation is a works-check. It does not rank configurations and it does not count. Four hours remain, one cycle per hour: 2 Validations, analyze, 1 Final, analyze, 3 Validations, analyze, 1 Final.

**Every folder runs on its own.** No launch guard, no replay, no dependency on an earlier result. `start.sh` sets the vLLM arguments and the GPU power limit for that run, and puts the power back to the card default when the run has none. Submit the folders in the order below. If a Final scores higher than a later one, you may copy its `profile.args` and its `GREENMIND_POWER_W` line into `run41-final7`. Otherwise run everything as written.

## What 99.9 requires

`S = 100 · A · s_E^0.6 · s_T^0.2 · s_L^0.2`. With `A = s_T = s_L = 1`, 99.9 needs `s_E ≈ 0.9983`, so `η ≈ 2.995 × 0.00163 ≈ 0.00488`: about **205 J per SLO-met request** and essentially all 300 requests inside both SLOs. That is at most about **61.5 kJ** for the graded window.

The run6 Final reported 221 J per request. Even 300/300 SLO-met at that energy is only ~2.78× the Final baseline, `S ≈ 96`. So the Finals go in three stages:

1. **TPOT.** Cap the running requests (`--max-num-seqs`). run6 reached 111 running and p95 TPOT of 82 ms. From the run6 Validation (35 running, 18 ms), p95 TPOT crosses 50 ms near 70 running.
2. **Throughput.** A cap alone leaves a queue at the 4 req/s peak, and queued requests miss TTFT. MTP k=1 (91.5% draft acceptance on run4 full) produces more tokens per step, which finishes requests faster, lowers TPOT, and uses fewer joules per token. With MTP the cap can loosen to 96.
3. **Energy.** A power limit trims the last few percent of joules. Only useful once TPOT has headroom, which is why it comes after stages 1 and 2.

`--long-prefill-token-threshold 2048` is dropped. This image already caps each scheduler step at 2048 tokens, so that threshold changes nothing.

## Profiles

All of them are run6 plus the lines shown. Prefix caching stays at the image default (on). Do not add `--enable-prefix-caching` or `--mamba-cache-mode`.

| Key | vLLM lines added to run6 | Power |
|---|---|---|
| P1 | `--max-num-seqs 64` | default |
| P2 | `--max-num-seqs 64`, MTP k=1 | default |
| P3 | `--max-num-seqs 96`, MTP k=1 | default |
| P4 | `--max-num-seqs 96`, MTP k=1 | 250 W |
| P5 | `--max-num-seqs 96`, MTP k=1 | 225 W |
| P6 | `--max-num-seqs 96`, MTP k=2 | 250 W |
| P7 | `--max-num-seqs 128`, MTP k=1 | default |
| P8 | `--max-num-seqs 64`, MTP k=1 | 250 W |
| P9 | `--max-num-seqs 96`, MTP k=1 | 200 W |

## Order

Cycle 1 has used its first two Validations (run5 35.6, run6 95.6) and its first Final (run6 19.1).

| Cycle | Folder | Profile | Purpose |
|---|---|---|---|
| 1 | [run17-val1](run17-val1/README.md) | P1 | Works-check for final1 |
| 1 | [run18-val2](run18-val2/README.md) | P2 | Works-check for final2. Check the prefix hit rate and accuracy |
| 1 | [run19-val3](run19-val3/README.md) | P3 | Works-check for final3 |
| 1 | [run20-final1](run20-final1/README.md) | **P1** | **Final** |
| 2 | [run21-val4](run21-val4/README.md) | P4 | Works-check for final4: TPOT headroom at 250 W |
| 2 | [run22-val5](run22-val5/README.md) | P8 | Power without loosening the cap |
| 2 | [run23-final2](run23-final2/README.md) | **P2** | **Final** |
| 2 | [run24-val6](run24-val6/README.md) | P5 | Works-check for final5 |
| 2 | [run25-val7](run25-val7/README.md) | P6 | Works-check for final6 |
| 2 | [run26-val8](run26-val8/README.md) | P7 | Looser cap |
| 2 | [run27-final3](run27-final3/README.md) | **P3** | **Final** |
| 3 | [run28-val9](run28-val9/README.md) | P4 | Works-check for final4 |
| 3 | [run29-val10](run29-val10/README.md) | P9 | 200 W |
| 3 | [run30-final4](run30-final4/README.md) | **P4** | **Final** |
| 3 | [run31-val11](run31-val11/README.md) | P5 | Works-check for final5 |
| 3 | [run32-val12](run32-val12/README.md) | P6 | Works-check for final6 |
| 3 | [run33-val13](run33-val13/README.md) | P7 | Looser cap |
| 3 | [run34-final5](run34-final5/README.md) | **P5** | **Final** |
| 4 | [run35-val14](run35-val14/README.md) | P6 | Works-check for final6 |
| 4 | [run36-val15](run36-val15/README.md) | P4 | Works-check for final7 |
| 4 | [run37-final6](run37-final6/README.md) | **P6** | **Final** |
| 4 | [run38-val16](run38-val16/README.md) | P4 | Works-check for final7 |
| 4 | [run39-val17](run39-val17/README.md) | P5 | 225 W |
| 4 | [run40-val18](run40-val18/README.md) | P4 | Last check before final7 |
| 4 | [run41-final7](run41-final7/README.md) | **P4** | **Final**. Or copy the best earlier Final here |

The last Final must finish before 25 Oct 2026 11:00 Bangkok.

## Every run

```bash
cd ~/GreenMind_Hackathon && git pull --no-rebase origin main     # only between runs
./runNN-xxx/flag-check.sh && REPLACE=1 ./runNN-xxx/start.sh
python3 lib/warmup.py
./lib/watch.sh                                                    # second terminal, just before Submit
# Submit on the grader, wait for it to finish, Ctrl-C watch.sh
python3 lib/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met <N> --track final|validation
```

`start.sh` may ask for the sudo password when it changes the power limit. Copy the History row into the folder's `log.md`.

## Two checks worth one glance

These are optional and do not block anything.

- After **val2** (the first MTP server), compare the prefix hit rate in `summarize.py` with run6's 87% on Validation. If it falls below about 50%, or accuracy falls under 86%, MTP is hurting caching. In that case, run final2 and final3 with the final1 profile.
- After any power-limited Validation, if p95 TPOT is already above about 35 ms, the Final at that wattage will not have room. Use the previous wattage instead.

`lib/replay.py --track final` is still available for a Final-shaped load test while the GPU is idle. Nothing depends on it.

## Rules

- `BIND` stays `0.0.0.0`. One serving process.
- Never relaunch, replay, warm up, or change power while a Validation or Final is running.
- Name the track next to every η, `s_E`, or retention.

# Approach configs

One launch config for every approach in [approach/](../../approach/README.md) that is worth testing. **Untested.** Each config is checked with `preflight.sh` on the VM before use.

## How the stack works

[`_stack.conf`](_stack.conf) holds **the current winner of every approach** and starts as the team's deployment (`scripts/start-vllm.sh`). Each `Axx_*.conf` sources it, changes **one** thing, and calls `compose_extra_args`. When a run wins, copy its value into `_stack.conf`. Every later config then tests on top of it, and the next reference is simply `A00_stack.conf`.

```bash
S=experiments_thyme/scripts
C=experiments_thyme/configs/A02_power_200w.conf
$S/preflight.sh $C            # flags exist in this vLLM image
$S/apply-gpu-settings.sh $C   # power cap / clock lock (or reset to defaults); sudo
$S/launch.sh $C               # refuses if the power limit doesn't match the config
python3 $S/smoke_grader_shape.py
# Validation run in the grader UI (+ telemetry.sh), then:
$S/stop.sh
```

Run `apply-gpu-settings.sh` for **every** config, not only A02/A11. For the others it resets the GPU to defaults, so a cap left over from an earlier run can't skew the next one.

## Map

| Approach | Verdict in approach/ | Config(s) | Changes vs stack |
|---|---|---|---|
| 1 Baseline | Must, first | `A01_baseline_bf16` (standalone), `A00_stack` ×2 | BF16 with vLLM defaults; stack twice for noise floor |
| 2 Power cap | Yes | `A02_power_{250,200,175,150}w` | `POWER_LIMIT_W` |
| 3 Quantization | Yes | `A03a_bf16_same_flags`, `A03b_fp8_online` | BF16 weights with the same flags; BF16 + `--quantization fp8` (W8A16) |
| 4 MTP | Yes | `A04_mtp_k{1,2,3}` | `--speculative-config` mtp, k draft tokens |
| 5 Batch size | Yes | `A05_max_seqs_{64,128,192,256}` | `--max-num-seqs` |
| 6 Batched tokens | Yes | `A06_batched_tokens_{2048,4096,8192}` | `--enable-chunked-prefill --max-num-batched-tokens` |
| 7 Prefix caching | Yes | `A07_prefix_cache_align` | `--enable-prefix-caching --mamba-cache-mode align` |
| 8 Memory / length | Yes | `A08a_max_len_40960`, `A08{b,c,d}_mem_{090,092,095}` | `MAX_MODEL_LEN`, then `GPU_MEMORY_UTILIZATION` |
| 9 Mamba state BF16 | If time | `A09_mamba_state_bf16` | `--mamba-ssm-cache-dtype bfloat16` |
| 10 CUDA graphs + warm-up | Yes (check) | none needed | No launch config ever passes `--enforce-eager`. Warm up by running `smoke_grader_shape.py` before submitting |
| 11 Clock lock | Maybe | `A11_clock_{1095,1215,1305}mhz` | `GPU_CLOCK_MHZ` (checked against supported clocks) |
| 12 API servers | Only if CPU-bound | `A12_api_servers_2` | `--api-server-count 2` |
| 13 FP8 KV cache | Probably not | `A13_kv_cache_fp8` | `--kv-cache-dtype fp8`; run last |

### Not given a config

| Approach | Why |
|---|---|
| 14 Scheduling policy | `--scheduling-policy priority` does nothing because grader requests carry no priority; a custom policy means patching vLLM. The approach file itself recommends no steps |
| 15 External draft model | Rejected: competes with MTP, its energy counts, needs a matching tokenizer |
| 16 Engine switch | Rejected for this event: needs a separate stack, not a vLLM config |
| 17 Pruning / fine-tuning / kernels | Rejected: too slow for 2 days |
| 18 Not allowed | Disqualification risk |

## Suggested order (from approach/README.md)

1. `A01` once, then `A00` ×2 (noise floor).
2. `A02` sweep → winner into `POWER_LIMIT_W`.
3. `A03a` vs `A00` (AWQ vs BF16) for per-class accuracy; `A03b` only if AWQ fails it.
4. `A04` k=1 → 2 → 3 → winner into `SPEC_ARGS`.
5. `A07` → `PREFIX_ARGS`.
6. `A08a` → `MAX_MODEL_LEN` (do this early if long-context requests error).
7. `A05`, then `A06`.
8. `A08b–d`, `A09`, then `A11`, `A12`, `A13` if time allows.
9. Re-run the `A02` sweep on the final stack: the best cap usually moves.

## Notes

- **Served model name stays `mango1.5-awq-w4a16` in every config**, BF16 ones included, so the grader's dropdown and the smoke test's `--model` never change between runs.
- **`A01` is not a true default `vllm serve`.** It adds the grader-required tool flags, which approach 1's command also uses, and `--trust-remote-code`, which doesn't change serving speed for natively supported models.
- **`A03a`/`A03b` clear `SPEC_ARGS`.** The BF16 repo may not include the MTP head.
- **Which base each sweep runs on matters.** A sweep run before its prerequisites are in `_stack.conf` measures a different base. `launch.sh` saves the config, a copy of `_stack.conf`, and the fully resolved `docker run` command in each run's folder, so every run records the exact base it was measured on.

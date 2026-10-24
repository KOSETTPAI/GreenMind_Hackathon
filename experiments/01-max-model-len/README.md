# E1 — context length 40960

Approach 8, and step 1 in `approach/README.md` after V0.

## Change

`scripts/start-vllm.sh` keeps `--max-model-len 32768`. This script is an isolated copy with `--max-model-len 40960`.

Everything else stays on the V0 command: AWQ checkpoint `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, served name `mango1.5-awq-w4a16`, GPU memory utilization `0.85`, tool parser `qwen3_coder`, reasoning parser `qwen3`, localhost port `8000`, MTP off, prefix caching off, no power cap.

```bash
docker rm -f mango-vllm
bash experiments/01-max-model-len/start.sh
```

`ADOPT_PREVIOUS` is rejected here. This is the first delta.

## Expected scoring impact

A prompt of 32768 tokens plus `max_tokens = 8192` is 40960 tokens. V0's 32768 context cannot hold both, so those requests fail or cut off. Failed and cut-off requests still add joules and add nothing to `η` or to peak `s_T`.

| Component | Expected direction | Condition |
|---|---|---|
| SLO-met | Up | Some of the 44 V0 misses are context errors or 8192-token cutoffs |
| `s_E` | Up | The extra SLO-met requests outrun any extra joules from a larger cache reservation |
| `s_T` | Up | The rescued requests sit in the 4 req/s peak |
| `s_L` | Down if cache pressure grows | p95 TPOT crossing 50 ms, or p95 normalized TTFT crossing 1, removes requests from SLO-met as well |
| `A` | Unchanged weights | Newly completed long answers still have to clear about 85.5% macro-accuracy for full `A` before the class factor |

The final mix has 15 long-context requests. Whether a class under 20 questions applies `c_f` is still unresolved in `scoring_criteria.md`. Keep 40960 even when the Validation pass count barely moves, and set `HELD_MAX_MODEL_LEN=40960`.

Revert when SLO-met or `S` falls. The hybrid stack has growing KV cache on about 8 of 32 layers, so the extra reservation is smaller than on a full transformer, and it is still real on a 40 GB GPU at utilization 0.85.

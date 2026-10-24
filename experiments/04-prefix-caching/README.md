# E4 — hybrid prefix caching

Approach 7. V0 leaves prefix caching off. For this hybrid model the documented change is the pair `--enable-prefix-caching` and `--mamba-cache-mode align`. The launcher treats that pair as one experiment.

## Change

```bash
ADOPT_PREVIOUS=1 bash experiments/04-prefix-caching/start.sh
bash experiments/04-prefix-caching/check-hits.sh
```

`check-hits.sh` reads the running container command, sends three requests that share a long prefix, and exits 0 only when a `prefix_cache_hits` counter increases.

## Expected scoring impact

Final traffic includes 60 RAG requests and 60 agentic tool-calling requests, with episodes up to 15 turns. Later turns resend the prefix. A hit skips prefill, which is the high-power phase, so joules and TTFT can both fall.

Validation is 100 requests and its class mix is not documented as the same 300-request mix. A Validation gain can be smaller than the Final gain. Still require a hit before spending the submission.

| Component | Expected direction | Condition |
|---|---|---|
| `s_E` | Up | The log shows real hits, so prefill joules fall |
| TTFT and SLO-met | Up | Later turns in a shared prefix finish inside `0.5 + 0.25 × prompt_tokens / 1000` |
| `s_T` | Up | Peak requests were TTFT failures on repeated prefixes |
| `A` | Flat | A state mismatch that changes answers is a revert |
| SLO-met | Down if the cache steals sequence slots | Re-tune memory or `max_num_seqs` only in a later experiment |

Submit only when the startup log says prefix caching stayed enabled and `check-hits.sh` exits 0. The probe disables thinking so the scripted transcript stays stable. The grader enables thinking, so the graded hit rate can differ. LMCache is not part of this experiment.

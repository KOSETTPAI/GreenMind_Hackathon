# experiments_thyme — later list

**This is not a second experiment system.** All runs go through the team's process:

- What to run, in order: [experiments/README.md](../experiments/README.md)
- Exact commands on the VM: [experiments/vm-sequence.md](../experiments/vm-sequence.md)
- Where results go: [experiments/log.md](../experiments/log.md)
- Where kept wins go: [experiments/adopted.env](../experiments/adopted.env)

This folder holds only two things: a checklist for sharing the one VM, and ideas to try **after** the team's sequence is finished, if time remains before Final closes (25 October, 11:00).

The earlier parallel scripts and configs were removed so the team has one set of records. They are still in Git history (commit `0a4df0b`) if ever needed.

---

## Before touching the VM

There is one GPU, one endpoint on port 8000, and one Validation quota (5 per hour), shared by the whole team.

1. **Ask in the team chat** whether anyone is running or about to submit. Say what you are going to run.
2. **Check that nothing is mid-run:**
   ```bash
   docker ps
   ```
   ```bash
   nvidia-smi
   ```
   A `mango-vllm` container under load (high GPU utilization) means someone may be testing. Don't remove it until they confirm.
3. **Check the power limit** before and after your run:
   ```bash
   bash experiments/07-power-cap/show-power.sh
   ```
   If you set a cap, restore it when you're done (see [experiments/07-power-cap/README.md](../experiments/07-power-cap/README.md)). A forgotten cap silently changes the next person's result.
4. **Write the result in `experiments/log.md`** right after the grader finishes, including failed runs.

---

## Later list

The team's README puts all of these on hold for later. The team launcher (`experiments/lib/launch-from-baseline.sh`) only accepts its own fixed set of flags, so **each one needs the team to agree first** and someone to add a step folder plus an allowed flag to that launcher. Don't run them by hand on the shared server.

| Idea | Approach | Change | Try only when | Main risk |
|---|---|---|---|---|
| Mamba state in BF16 | [9](../approach/9_Mamba_State_Cache_BF16.md) | `--mamba-ssm-cache-dtype bfloat16` | Prefix caching (team step 4) has a hit-rate result | Long-context and RAG accuracy can drop |
| Fixed clock lock | [11](../approach/11_Fixed_Clock_Lock.md) | Host-side: `sudo nvidia-smi -lgc 1095,1095` (reset with `sudo nvidia-smi -rgc`) | The team's power-cap sweep (step 6) is done; compare 2–3 clocks against the best cap | Long prompts slow down and miss TTFT. Must stay constant for the whole run |
| Two API server processes | [12](../approach/12_API_Server_and_CPU_Workers.md) | `--api-server-count 2` | During a run, one CPU core is at 100% while the GPU is idle and requests are queued. **Confirm with organizers** that this still counts as "one serving process" | Rule question; extra memory and CPU |
| FP8 KV cache | [13](../approach/13_FP8_KV_Cache.md) | `--kv-cache-dtype fp8` | Everything else is settled; last of all | Small gain (only ~8 of 32 layers use a KV cache), long-context accuracy risk |
| 8-bit weights instead of 4-bit | [3](../approach/3_Weight_Only_Quantization_With_Accuracy_Guardrail.md) fallback | BF16 checkpoint + `--quantization fp8` | Only if the AWQ model fails accuracy on some class (e.g. Thai), which the team hasn't seen | Changes the model, so it's not a one-flag experiment; the team launcher refuses non-AWQ models on purpose |

Always confirm a flag exists in the image before the run (the command is in [vm-sequence.md](../experiments/vm-sequence.md#flag-check)).

---

## Notes from the review of the team process

- **Scores so far:** V0 (`scripts/start-vllm.sh`) scored S = 34.8 with 56/100 requests on time. The 44 misses matter more than watts, which is why the team puts the power cap last.
- **The team's smoke tests run with thinking off** (`scripts/test-chat.sh`, `test-stream.sh`). The grader runs with thinking on. The team's `experiments/10-warmup/warmup.sh` turns thinking on, so run it before every Submit, as their checklist says.

# run11 — V7, MTP k=1 with caching off

**Conditional.** Parent is [run8](../run8/README.md): no MTP, prefix caching off, budget 8192. If the kept budget is 4096 or 16384, change only that line before launching.

**Single change:** `--speculative-config {"method":"mtp","num_speculative_tokens":1}`.

Prefix caching stays off. The run4 full server, which had MTP and caching together, scored below V0. A vLLM report (`vllm-project/vllm` issue 53912) describes corrupted output when MTP and prefix caching are combined on a Qwen3.5-class hybrid model. That is not proof it happened here. It is why this comparison turns caching off first. On run4 full, draft acceptance was 91.5%, so acceptance alone did not make the score go up. Compare SLO-met and `S`, and read the startup log for the `max_num_scheduled_tokens` warning.

**Run only after** a no-MTP configuration is the one you would otherwise keep. `start.sh` refuses without `CONFIRM_V7=1`.

```bash
CONFIRM_V7=1 ./run11/start.sh
```

If this wins and tool calls still parse, [run12](../run12/README.md) tries two draft tokens.

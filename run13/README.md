# run13 — V8, GPU memory utilization 0.92

**Conditional.** Parent is [run8](../run8/README.md). If a different no-MTP profile is the kept server, copy that profile and change only the memory line.

**Single change:** `--gpu-memory-utilization 0.92` instead of 0.90.

**Run only if** telemetry shows preemptions, or the KV cache filling, with free GPU memory left. The run4 full server had 0 preemptions and about 21.9 GiB of KV cache, so this is not the first lever. It does not fix queueing. An out-of-memory abort fails the round.

`start.sh` refuses without `CONFIRM_V8=1`.

```bash
CONFIRM_V8=1 ./run13/start.sh
```

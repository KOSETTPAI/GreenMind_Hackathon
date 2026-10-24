# Experiments

Run the next change from the VM, in the repository root:

```bash
docker rm -f mango-vllm
bash experiments/01-max-model-len/start.sh
```

`scripts/start-vllm.sh` is the scored V0 baseline. Leave that file as it is.

The run order, score expectations, and adopt/revert rules are in [README.md](README.md). The command list is [vm-sequence.md](vm-sequence.md). Record every Validation in [log.md](log.md).

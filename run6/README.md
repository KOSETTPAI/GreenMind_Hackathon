# run6 — V2, prefix caching off

**Parent:** [run5](../run5/README.md). MTP is already off.

**Single change:** `--enable-prefix-caching` and `--mamba-cache-mode align` are removed. On this image, omitting them leaves prefix caching off. `align` is what forced the 528-token attention block.

**Question:** does hybrid prefix caching pay for itself? On the run4 full server the hit rate was 1.0% of prompt tokens (11,616 of 1,115,335).

**Keep if:** SLO-met, `S`, or efficiency improves, or the hit rate on run5 was about zero. If run5 was clearly better, keep run5 and add its two cache lines back onto whichever later profile you launch. Do not also change the budget in the same launch.

```bash
./run6/flag-check.sh
REPLACE=1 ./run6/start.sh
```

Next default experiment is [run7](../run7/README.md).

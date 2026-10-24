# run17: run6 + `--max-num-seqs 96`

**Parent:** [run6](../run6/README.md).

**Single change:** `--max-num-seqs 96`, a looser cap than [run16](../run16/README.md).

**When:** run16 queues too much. That shows as p95 TTFT ÷ SLO worsening while p95 TPOT sits well under 50 ms. If run16's TPOT is already close to 50 ms, 96 will cross it. Skip this run and try [run18](../run18/README.md).

```bash
./run17/flag-check.sh
REPLACE=1 ./run17/start.sh
python3 lib/warmup.py
```

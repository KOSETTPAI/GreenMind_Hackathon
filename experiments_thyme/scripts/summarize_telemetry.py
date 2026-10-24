#!/usr/bin/env python3
"""Summarize a telemetry.sh CSV (stdlib only).

Energy here is power.draw integrated over the sampling interval: an estimate to
compare configs against each other, not the grader's NVML energy counter.

The number this approach targets is "util while busy": mean GPU utilization in
samples where vLLM has at least one running request. Anything well below 100%
there is time the GPU sat waiting on the CPU (scheduling, detokenizing,
streaming) while still drawing power.

Usage: python3 summarize_telemetry.py run.csv [--busy-util-threshold 90]
"""

import argparse
import csv


def num(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def delta(rows, key):
    vals = [r[key] for r in rows if r[key] is not None]
    return vals[-1] - vals[0] if len(vals) >= 2 else None


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("csv_path")
    ap.add_argument("--busy-util-threshold", type=float, default=90.0)
    args = ap.parse_args()

    with open(args.csv_path, newline="") as fh:
        rows = [{k: num(v) for k, v in row.items()} for row in csv.DictReader(fh)]
    rows = [r for r in rows if r["t"] is not None and r["power_w"] is not None]
    if len(rows) < 2:
        raise SystemExit("Need at least two samples.")

    energy_j = 0.0
    for a, b in zip(rows, rows[1:]):
        energy_j += a["power_w"] * (b["t"] - a["t"])
    duration = rows[-1]["t"] - rows[0]["t"]

    busy = [r for r in rows if (r["running"] or 0) > 0 and r["util_pct"] is not None]
    idle = [r for r in rows if not (r["running"] or 0) > 0]
    gen_tokens = delta(rows, "generation_tokens_total")

    print(f"samples                 {len(rows)} over {duration:.0f} s")
    print(f"energy (estimate)       {energy_j / 1000:.1f} kJ, mean power {energy_j / duration:.0f} W")
    if idle:
        print(f"idle samples            {len(idle)}, mean power {sum(r['power_w'] for r in idle) / len(idle):.0f} W")
    if busy:
        mean_util = sum(r["util_pct"] for r in busy) / len(busy)
        gaps = sum(1 for r in busy if r["util_pct"] < args.busy_util_threshold)
        print(f"busy samples            {len(busy)}, mean power {sum(r['power_w'] for r in busy) / len(busy):.0f} W")
        print(f"util while busy         {mean_util:.1f}%  <- target of this approach")
        print(f"busy samples < {args.busy_util_threshold:.0f}% util  {gaps / len(busy) * 100:.1f}%")
    running = [r["running"] for r in rows if r["running"] is not None]
    waiting = [r["waiting"] for r in rows if r["waiting"] is not None]
    if running:
        print(f"peak running requests   {max(running):.0f}  <- compare with largest CUDA graph size (T3)")
    if waiting:
        print(f"peak waiting requests   {max(waiting):.0f}")
    pre = delta(rows, "preemptions_total")
    if pre is not None:
        print(f"preemptions             {pre:.0f}")
    if gen_tokens:
        print(f"generated tokens        {gen_tokens:.0f}, {energy_j / gen_tokens:.3f} J/token")
    draft = delta(rows, "spec_draft_tokens_total")
    accepted = delta(rows, "spec_accepted_tokens_total")
    if draft and accepted is not None:
        print(f"spec acceptance         {accepted / draft * 100:.1f}% ({accepted:.0f}/{draft:.0f})")


if __name__ == "__main__":
    main()

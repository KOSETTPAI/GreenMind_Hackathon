#!/usr/bin/env python3
"""Summarize a run4/watch.sh CSV. Standard library only.

Energy comes from the NVML total-energy counter (the grader's source) when the
driver reports it, otherwise from integrated power. The CSV window is wherever
watch.sh was started and stopped, not the grader's timed window, so treat the
joules as a comparison between runs, not the graded number.

  python3 lib/summarize.py telemetry.csv --slo-met 127 --track final
  python3 lib/summarize.py telemetry.csv --slo-met 98 --track validation
"""

import argparse
import csv
import math

# Each grader track has its own baseline. Only the Final counts.
ETA_BASE = {"final": 0.00163, "validation": 0.00154}


def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def delta(rows, key):
    vals = [r[key] for r in rows if r.get(key) is not None]
    return vals[-1] - vals[0] if len(vals) >= 2 else None


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("csv_path")
    ap.add_argument("--slo-met", type=int, help="SLO-met count from grader History")
    ap.add_argument("--track", choices=sorted(ETA_BASE), required=True,
                    help="grader track the run was scored on; picks that track's baseline")
    args = ap.parse_args()

    with open(args.csv_path, newline="") as fh:
        rows = [{k: num(v) for k, v in row.items()} for row in csv.DictReader(fh)]
    rows = [r for r in rows if r["t"] is not None]
    if len(rows) < 2:
        raise SystemExit("Need at least two samples.")
    duration = rows[-1]["t"] - rows[0]["t"]

    e_counter = delta(rows, "energy_mj")
    if e_counter is not None and e_counter > 0:
        energy_j, source = e_counter / 1000.0, "NVML total_energy_consumption"
    else:
        energy_j = sum(
            a["power_w"] * (b["t"] - a["t"])
            for a, b in zip(rows, rows[1:])
            if a["power_w"] is not None
        )
        source = "integrated power.draw"

    busy = [r for r in rows if (r["running"] or 0) > 0]
    idle = [r for r in rows if not (r["running"] or 0) > 0]

    def mean(rs, k):
        vals = [r[k] for r in rs if r[k] is not None]
        return sum(vals) / len(vals) if vals else None

    print(f"samples            {len(rows)} over {duration:.0f} s")
    print(f"energy             {energy_j / 1000:.2f} kJ ({source}), mean {energy_j / duration:.0f} W")
    if busy:
        print(f"busy samples       {len(busy)}, mean {mean(busy, 'power_w') or 0:.0f} W, util {mean(busy, 'util_pct') or 0:.0f}%")
    if idle:
        print(f"idle samples       {len(idle)}, mean {mean(idle, 'power_w') or 0:.0f} W")
    print(f"peak running       {max((r['running'] or 0) for r in rows):.0f}")
    print(f"peak waiting       {max((r['waiting'] or 0) for r in rows):.0f}")
    kv = [r["kv_cache_usage"] for r in rows if r["kv_cache_usage"] is not None]
    if kv:
        print(f"peak KV usage      {max(kv) * 100:.0f}%")
    pre = delta(rows, "preemptions_total")
    if pre is not None:
        print(f"preemptions        {pre:.0f}")

    gen = delta(rows, "generation_tokens_total")
    if gen:
        print(f"generated tokens   {gen:.0f} ({energy_j / gen:.3f} J/token)")

    q, h = delta(rows, "prefix_queries_total"), delta(rows, "prefix_hits_total")
    if q:
        print(f"prefix cache       {h or 0:.0f}/{q:.0f} tokens hit ({(h or 0) / q * 100:.1f}%)")
    else:
        print("prefix cache       no queries recorded (off, or metric absent)")

    d, a = delta(rows, "spec_draft_tokens_total"), delta(rows, "spec_accepted_tokens_total")
    if d:
        print(f"MTP acceptance     {a or 0:.0f}/{d:.0f} draft tokens ({(a or 0) / d * 100:.1f}%)")
    else:
        print("MTP acceptance     no drafts recorded (off, or metric absent)")

    if args.slo_met:
        base = ETA_BASE[args.track]
        eta = args.slo_met / energy_j
        s_e = min(1.0, max(0.0, math.log(eta / base) / math.log(3)))
        print(f"eta (this window)  {eta:.5f} SLO-met/J = {eta / base:.2f}x the {args.track} baseline ({base}), s_E ~ {s_e:.2f}")
        print("                   Indicative only: the grader's window and joules are authoritative.")


if __name__ == "__main__":
    main()

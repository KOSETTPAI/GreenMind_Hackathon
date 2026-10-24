#!/usr/bin/env python3
"""Final-shaped synthetic load against the running server. Standard library only.

Replays an open-loop arrival schedule (ramp to the peak rate, hold, then a quiet
tail) with synthetic prompts. Prompt and output lengths are sampled from the
request-size histograms our own run4 server exported on /metrics during a
Validation and a Final (996 calls). No grader prompt or answer is used.

Scores each request with the grader's SLO rules and estimates the score
components. Accuracy is not measured; A is taken as 1.

It is a GPU workload. Run it only when no Validation or Final is running, and
compare configurations with the same --seed.

  python3 lib/replay.py --label run16
  python3 lib/replay.py --label run6 --total 300 --peak-s 45
"""

import argparse
import csv
import json
import math
import os
import random
import statistics
import subprocess
import sys
import threading
import time
import urllib.request

# (low, high, count) buckets from vllm:request_prompt_tokens and
# vllm:request_generation_tokens on run4 full (2026-10-24 10:51 UTC snapshot).
PROMPT_BUCKETS = [(10, 20, 2), (20, 50, 188), (50, 100, 50), (100, 200, 217), (200, 500, 39),
                  (500, 1000, 341), (1000, 2000, 48), (2000, 5000, 56), (5000, 10000, 30),
                  (10000, 20000, 14), (20000, 32000, 11)]
OUTPUT_BUCKETS = [(1, 2, 1), (5, 10, 8), (10, 20, 26), (20, 50, 90), (50, 100, 238),
                  (100, 200, 252), (200, 500, 257), (500, 1000, 91), (1000, 2000, 13),
                  (2000, 5000, 8), (5000, 8000, 12)]
WORDS = ("energy model token server prompt answer latency throughput budget request river "
         "mountain market report table system cache window policy order invoice weather "
         "city language thai bangkok number value result query document section summary "
         "analysis account record status update review plan schedule metric signal").split()

ETA_BASE = {"final": 0.00163, "validation": 0.00154}


def sample_len(rng, buckets):
    total = sum(c for _, _, c in buckets)
    x = rng.uniform(0, total)
    for lo, hi, c in buckets:
        if x <= c:
            return int(math.exp(rng.uniform(math.log(lo), math.log(hi))))
        x -= c
    return buckets[-1][1]


def arrival_times(total, rate, ramp_s, peak_s, quiet_rate):
    """Ramp linearly 0 -> rate over ramp_s, hold rate for peak_s, then quiet_rate."""
    times, phases = [], []
    k = 1
    while True:
        t = math.sqrt(2 * ramp_s * k / rate)
        if t > ramp_s or len(times) >= total:
            break
        times.append(t); phases.append("ramp"); k += 1
    t = ramp_s
    while len(times) < total and t + 1 / rate <= ramp_s + peak_s:
        t += 1 / rate
        times.append(t); phases.append("peak")
    t = max(t, ramp_s + peak_s)
    while len(times) < total:
        t += 1 / quiet_rate
        times.append(t); phases.append("quiet")
    return times, phases


def make_prompt(rng, n_tokens, history, reuse_prob):
    words = [rng.choice(WORDS) for _ in range(max(1, int(n_tokens * 0.85)))]
    text = " ".join(words)
    if history and rng.random() < reuse_prob:
        # Multi-turn shape: resend an earlier prompt as the prefix, then new text.
        text = rng.choice(history) + "\n" + text
    return text


def metric_total(text, name):
    s = 0.0
    found = False
    for line in text.splitlines():
        if line.startswith(name) and (line[len(name)] in "{ "):
            s += float(line.rsplit(" ", 1)[1]); found = True
    return s if found else None


def read_metrics(url):
    try:
        with urllib.request.urlopen(url, timeout=5) as r:
            return r.read().decode()
    except OSError:
        return ""


class PowerSampler(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self.samples = []
        self.stop = threading.Event()

    def run(self):
        while not self.stop.is_set():
            try:
                out = subprocess.run(["nvidia-smi", "-i", "0", "--query-gpu=power.draw",
                                      "--format=csv,noheader,nounits"],
                                     capture_output=True, text=True, timeout=5).stdout.strip()
                self.samples.append((time.time(), float(out.splitlines()[0])))
            except (OSError, ValueError, IndexError, subprocess.SubprocessError):
                pass
            self.stop.wait(0.5)

    def joules(self, t0, t1):
        pts = [(t, w) for t, w in self.samples if t0 - 1 <= t <= t1 + 1]
        return sum((b[0] - a[0]) * (a[1] + b[1]) / 2 for a, b in zip(pts, pts[1:])) if len(pts) > 1 else None


def one_request(base_url, model, prompt, max_tokens, rec):
    body = {"model": model, "messages": [{"role": "user", "content": prompt}],
            "stream": True, "stream_options": {"include_usage": True},
            "max_tokens": max_tokens, "temperature": 0, "ignore_eos": True,
            "chat_template_kwargs": {"enable_thinking": False}}
    req = urllib.request.Request(base_url + "/chat/completions", data=json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    rec["t_send"] = time.time()
    try:
        with urllib.request.urlopen(req, timeout=900) as resp:
            for raw in resp:
                line = raw.decode("utf-8", "replace").strip()
                if not line.startswith("data:"):
                    continue
                data = line[5:].strip()
                if data == "[DONE]":
                    break
                chunk = json.loads(data)
                if chunk.get("usage"):
                    rec["prompt_tokens"] = chunk["usage"].get("prompt_tokens")
                    rec["completion_tokens"] = chunk["usage"].get("completion_tokens")
                for ch in chunk.get("choices") or []:
                    d = ch.get("delta") or {}
                    if d.get("content") or d.get("reasoning_content") or d.get("reasoning") or d.get("tool_calls"):
                        now = time.time()
                        rec.setdefault("t_first", now)
                        rec["t_last"] = now
                    if ch.get("finish_reason"):
                        rec["finish"] = ch["finish_reason"]
    except Exception as exc:  # noqa: BLE001 - any failure is an SLO miss
        rec["error"] = f"{type(exc).__name__}: {exc}"[:200]
    rec["t_done"] = time.time()


def score(rec):
    if rec.get("error") or "t_first" not in rec or not rec.get("prompt_tokens"):
        return dict(ttft=None, tpot=None, slo_ttft=None, met=False)
    ttft = rec["t_first"] - rec["t_send"]
    slo = 0.5 + 0.25 * rec["prompt_tokens"] / 1000
    n = rec.get("completion_tokens") or 0
    tpot = (rec["t_last"] - rec["t_first"]) / (n - 1) if n > 1 else None
    met = ttft <= slo and (tpot is None or tpot <= 0.050) and n < 8192
    return dict(ttft=ttft, tpot=tpot, slo_ttft=slo, met=met)


def pct(values, p):
    v = sorted(x for x in values if x is not None)
    return v[min(len(v) - 1, int(math.ceil(p * len(v)) - 1))] if v else None


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--base-url", default="http://127.0.0.1:8000/v1")
    ap.add_argument("--model", default="mango1.5-awq-w4a16")
    ap.add_argument("--label", default="replay")
    ap.add_argument("--total", type=int, default=300)
    ap.add_argument("--rate", type=float, default=4.0, help="peak arrivals per second")
    ap.add_argument("--ramp-s", type=float, default=30)
    ap.add_argument("--peak-s", type=float, default=45)
    ap.add_argument("--quiet-rate", type=float, default=1.0)
    ap.add_argument("--reuse-prob", type=float, default=0.4,
                    help="share of prompts that resend an earlier prompt as prefix")
    ap.add_argument("--seed", type=int, default=17)
    ap.add_argument("--track", choices=["final", "validation"], default="final")
    ap.add_argument("--out", default=None, help="per-request CSV")
    ap.add_argument("--force", action="store_true", help="run even if the server is busy")
    args = ap.parse_args()

    metrics_url = args.base_url.rsplit("/v1", 1)[0] + "/metrics"
    m0 = read_metrics(metrics_url)
    busy = (metric_total(m0, "vllm:num_requests_running") or 0) + (metric_total(m0, "vllm:num_requests_waiting") or 0)
    if busy and not args.force:
        sys.exit(f"[ABORT] the server already has {busy:.0f} running/waiting requests. "
                 "A grader run may be active. Never replay during a graded window.")

    rng = random.Random(args.seed)
    times, phases = arrival_times(args.total, args.rate, args.ramp_s, args.peak_s, args.quiet_rate)
    history, plan = [], []
    for t, ph in zip(times, phases):
        prompt = make_prompt(rng, sample_len(rng, PROMPT_BUCKETS), history, args.reuse_prob)
        history.append(prompt[:20000])
        plan.append(dict(t=t, phase=ph, prompt=prompt, max_tokens=min(8000, sample_len(rng, OUTPUT_BUCKETS))))

    print(f"[{args.label}] {len(plan)} requests: ramp {phases.count('ramp')}, peak {phases.count('peak')}, "
          f"quiet {phases.count('quiet')}; last arrival at {times[-1]:.0f}s; seed {args.seed}")
    power = PowerSampler(); power.start()
    recs = [dict(i=i, phase=p["phase"], max_tokens=p["max_tokens"]) for i, p in enumerate(plan)]
    threads, inflight_peak = [], 0
    start = time.time() + 1
    for p, rec in zip(plan, recs):
        delay = start + p["t"] - time.time()
        if delay > 0:
            time.sleep(delay)
        th = threading.Thread(target=one_request, args=(args.base_url, args.model, p["prompt"], p["max_tokens"], rec), daemon=True)
        th.start(); threads.append(th)
        inflight_peak = max(inflight_peak, sum(1 for x in threads if x.is_alive()))
    for th in threads:
        th.join()
    power.stop.set(); power.join(timeout=2)
    m1 = read_metrics(metrics_url)

    scored = [dict(r, **score(r)) for r in recs]
    t0 = min(r["t_send"] for r in recs)
    t1 = max(r["t_done"] for r in recs)
    met = sum(1 for r in scored if r["met"])
    peak = [r for r in scored if r["phase"] == "peak"]
    s_t = sum(1 for r in peak if r["met"]) / len(peak) if peak else None
    ratios = [r["ttft"] / r["slo_ttft"] for r in scored if r["ttft"] is not None]
    p95_ratio = pct(ratios, 0.95)
    p95_tpot = pct([r["tpot"] for r in scored], 0.95)
    s_l = math.sqrt(min(1, 1 / p95_ratio) * min(1, 0.050 / p95_tpot)) if p95_ratio and p95_tpot else None
    joules = power.joules(t0, t1)
    eta = met / joules if joules else None
    rel = eta / ETA_BASE[args.track] if eta else None
    s_e = max(0.0, min(1.0, math.log(rel) / math.log(3))) if rel else None
    s_est = 100 * s_e ** 0.6 * s_t ** 0.2 * s_l ** 0.2 if None not in (s_e, s_t, s_l) and s_t > 0 else None
    errors = [r for r in scored if r.get("error")]

    def delta(name):
        a, b = metric_total(m0, name), metric_total(m1, name)
        return (b - a) if a is not None and b is not None else None
    pq, ph = delta("vllm:prefix_cache_queries_total"), delta("vllm:prefix_cache_hits_total")

    print(f"[{args.label}] window {t1 - t0:.0f}s  client in-flight peak {inflight_peak}  errors {len(errors)}")
    print(f"  SLO-met {met}/{len(scored)}  peak-phase SLO share (sT est) {s_t:.2f}" if s_t is not None else f"  SLO-met {met}/{len(scored)}")
    print(f"  p95 TTFT/SLO {p95_ratio:.2f}  p95 TTFT {pct([r['ttft'] for r in scored], 0.95):.2f}s  "
          f"p95 TPOT {p95_tpot * 1000:.0f}ms  sL est {s_l:.2f}" if s_l else "  latency: not enough data")
    if joules:
        print(f"  energy {joules / 1000:.1f} kJ  J/request {joules / len(scored):.0f}  "
              f"eta {eta:.5f} = {rel:.2f}x {args.track} base  sE est {s_e:.2f}")
    if pq:
        print(f"  prefix-cache hits {100 * ph / pq:.0f}% of {pq:.0f} prompt tokens")
    if s_est is not None:
        print(f"  S estimate (A assumed 1): {s_est:.1f}   [synthetic prompts, not a grader score]")
    if errors:
        print(f"  first error: {errors[0]['error']}")

    out = args.out or os.path.expanduser(f"~/greenmind-runs/latest/replay-{args.label}-{time.strftime('%Y%m%d-%H%M%S')}.csv")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    cols = ["i", "phase", "max_tokens", "prompt_tokens", "completion_tokens", "finish", "ttft", "slo_ttft", "tpot", "met", "error"]
    with open(out, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        for r in scored:
            w.writerow(r)
    print(f"  per-request CSV: {out}")


if __name__ == "__main__":
    main()

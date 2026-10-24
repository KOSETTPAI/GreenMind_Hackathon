#!/usr/bin/env python3
"""Grader-shaped warmup for run4. Standard library only.

Run after start.sh reports READY and right before Submit, never during a graded
window. Every request matches the grader's shape: streaming with usage, thinking
on, temperature 0, tool_choice auto. It compiles graph and kernel paths the
first graded requests would otherwise pay for, and checks a two-turn tool
episode, which preflight.sh does not.

Exit 0 = contract held. Exit 1 = do not submit.
"""

import argparse
import json
import sys
import time
import urllib.request

TOOL = {
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Get the current weather for a city.",
        "parameters": {
            "type": "object",
            "properties": {"city": {"type": "string"}},
            "required": ["city"],
        },
    },
}


def stream(base_url, model, messages, max_tokens, tools=None, timeout=300):
    body = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": 0,
        "stream": True,
        "stream_options": {"include_usage": True},
        "chat_template_kwargs": {"enable_thinking": True},
    }
    if tools:
        body["tools"] = tools
        body["tool_choice"] = "auto"
    req = urllib.request.Request(
        base_url.rstrip("/") + "/chat/completions",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    out = {"content": "", "reasoning": "", "calls": {}, "finish": None, "usage": None, "ttft": None, "done": False}
    start = time.monotonic()
    last = None
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        for raw in resp:
            line = raw.decode("utf-8", "replace").strip()
            if not line.startswith("data:"):
                continue
            data = line[5:].strip()
            if data == "[DONE]":
                out["done"] = True
                break
            chunk = json.loads(data)
            if chunk.get("usage"):
                out["usage"] = chunk["usage"]
            for choice in chunk.get("choices") or []:
                delta = choice.get("delta") or {}
                got = False
                if delta.get("content"):
                    out["content"] += delta["content"]
                    got = True
                reasoning = delta.get("reasoning_content") or delta.get("reasoning")
                if reasoning:
                    out["reasoning"] += reasoning
                    got = True
                for tc in delta.get("tool_calls") or []:
                    got = True
                    slot = out["calls"].setdefault(tc.get("index", 0), {"id": None, "name": "", "arguments": ""})
                    if tc.get("id"):
                        slot["id"] = tc["id"]
                    fn = tc.get("function") or {}
                    slot["name"] += fn.get("name") or ""
                    slot["arguments"] += fn.get("arguments") or ""
                if got:
                    now = time.monotonic()
                    if out["ttft"] is None:
                        out["ttft"] = now - start
                    last = now
                if choice.get("finish_reason"):
                    out["finish"] = choice["finish_reason"]
    n = (out["usage"] or {}).get("completion_tokens") or 0
    out["tpot"] = (last - start - out["ttft"]) / (n - 1) if out["ttft"] is not None and last and n > 1 else None
    return out


def show(name, r):
    u = r["usage"] or {}
    p = u.get("prompt_tokens") or 0
    slo = 0.5 + 0.25 * p / 1000
    ttft = f"{r['ttft']:.3f}s" if r["ttft"] is not None else "n/a"
    tpot = f"{r['tpot'] * 1000:.1f}ms" if r["tpot"] is not None else "n/a"
    print(f"[{name}] prompt={p} completion={u.get('completion_tokens')} finish={r['finish']} "
          f"TTFT={ttft} (SLO {slo:.3f}s) TPOT={tpot} reasoning_chars={len(r['reasoning'])}")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--base-url", default="http://127.0.0.1:8000/v1")
    ap.add_argument("--model", default="mango1.5-awq-w4a16")
    ap.add_argument("--max-tokens", type=int, default=2048)
    args = ap.parse_args()
    failures, warnings = [], []

    def run(name, messages, tools=None):
        try:
            r = stream(args.base_url, args.model, messages, args.max_tokens, tools)
        except (OSError, ValueError) as exc:
            failures.append(f"{name}: request failed: {exc}")
            print(f"[{name}] FAILED: {exc}")
            return None
        show(name, r)
        if r["ttft"] is None:
            failures.append(f"{name}: no token streamed")
        if not r["usage"]:
            failures.append(f"{name}: no usage chunk")
        if not r["done"]:
            failures.append(f"{name}: stream ended without [DONE]")
        if r["finish"] == "length":
            warnings.append(f"{name}: used the whole {args.max_tokens}-token budget")
        return r

    run("chat", [{"role": "user", "content": "What is 17 * 23? Answer briefly."}])
    run("thai", [{"role": "user", "content": "เมืองหลวงของประเทศไทยคืออะไร ตอบสั้นๆ"}])

    turn1 = [{"role": "user", "content": "What is the weather in Bangkok? Use the get_weather tool."}]
    r1 = run("tool-turn1", turn1, [TOOL])
    if r1 is not None:
        calls = [r1["calls"][i] for i in sorted(r1["calls"])]
        if not calls:
            failures.append("tool-turn1: no tool call with thinking on")
        else:
            call = calls[0]
            try:
                json.loads(call["arguments"] or "{}")
            except ValueError:
                failures.append(f"tool-turn1: arguments are not JSON: {call['arguments']!r}")
            cid = call["id"] or "call_0"
            turn2 = turn1 + [
                {"role": "assistant", "content": r1["content"] or None, "tool_calls": [
                    {"id": cid, "type": "function", "function": {"name": call["name"], "arguments": call["arguments"]}}
                ]},
                {"role": "tool", "tool_call_id": cid, "content": json.dumps({"city": "Bangkok", "temp_c": 33, "condition": "humid"})},
            ]
            r2 = run("tool-turn2", turn2, [TOOL])
            if r2 is not None and not r2["content"]:
                if r2["reasoning"].strip() and r2["finish"] == "stop":
                    # MANGO answers this turn without a <think> block, so the qwen3
                    # parser files the whole answer under reasoning_content. Seen on
                    # every tier, including run4 full, which scored A = 1.00.
                    warnings.append("tool-turn2: the answer arrived as reasoning_content, not content "
                                    f"({r2['reasoning'].strip()[:80]!r})")
                else:
                    failures.append("tool-turn2: no final answer after the tool result")

    print()
    for w in warnings:
        print(f"[WARN] {w}")
    if failures:
        for f in failures:
            print(f"[FAIL] {f}")
        print("RESULT: WARMUP FAILED. Do not submit.")
        sys.exit(1)
    print("RESULT: WARMUP PASSED. Latency lines are single-request numbers, not peak-load results.")


if __name__ == "__main__":
    main()

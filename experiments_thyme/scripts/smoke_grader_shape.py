#!/usr/bin/env python3
"""Grader-shaped smoke test for an OpenAI-compatible endpoint (stdlib only).

Unlike scripts/test-*.sh (thinking off, streaming and tool calls tested apart),
every request here matches the grader's shape: streaming, usage in the stream,
thinking mode on, temperature 0, tool_choice auto. It checks the contract and
reports TTFT / TPOT against the per-request SLO from the briefing:

    TTFT <= 0.5 s + 0.25 s per 1,000 prompt tokens
    TPOT <= 50 ms (skipped for one-token answers)

Single requests on an idle server say nothing about peak-load latency; use this
to catch broken configs (e.g. tool calls or streaming broken by a new flag)
before spending a Validation submission.

Usage:
    python3 smoke_grader_shape.py --base-url http://127.0.0.1:8000/v1 --model mango1.5-awq-w4a16
"""

import argparse
import json
import sys
import time
import urllib.request

WEATHER_TOOL = {
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


def stream_chat(base_url, model, messages, max_tokens, tools=None, timeout=900):
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
    result = {
        "content": "",
        "reasoning": "",
        "tool_calls": {},
        "finish_reason": None,
        "usage": None,
        "ttft": None,
        "chunks": 0,
    }
    t_start = time.monotonic()
    t_last = None
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        for raw in resp:
            line = raw.decode("utf-8").strip()
            if not line.startswith("data:"):
                continue
            data = line[len("data:"):].strip()
            if data == "[DONE]":
                break
            chunk = json.loads(data)
            result["chunks"] += 1
            if chunk.get("usage"):
                result["usage"] = chunk["usage"]
            for choice in chunk.get("choices") or []:
                delta = choice.get("delta") or {}
                got_token = False
                if delta.get("content"):
                    result["content"] += delta["content"]
                    got_token = True
                # vLLM has used both names for the reasoning field.
                reasoning = delta.get("reasoning_content") or delta.get("reasoning")
                if reasoning:
                    result["reasoning"] += reasoning
                    got_token = True
                for tc in delta.get("tool_calls") or []:
                    got_token = True
                    slot = result["tool_calls"].setdefault(
                        tc.get("index", 0), {"id": None, "name": "", "arguments": ""}
                    )
                    if tc.get("id"):
                        slot["id"] = tc["id"]
                    fn = tc.get("function") or {}
                    slot["name"] += fn.get("name") or ""
                    slot["arguments"] += fn.get("arguments") or ""
                if got_token:
                    now = time.monotonic()
                    if result["ttft"] is None:
                        result["ttft"] = now - t_start
                    t_last = now
                if choice.get("finish_reason"):
                    result["finish_reason"] = choice["finish_reason"]

    usage = result["usage"] or {}
    n_out = usage.get("completion_tokens") or 0
    if result["ttft"] is not None and t_last is not None and n_out > 1:
        result["tpot"] = (t_last - t_start - result["ttft"]) / (n_out - 1)
    else:
        result["tpot"] = None
    return result


def report(name, r, max_tokens):
    problems = []
    usage = r["usage"] or {}
    prompt_tokens = usage.get("prompt_tokens")
    if not r["usage"]:
        problems.append("no usage chunk in stream")
    if r["ttft"] is None:
        problems.append("no token streamed")
    if r["finish_reason"] == "length" or usage.get("completion_tokens") == max_tokens:
        problems.append("cut off at max_tokens (would fail SLO)")

    ttft_slo = 0.5 + 0.25 * (prompt_tokens or 0) / 1000
    ttft_ok = r["ttft"] is not None and r["ttft"] <= ttft_slo
    tpot_ok = r["tpot"] is None or r["tpot"] <= 0.050
    ttft_s = f"{r['ttft']:.3f}s" if r["ttft"] is not None else "n/a"
    tpot_s = f"{r['tpot'] * 1000:.1f}ms" if r["tpot"] is not None else "n/a"
    print(
        f"[{name}] prompt={prompt_tokens} completion={usage.get('completion_tokens')} "
        f"chunks={r['chunks']} finish={r['finish_reason']} "
        f"TTFT={ttft_s} (SLO {ttft_slo:.3f}s {'ok' if ttft_ok else 'MISS'}) "
        f"TPOT={tpot_s} ({'ok' if tpot_ok else 'MISS'}) "
        f"reasoning_chars={len(r['reasoning'])}"
    )
    if not r["reasoning"]:
        print(f"[{name}] note: no reasoning streamed; check thinking mode / --reasoning-parser")
    return problems


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--base-url", default="http://127.0.0.1:8000/v1")
    ap.add_argument("--model", default="mango1.5-awq-w4a16")
    ap.add_argument("--max-tokens", type=int, default=8192, help="grader uses 8192")
    args = ap.parse_args()

    failures = []

    def run(name, messages, tools=None):
        try:
            r = stream_chat(args.base_url, args.model, messages, args.max_tokens, tools)
        # URLError/HTTPError, timeouts and connection resets are all OSError.
        except (OSError, json.JSONDecodeError) as exc:
            failures.append(f"{name}: request failed: {exc}")
            print(f"[{name}] FAILED: {exc}")
            return None
        failures.extend(f"{name}: {p}" for p in report(name, r, args.max_tokens))
        return r

    run("chat", [{"role": "user", "content": "What is 17 * 23? Answer briefly."}])
    run("thai", [{"role": "user", "content": "เมืองหลวงของประเทศไทยคืออะไร ตอบสั้นๆ"}])

    # Two-turn tool episode, like the grader's agentic class.
    turn1_msgs = [{"role": "user", "content": "What is the weather in Bangkok? Use the get_weather tool."}]
    r1 = run("tool-turn1", turn1_msgs, [WEATHER_TOOL])
    if r1 is not None:
        calls = [r1["tool_calls"][i] for i in sorted(r1["tool_calls"])]
        if not calls:
            failures.append("tool-turn1: no tool call returned")
        else:
            call = calls[0]
            try:
                json.loads(call["arguments"] or "{}")
            except json.JSONDecodeError:
                failures.append(f"tool-turn1: arguments are not valid JSON: {call['arguments']!r}")
            call_id = call["id"] or "call_0"
            turn2_msgs = turn1_msgs + [
                {
                    "role": "assistant",
                    "content": r1["content"] or None,
                    "tool_calls": [
                        {
                            "id": call_id,
                            "type": "function",
                            "function": {"name": call["name"], "arguments": call["arguments"]},
                        }
                    ],
                },
                {
                    "role": "tool",
                    "tool_call_id": call_id,
                    "content": json.dumps({"city": "Bangkok", "temp_c": 33, "condition": "humid"}),
                },
            ]
            r2 = run("tool-turn2", turn2_msgs, [WEATHER_TOOL])
            if r2 is not None and not r2["content"]:
                failures.append("tool-turn2: no final answer after tool result")

    print()
    if failures:
        print("FAILED checks:")
        for f in failures:
            print("  - " + f)
        sys.exit(1)
    print("All contract checks passed (latency lines are informational).")


if __name__ == "__main__":
    main()

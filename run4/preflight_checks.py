#!/usr/bin/env python3
"""Individual checks for run4/preflight.sh. Standard library only.

Each subcommand prints its details and exits:
  0  pass
  1  fail (do not benchmark)
  3  pass with a warning
"""

import json
import sys
import time
import urllib.error
import urllib.request

PASS, FAIL, WARN = 0, 1, 3

# Flags that never take a value. Used so a boolean flag is not read as
# consuming the next token when parsing the container command.
BOOLEAN_FLAGS = {
    "--trust-remote-code",
    "--enable-auto-tool-choice",
    "--enable-prefix-caching",
    "--no-enable-prefix-caching",
    "--enable-chunked-prefill",
    "--no-enable-chunked-prefill",
    "--enforce-eager",
    "--disable-log-requests",
    "--disable-log-stats",
}

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


# ---------- container command vs experiment profile ----------

def read_profile(path):
    model = None
    flags = {}
    with open(path, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("-"):
                parts = line.split(None, 1)
                key = parts[0]
                value = parts[1].strip() if len(parts) > 1 else None
                if key in flags:
                    raise SystemExit(f"profile {path}: duplicate flag {key}")
                flags[key] = value
            elif model is None:
                model = line
            else:
                raise SystemExit(f"profile {path}: second positional line {line!r}")
    if model is None:
        raise SystemExit(f"profile {path}: no model line")
    return model, flags


def parse_command(tokens, known_booleans):
    model = None
    flags = {}
    duplicates = []
    extra_positional = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok.startswith("-") and len(tok) > 1:
            if "=" in tok:
                key, value = tok.split("=", 1)
            elif (
                tok not in known_booleans
                and i + 1 < len(tokens)
                and not tokens[i + 1].startswith("--")
            ):
                key, value = tok, tokens[i + 1]
                i += 1
            else:
                key, value = tok, None
            if key == "--model":
                model = value
            elif key in flags:
                duplicates.append(key)
            flags[key] = value
        elif model is None:
            model = tok
        else:
            extra_positional.append(tok)
        i += 1
    flags.pop("--model", None)
    return model, flags, duplicates, extra_positional


def same_value(a, b):
    if a == b:
        return True
    if a is None or b is None:
        return False
    try:
        return float(a) == float(b)
    except ValueError:
        pass
    try:
        return json.loads(a) == json.loads(b)
    except (ValueError, TypeError):
        return False


def cmd_args(profile_path, cmd_json, expected_max_len=""):
    want_model, want_flags = read_profile(profile_path)
    try:
        tokens = json.loads(cmd_json) or []
    except ValueError:
        print(f"  container command is not JSON: {cmd_json!r}")
        return FAIL
    booleans = BOOLEAN_FLAGS | {k for k, v in want_flags.items() if v is None}
    model, flags, duplicates, extra_pos = parse_command(tokens, booleans)

    problems = []
    if tokens[:2] == ["vllm", "serve"]:
        problems.append("command starts with 'vllm serve'; the image entrypoint already runs it")
    if model != want_model:
        problems.append(f"model: container has {model!r}, profile expects {want_model!r}")
    for key in duplicates:
        problems.append(f"flag passed more than once: {key}")
    for tok in extra_pos:
        problems.append(f"unexpected positional argument: {tok!r}")
    for key, want in want_flags.items():
        if key not in flags:
            problems.append(f"missing {key}" + (f" {want}" if want else ""))
        elif not same_value(flags[key], want):
            problems.append(f"{key}: container has {flags[key]!r}, profile expects {want!r}")
    for key in flags:
        if key not in want_flags:
            shown = f"{key} {flags[key]}" if flags[key] is not None else key
            problems.append(f"unexpected flag not in profile: {shown}")

    actual_len = flags.get("--max-model-len")
    print(f"  container model: {model}")
    print(f"  container --max-model-len: {actual_len}")
    print(f"  container --served-model-name: {flags.get('--served-model-name')}")
    if expected_max_len and not same_value(actual_len, expected_max_len):
        problems.append(f"--max-model-len is {actual_len}, EXPECTED_MAX_LEN is {expected_max_len}")

    for p in problems:
        print(f"  - {p}")
    return FAIL if problems else PASS


def cmd_profile_value(profile_path, key):
    model, flags = read_profile(profile_path)
    if key == "model":
        print(model)
        return PASS
    value = flags.get(key)
    if value is None:
        return FAIL
    print(value)
    return PASS


# ---------- docker port binding ----------

def cmd_ports(port_lines, expected_bind, host_port):
    bindings = []
    for line in port_lines.splitlines():
        line = line.strip()
        if not line:
            continue
        host, _, port = line.rpartition(":")
        bindings.append((host.strip("[]"), port))
    if not bindings:
        print("  no published binding for container port 8000/tcp")
        return FAIL
    for host, port in bindings:
        print(f"  published {host}:{port} -> container 8000/tcp")
    ports_ok = [b for b in bindings if b[1] == host_port]
    if not ports_ok:
        print(f"  none of the bindings use host port {host_port}")
        return FAIL
    hosts = {h for h, _ in ports_ok}
    loopback = {"127.0.0.1", "::1"}
    if expected_bind in loopback:
        if not hosts <= loopback:
            print(f"  expected loopback only, but published on {sorted(hosts - loopback)}")
            return FAIL
        print("  loopback only: clients outside the VM cannot reach this port")
        return PASS
    if expected_bind not in hosts:
        print(f"  expected bind {expected_bind}, found {sorted(hosts)}")
        return FAIL
    if expected_bind in {"0.0.0.0", "::"}:
        print("  listening on all interfaces: restrict inbound access to trusted clients")
        return WARN
    return PASS


# ---------- HTTP checks ----------

def http_json(method, url, body=None, timeout=15):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(
        url, data=data, method=method, headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.status, json.loads(resp.read().decode("utf-8"))


def report_http_error(exc):
    if isinstance(exc, urllib.error.HTTPError):
        body = exc.read().decode("utf-8", "replace")[:2000]
        print(f"  HTTP {exc.code}: {body}")
    else:
        print(f"  request failed: {exc}")


def cmd_models(base_url, model_id, expected_max_len, expected_root):
    try:
        status, data = http_json("GET", base_url.rstrip("/") + "/models")
    except (OSError, ValueError) as exc:
        report_http_error(exc)
        return FAIL
    items = data.get("data") or []
    ids = [it.get("id") for it in items]
    print(f"  HTTP {status}, model ids: {ids}")
    match = [it for it in items if it.get("id") == model_id]
    if not match:
        print(f"  expected model id {model_id!r} is not served")
        return FAIL
    item = match[0]
    result = PASS
    served_len = item.get("max_model_len")
    print(f"  served max_model_len: {served_len}")
    if served_len is None:
        print("  /models did not report max_model_len; relying on the container command")
        result = WARN
    elif expected_max_len and not same_value(str(served_len), expected_max_len):
        print(f"  engine context is {served_len}, expected {expected_max_len}")
        return FAIL
    root = item.get("root")
    if root is not None:
        print(f"  served checkpoint: {root}")
        if expected_root and root != expected_root:
            print(f"  checkpoint differs from profile: expected {expected_root!r}")
            return FAIL
    return result


def chat_body(model_id, content, max_tokens, thinking, stream, tools=None):
    body = {
        "model": model_id,
        "messages": [{"role": "user", "content": content}],
        "max_tokens": max_tokens,
        "temperature": 0,
        "stream": stream,
        "chat_template_kwargs": {"enable_thinking": thinking},
    }
    if stream:
        body["stream_options"] = {"include_usage": True}
    if tools:
        body["tools"] = tools
        body["tool_choice"] = "auto"
    return body


def cmd_chat(base_url, model_id):
    body = chat_body(model_id, "Reply with exactly: PREFLIGHT_OK", 64, False, False)
    try:
        status, data = http_json("POST", base_url.rstrip("/") + "/chat/completions", body, timeout=90)
    except (OSError, ValueError) as exc:
        report_http_error(exc)
        return FAIL
    choices = data.get("choices") or []
    content = (choices[0].get("message") or {}).get("content") or "" if choices else ""
    print(f"  HTTP {status}, reply: {content!r}")
    if "PREFLIGHT_OK" not in content:
        print("  reply did not contain PREFLIGHT_OK")
        return FAIL
    if not data.get("usage"):
        print("  response has no usage block")
        return FAIL
    return PASS


def stream_chat(base_url, body, timeout):
    req = urllib.request.Request(
        base_url.rstrip("/") + "/chat/completions",
        data=json.dumps(body).encode(),
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    out = {
        "content": "",
        "reasoning": "",
        "tool_calls": {},
        "finish": None,
        "usage": None,
        "ttft": None,
        "done": False,
        "chunks": 0,
        "errors": [],
    }
    start = time.monotonic()
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        for raw in resp:
            if time.monotonic() - start > timeout:
                out["errors"].append(f"stream exceeded {timeout}s")
                break
            line = raw.decode("utf-8", "replace").strip()
            if not line.startswith("data:"):
                continue
            payload = line[5:].strip()
            if payload == "[DONE]":
                out["done"] = True
                break
            chunk = json.loads(payload)
            out["chunks"] += 1
            if chunk.get("error"):
                out["errors"].append(str(chunk["error"]))
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
                    slot = out["tool_calls"].setdefault(tc.get("index", 0), {"name": "", "arguments": ""})
                    fn = tc.get("function") or {}
                    slot["name"] += fn.get("name") or ""
                    slot["arguments"] += fn.get("arguments") or ""
                if got and out["ttft"] is None:
                    out["ttft"] = time.monotonic() - start
                if choice.get("finish_reason"):
                    out["finish"] = choice["finish_reason"]
    return out


def describe(r):
    usage = r["usage"] or {}
    ttft = f"{r['ttft']:.3f}s" if r["ttft"] is not None else "n/a"
    print(
        f"  chunks={r['chunks']} finish={r['finish']} done={r['done']} ttft={ttft} "
        f"prompt_tokens={usage.get('prompt_tokens')} completion_tokens={usage.get('completion_tokens')} "
        f"content_chars={len(r['content'])} reasoning_chars={len(r['reasoning'])}"
    )


def stream_basics(r):
    problems = list(r["errors"])
    if r["ttft"] is None:
        problems.append("no token was streamed")
    if not r["usage"]:
        problems.append("no usage chunk (stream_options.include_usage)")
    if not r["done"]:
        problems.append("stream ended without [DONE]")
    return problems


def cmd_stream(base_url, model_id):
    body = chat_body(model_id, "Count from 1 to 5, separated by spaces.", 64, False, True)
    try:
        r = stream_chat(base_url, body, 90)
    except (OSError, ValueError) as exc:
        report_http_error(exc)
        return FAIL
    describe(r)
    problems = stream_basics(r)
    if not r["content"]:
        problems.append("no content streamed")
    for p in problems:
        print(f"  - {p}")
    return FAIL if problems else PASS


def cmd_tool(base_url, model_id):
    body = chat_body(
        model_id,
        "What is the weather in Bangkok? Use the get_weather tool.",
        512,
        False,
        True,
        tools=[WEATHER_TOOL],
    )
    try:
        r = stream_chat(base_url, body, 120)
    except (OSError, ValueError) as exc:
        report_http_error(exc)
        return FAIL
    describe(r)
    problems = stream_basics(r)
    calls = [r["tool_calls"][i] for i in sorted(r["tool_calls"])]
    if not calls:
        problems.append("no tool_calls in the stream (check --enable-auto-tool-choice and --tool-call-parser)")
    else:
        call = calls[0]
        print(f"  tool call: {call['name']}({call['arguments']})")
        if call["name"] != "get_weather":
            problems.append(f"unexpected tool name {call['name']!r}")
        try:
            args = json.loads(call["arguments"] or "{}")
            if not isinstance(args, dict) or "city" not in args:
                problems.append("tool arguments have no 'city'")
        except ValueError:
            problems.append("tool arguments are not valid JSON")
    for p in problems:
        print(f"  - {p}")
    return FAIL if problems else PASS


def cmd_thinking(base_url, model_id):
    body = chat_body(model_id, "What is 2 + 2? Answer briefly.", 1024, True, True)
    try:
        r = stream_chat(base_url, body, 180)
    except (OSError, ValueError) as exc:
        report_http_error(exc)
        return FAIL
    describe(r)
    problems = stream_basics(r)
    for p in problems:
        print(f"  - {p}")
    if problems:
        return FAIL
    usage = r["usage"] or {}
    if r["ttft"] is not None and usage.get("prompt_tokens") is not None:
        slo = 0.5 + 0.25 * usage["prompt_tokens"] / 1000
        print(f"  idle-server TTFT {r['ttft']:.3f}s vs SLO {slo:.3f}s (informational)")
    if r["finish"] == "length":
        print("  thinking used the whole 1024-token budget; not proof of a broken endpoint")
        return WARN
    if not r["reasoning"]:
        print("  no reasoning field streamed; check --reasoning-parser qwen3")
        return WARN
    return PASS


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    cmd, args = argv[1], argv[2:]
    table = {
        "args": cmd_args,
        "profile-value": cmd_profile_value,
        "ports": cmd_ports,
        "models": cmd_models,
        "chat": cmd_chat,
        "stream": cmd_stream,
        "tool": cmd_tool,
        "thinking": cmd_thinking,
    }
    if cmd not in table:
        print(f"unknown check: {cmd}")
        return 2
    return table[cmd](*args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))

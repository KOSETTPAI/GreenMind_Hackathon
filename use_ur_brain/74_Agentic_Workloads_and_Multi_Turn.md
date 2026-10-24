# 74. Agentic Workloads and Multi-Turn Conversations

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Tool Calling](73_Tool_Calling.md)

## In one sentence
An agentic workload is a multi-step task where one user goal triggers several model calls, tool calls, and follow-up prompts that each carry the growing conversation history.

## Plain-English explanation
"Book me a flight" → model calls `search_flights` → tool returns results → model calls `book_flight` → tool confirms → model answers. That's 3 model requests, each including all previous messages. Prompts grow every turn, and steps depend on each other — a slow step delays the whole chain.

## Technical depth
- **Prompt growth:** turn k's prompt = system + tools + all previous messages and tool results → prefill cost increases per turn.
- **Prefix reuse:** consecutive turns share long identical prefixes → [Prefix Caching](96_Prefix_Caching.md) can save much prefill (if supported for the hybrid model's state).
- **Dependent arrivals:** next request arrives only after the previous response + tool time → closed-loop within a session; bursts across sessions.
- **Errors compound:** one malformed tool call can derail the whole task.
- Multi-turn chat (no tools) has the same history-growth behavior.

## Backend-engineer analogy
A saga/workflow of dependent service calls where each step's payload includes the full history — latency adds up along the critical path.

## Why it matters for GreenMind
Agentic requests stress TTFT (long prompts), tool-call correctness, and benefit most from prefix caching. Their accuracy may be scored per task.

## Common mistakes
- Benchmarking single-turn only.
- Assuming prefix caching works for hybrid recurrent state without verifying.

## Related concepts
[Tool Calling](73_Tool_Calling.md) · [Prefix Caching](96_Prefix_Caching.md) · [RAG](75_RAG.md) · [Workload Mix](6_Workload_Mix.md)

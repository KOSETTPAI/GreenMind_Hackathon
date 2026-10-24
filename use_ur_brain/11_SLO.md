# 11. SLO (Service-Level Objective)

**Stage:** 0 / 3 | **Priority:** Must know | **Prerequisites:** [Hard Gates](2_Hard_Gates_and_Eligibility.md)

## In one sentence
An SLO is a target that a request or service must meet — for LLM serving typically limits on TTFT, TPOT, completion, and correctness.

## Plain-English explanation
In normal web services an SLO might be "99% of requests under 300 ms." For LLMs, one latency number isn't enough because responses stream token by token, so SLOs usually split into:
- **TTFT limit** — how long the user waits before the first token appears.
- **TPOT limit** — how fast tokens keep flowing after that.
- **Completion/correctness** — the request finished, wasn't an error, and had a valid format.

In this hackathon, request-level SLOs probably decide whether a request is "useful" (counts toward score) or not.

## Technical depth
- **Request-level SLO:** applied per request (pass/fail each one). Throughput may only count passing requests ("goodput").
- **Aggregate SLO:** applied over a distribution (e.g., p95 TTFT < X).
- **Goodput** = rate of requests that meet SLOs. It's the more honest throughput metric: a server that does 100 req/s but fails half its SLOs has goodput 50 req/s.
- Tight SLOs limit how large you can make batches: bigger batches increase throughput but also increase each request's TPOT and queueing delay.

## Backend-engineer analogy
Exactly like SRE SLOs, but with two latency dimensions (time to first byte and streaming rate) instead of one.

## Why it matters for GreenMind
Every throughput or energy optimization must be checked against SLO pass rate. A configuration that maximizes tokens/sec while pushing some requests past the TPOT limit can lower the real score.

## Common mistakes
- Reporting raw throughput instead of SLO-passing throughput.
- Watching averages while tail requests violate SLOs.

## Related concepts
[Useful Requests](12_Useful_Requests.md) · [TTFT](62_TTFT.md) · [TPOT](63_TPOT.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Throughput](66_Throughput.md)

# 59. Backpressure

**Stage:** 3 | **Priority:** Should know | **Prerequisites:** [Concurrency](58_Concurrency.md)

## In one sentence
Backpressure is a mechanism that limits incoming work or queue growth when downstream capacity is saturated, instead of letting queues grow without bound.

## Plain-English explanation
If requests arrive faster than the server can process them, the queue grows forever and every request gets slower. Backpressure pushes back: reject (HTTP 429/503), delay acceptance, or cap the queue. It trades a few fast failures for keeping the rest healthy.

## Technical depth
- In LLM serving: admission limits (`max_num_seqs`), bounded waiting queues, rejecting requests that can never fit (`max-model-len`), timeouts.
- **Trade-off under a grader:** rejecting a request makes it non-useful (zero credit) but may save other requests from missing SLOs. Whether this is net-positive depends on the scoring rules — and deliberately dropping requests may be considered gaming. Check the rules.
- Overload without backpressure → queueing delay grows → TTFT for *all* subsequent requests explodes (queueing collapse).
- Under bursty open-loop load, short bursts can be absorbed by queues; sustained overload cannot.

## Backend-engineer analogy
Load shedding, rate limiting, bounded queues, circuit breakers — standard tools for staying healthy under overload.

## Why it matters for GreenMind
During peak load phases, understanding whether the server is overloaded (arrival rate > service rate) helps you decide between scaling efficiency (better batching) and controlling queue growth.

## Common mistakes
- Unbounded queues that make every request late during a burst.
- Shedding load in ways the grader penalizes more than lateness.

## Related concepts
[Queueing](67_Queueing.md) · [Cancellation and Timeouts](71_Cancellation_and_Timeouts.md) · [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md) · [Useful Requests](12_Useful_Requests.md)

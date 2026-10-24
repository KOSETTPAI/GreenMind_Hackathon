# 71. Cancellation and Timeouts

**Stage:** 3 | **Priority:** Should know | **Prerequisites:** [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)

## In one sentence
Timeouts end requests that take too long, and cancellation stops server-side work when the client disconnects — both decide whether wasted GPU work keeps consuming energy.

## Plain-English explanation
If the grader gives up on a request after N seconds, any tokens the server still generates for it are pure waste: they burn energy, occupy batch slots, and slow everyone else. A well-behaved server notices the client disconnect and aborts the sequence immediately.

## Technical depth
- vLLM aborts a request when the HTTP client disconnects (for streaming responses the disconnect is detected on the next write).
- Client-side: grader timeout settings, retry policy (does it retry? does a retry count as a new request?).
- Server-side limits: `max_tokens`, `max-model-len`; some deployments add request-level timeouts.
- Verify with a test: start a long generation, kill the client, check `/metrics` running count and GPU activity drop.
- Retries under overload can amplify load (retry storms).

## Backend-engineer analogy
Context cancellation propagation (Go `context.Context`, gRPC deadlines) — without it, abandoned requests keep consuming backend resources.

## Why it matters for GreenMind
Timed-out requests are not useful but still cost joules unless cancelled. Understand the grader's timeout and retry behavior and make sure aborts propagate.

## Common mistakes
- Assuming disconnects automatically stop generation in every engine/proxy setup.
- Placing a proxy in front of the engine that hides client disconnects.

## Related concepts
[Backpressure](59_Backpressure.md) · [Useful Requests](12_Useful_Requests.md) · [Energy per Useful Request](121_Energy_per_Useful_Request.md) · [OpenAI-Compatible API](72_OpenAI_Compatible_API.md)

# 12. Useful Requests (Useful Work)

**Stage:** 0 / 9 | **Priority:** Must know | **Prerequisites:** [SLO](11_SLO.md)

## In one sentence
A "useful" request is one that satisfies all the grader's qualifying conditions — the briefing reportedly lists five — and only useful requests count toward throughput and energy-efficiency scores.

## Plain-English explanation
The grader doesn't reward "work done," it rewards "work that was good enough." A response that was too slow, malformed, wrong, or errored is effectively wasted energy. The official five conditions are **not** in the supplied material; plausible candidates include:
1. Request completed without error.
2. TTFT within limit.
3. TPOT within limit.
4. Response format valid (streaming chunks, tool-call schema).
5. Content correct / accuracy criteria met.

**These are guesses — fill in the real five from the briefing.**

## Technical depth
- **Useful throughput** = `N_useful / window_duration`.
- **Energy per useful request** = `E_J / N_useful`. Failed requests still consume energy but add nothing to the denominator — so they hurt twice.
- **Useful requests per joule** = `N_useful / E_J`.
- Edge cases to clarify: retries, cancellations, boundary equality (`≤` vs `<`), one-token outputs for TPOT.

## Backend-engineer analogy
Like counting only successful, on-time, schema-valid API responses as "served" for billing purposes — 5xx and timeouts don't count, but you still paid for the compute.

## Why it matters for GreenMind
This definition is the denominator of the energy metric and the numerator of throughput. It turns latency SLOs into energy and throughput consequences.

## Common mistakes
- Using total completed requests instead of useful requests.
- Assuming partial credit for late requests.

## Related concepts
[Energy per Useful Request](121_Energy_per_Useful_Request.md) · [SLO](11_SLO.md) · [Tool Calling](73_Tool_Calling.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md)

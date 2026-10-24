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

**Confirmed:** the energy score counts **SLO-met requests**. Efficiency is `η = SLO-met requests / J`, with baseline `η_base = 0.00154` and full marks at 3× (`0.00462`).

## Technical depth
- **Useful throughput** = `N_useful / window_duration`.
- **Energy efficiency (scored)** = `η = N_SLO-met / E_J`. Baseline is 0.00154 (≈ 649 J per SLO-met request). Failed requests still consume energy but add nothing to the numerator, so they hurt twice.
- **Energy per SLO-met request** = `E_J / N_SLO-met = 1/η`.
- Example: anywhere between baseline and 3×, losing 50 SLO-met requests out of 1,000 lowers η by 5%, which costs about 0.05 of `s_E` on the log curve (`ln 0.95 / ln 3`). That's before counting any extra energy those failures used.
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

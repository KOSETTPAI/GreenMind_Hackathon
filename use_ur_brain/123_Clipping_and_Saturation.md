# 123. Clipping and Saturation

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Continuous Score Components](3_Continuous_Score_Components.md)

## In one sentence
Clipping caps a score at a minimum and/or maximum value; saturation means improvements beyond a point earn no additional score.

## Plain-English explanation
If the energy score is clipped to [0, 1] and you're already at 1.0, cutting energy further earns nothing — spend effort elsewhere. If you're at 0 (worse than some floor), small improvements also earn nothing until you cross the floor.

## Technical depth
- `s = min(max(raw, lo), hi)` — e.g., `clip(raw, 0, 1)`.
- Saturation points create **flat regions** in the score landscape: zero marginal reward.
- **Energy score (confirmed constants):** `η_base = 0.00154` SLO-met req/J and `K = 3`. With the inferred log form `s_E = clip(ln(η/η_base) / ln 3, 0, 1)`:
  - **Floor:** `η ≤ 0.00154` (≥ 649 J per SLO-met request) gives `s_E = 0`, assuming below-baseline values clip to 0 (confirm).
  - **Saturation:** `η ≥ 0.00462` (≤ 216 J per SLO-met request) gives `s_E = 1`. Further energy savings earn nothing.
  - Between the two, the slope is steepest near baseline and flattens as you approach 3×.
- Strategy: compute each component's position relative to its clip bounds; invest in components with the steepest remaining slope.
- Clarify: are bounds inclusive? Is clipping applied before or after weighting/rounding?

## Backend-engineer analogy
SLO error budgets: once you're comfortably within the target, extra reliability work doesn't change the outcome — move effort to the metric that's failing.

## Why it matters for GreenMind
The energy score saturates at 3× baseline efficiency (0.00462 SLO-met req/J). Once your measured η clears that with a margin for run-to-run noise, stop spending effort on energy and move to throughput, latency, or accuracy. Other components may have their own bounds; check the briefing.

## Common mistakes
- Optimizing an already-saturated component.
- Assuming the shape without the official formula.

## Related concepts
[Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Continuous Score Components](3_Continuous_Score_Components.md)

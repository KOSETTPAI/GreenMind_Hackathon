# 123. Clipping and Saturation

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Continuous Score Components](3_Continuous_Score_Components.md)

## In one sentence
Clipping caps a score at a minimum and/or maximum value; saturation means improvements beyond a point earn no additional score.

## Plain-English explanation
If the energy score is clipped to [0, 1] and you're already at 1.0, cutting energy further earns nothing — spend effort elsewhere. If you're at 0 (worse than some floor), small improvements also earn nothing until you cross the floor.

## Technical depth
- `s = min(max(raw, lo), hi)` — e.g., `clip(raw, 0, 1)`.
- Saturation points create **flat regions** in the score landscape: zero marginal reward.
- Combined with log scales: `s_E = clip(log(E_ref / E) / log(k), 0, 1)` (illustrative only) — saturates when `E ≤ E_ref / k`.
- Strategy: compute each component's position relative to its clip bounds; invest in components with the steepest remaining slope.
- Clarify: are bounds inclusive? Is clipping applied before or after weighting/rounding?

## Backend-engineer analogy
SLO error budgets: once you're comfortably within the target, extra reliability work doesn't change the outcome — move effort to the metric that's failing.

## Why it matters for GreenMind
The briefing reportedly includes clipping and saturation in the energy score (and perhaps others). Knowing the bounds prevents wasted effort.

## Common mistakes
- Optimizing an already-saturated component.
- Assuming the shape without the official formula.

## Related concepts
[Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Continuous Score Components](3_Continuous_Score_Components.md)

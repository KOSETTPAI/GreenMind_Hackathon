# 3. Continuous Score Components

**Stage:** 0 — Understand the evaluator | **Priority:** Must know | **Prerequisites:** [Hard Gates](2_Hard_Gates_and_Eligibility.md)

## In one sentence
A continuous score component rewards improvement gradually (e.g., less energy → higher energy score), usually within a bounded range.

## Plain-English explanation
Once you've passed the gates, the remaining score is a set of dials: energy, throughput, latency, accuracy factor. Turning a dial a little moves the score a little. But dials often have **limits**: below some value you get zero, above some value you get the maximum (clipping/saturation), and some are on a **logarithmic** scale so each halving of energy is worth the same amount.

## Technical depth
- **Energy score (confirmed constants):** efficiency `η = SLO-met requests / J`, with baseline `η_base = 0.00154` and full marks at `K = 3×` baseline (`η ≥ 0.00462`). The inferred logarithmic form is `s_E = clip(ln(η/η_base) / ln 3, 0, 1)`; confirm the exact expression in the briefing. See [Energy per Useful Request](121_Energy_per_Useful_Request.md).
- Other components (throughput, latency) may use linear normalization `s = x / x_ref` with clipping. Those formulas are still unknown.
- Components are often combined by a weighted sum or a product with an accuracy factor, e.g. `S = A × (w_E s_E + w_T s_T + w_L s_L)`. This is illustrative; the weights are unknown.
- **Saturation** means that beyond a point, more improvement earns nothing. For energy that point is 3× baseline efficiency: stop investing there and move to another component.
- On the log energy curve, every multiplicative gain is worth the same: 1× → 1.5× efficiency earns about 0.37 of the component, and 2× → 3× earns the same 0.37.

## Backend-engineer analogy
Like a cost/performance dashboard where some KPIs have target bands: below target you're penalized, above target you get no bonus. Effort should go to the KPI with the steepest marginal gain.

## Why it matters for GreenMind
The energy score is logarithmic with confirmed constants (`η_base = 0.00154` SLO-met req/J, saturating at 3×), and there are also throughput and latency component scores. Knowing the curve shape tells you where marginal effort pays off: early energy gains are cheap, and anything beyond 3× is wasted.

## Common mistakes
- Optimizing a component that is already saturated.
- Assuming linear reward when it's logarithmic (or vice versa).
- Forgetting that a multiplicative accuracy factor can wipe out gains elsewhere.

## Related concepts
[Clipping and Saturation](123_Clipping_and_Saturation.md) · [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Baseline](4_Baseline.md)

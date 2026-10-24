# 3. Continuous Score Components

**Stage:** 0 — Understand the evaluator | **Priority:** Must know | **Prerequisites:** [Hard Gates](2_Hard_Gates_and_Eligibility.md)

## In one sentence
A continuous score component rewards improvement gradually (e.g., less energy → higher energy score), usually within a bounded range.

## Plain-English explanation
Once you've passed the gates, the remaining score is a set of dials: energy, throughput, latency, accuracy factor. Turning a dial a little moves the score a little. But dials often have **limits**: below some value you get zero, above some value you get the maximum (clipping/saturation), and some are on a **logarithmic** scale so each halving of energy is worth the same amount.

## Technical depth
- Typical shapes: linear normalized `s = x / x_ref`, logarithmic `s = log(E_base / E) / log(k)`, clipped `s = clip(s, 0, 1)`. These are **illustrations only** — the real formulas come from the briefing.
- Components are often combined by a weighted sum or a product with an accuracy factor: e.g. `S = A × (w_E s_E + w_T s_T + w_L s_L)`. Again: illustrative.
- **Saturation** means beyond a point, more improvement earns nothing — stop investing there and move to another component.
- With a log energy score, going from 20 kJ → 10 kJ earns the same as 10 kJ → 5 kJ.

## Backend-engineer analogy
Like a cost/performance dashboard where some KPIs have target bands: below target you're penalized, above target you get no bonus. Effort should go to the KPI with the steepest marginal gain.

## Why it matters for GreenMind
The briefing reportedly has a logarithmic energy score with baseline, clipping, and saturation, plus throughput and latency component scores. Knowing the curve shape tells you where marginal effort pays off.

## Common mistakes
- Optimizing a component that is already saturated.
- Assuming linear reward when it's logarithmic (or vice versa).
- Forgetting that a multiplicative accuracy factor can wipe out gains elsewhere.

## Related concepts
[Clipping and Saturation](123_Clipping_and_Saturation.md) · [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Score-Aware Decisions](125_Score_Aware_Decisions.md) · [Baseline](4_Baseline.md)

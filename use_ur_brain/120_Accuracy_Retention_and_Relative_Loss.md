# 120. Accuracy Retention and Relative Accuracy Loss

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md), [Baseline](4_Baseline.md)

## In one sentence
Accuracy retention compares your candidate's accuracy to the baseline's (often as a ratio), and relative loss is how much was lost as a fraction of the baseline.

## Plain-English explanation
If the BF16 baseline scores 80% and your quantized server scores 78%, you kept 97.5% of the baseline accuracy (retention) and lost 2.5% relative (loss). The briefing reportedly has an accuracy-retention cutoff — fall below it and you're likely disqualified or heavily penalized.

## Technical depth
- `Retention = Acc_candidate / Acc_base` (if defined this way).
- `Loss_rel = (Acc_base − Acc_candidate) / Acc_base`, for `Acc_base > 0`.
- **Absolute** loss = `Acc_base − Acc_candidate` (percentage points) — different number! 80% → 78% = 2 points absolute, 2.5% relative.
- May use macro accuracy instead of micro.
- An **accuracy factor A** in the final score may be derived from retention (with floors/thresholds/clipping) — unknown until the official formula is supplied.
- Noise: accuracy itself varies run to run (numerics, batching) — measure the baseline's own variation before declaring a regression.

## Backend-engineer analogy
A regression budget: "no more than X% degradation vs the previous release" in quality metrics.

## Why it matters for GreenMind
This is the main constraint on quantization, speculative decoding, engine swaps, and anything that alters numerics. Keep a margin from the cutoff.

## Common mistakes
- Mixing up absolute and relative loss.
- Assuming the formula without reading the briefing.

## Related concepts
[Hard Gates](2_Hard_Gates_and_Eligibility.md) · [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Quantization](102_Quantization.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md)

# 120. Accuracy Retention and Relative Accuracy Loss

**Stage:** 9 | **Priority:** Must know | **Prerequisites:** [Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md), [Baseline](4_Baseline.md)

## In one sentence
Accuracy retention compares your candidate's macro-accuracy to the confirmed reference macro-accuracy of **87.2%**, and relative loss is how much was lost as a fraction of that reference.

## Confirmed scoring constant
**Reference macro-accuracy = 87.2%.** This is the denominator for retention. The retention **cutoff** and the way retention maps to the accuracy factor `A` are still unknown.

## Plain-English explanation
If your quantized server scores 85.0% macro-accuracy, you kept `85.0 / 87.2 = 97.5%` of the reference (retention) and lost 2.5% relative. The briefing has an accuracy-retention cutoff: fall below it and you're likely disqualified or heavily penalized.

## Technical depth
- `Retention = MacroAcc_candidate / 0.872`.
- `Loss_rel = (0.872 − MacroAcc_candidate) / 0.872`.
- **Absolute loss** = `87.2 − MacroAcc_candidate` in percentage points, which is a different number. 87.2% → 85.0% is 2.2 points absolute but 2.5% relative.
- **Rule of thumb:** each 1 point of macro-accuracy lost costs about 1.15% of retention (`1 / 87.2`).

Macro-accuracy needed for common retention levels (the actual cutoff is still unknown):

| Retention | Minimum macro-accuracy | Allowed absolute drop |
|---:|---:|---:|
| 99% | 86.33% | 0.87 pt |
| 98% | 85.46% | 1.74 pt |
| 97% | 84.58% | 2.62 pt |
| 95% | 82.84% | 4.36 pt |
| 90% | 78.48% | 8.72 pt |

- The reference is a **macro** average, so compute your candidate's accuracy the same way: the unweighted mean of per-category accuracies, not total correct / total items.
- **Check your own baseline:** your reproduced BF16 run should land close to 87.2%. If it's noticeably off, find out why (judge, normalization, dataset version, template, sampling) before trusting any retention numbers.
- **Noise:** accuracy itself varies run to run (numerics, batching). Measure that spread and keep a margin above the cutoff that is larger than it.

## Backend-engineer analogy
A regression budget against a fixed reference release: "quality must stay within X% of 87.2%."

## Why it matters for GreenMind
This is the main constraint on quantization, speculative decoding, engine swaps, and anything else that alters numerics. Once the cutoff is known, the table above tells you exactly how many accuracy points you can afford to lose.

## Common mistakes
- Computing micro accuracy and comparing it to the 87.2% macro reference.
- Mixing up absolute and relative loss.
- Assuming the cutoff or the formula for `A` without reading the briefing.

## Related concepts
[Per-Class and Macro Accuracy](119_Per_Class_and_Macro_Accuracy.md) · [Hard Gates](2_Hard_Gates_and_Eligibility.md) · [Score Symbols](124_Score_Symbols_A_sE_sT_sL_S.md) · [Quantization](102_Quantization.md) · [Run-to-Run Variance](91_Run_to_Run_Variance.md)

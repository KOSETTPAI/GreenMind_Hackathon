# Hackathon Evaluation Test --- Scoring Criteria

## 1. Overview

The hackathon uses a live ranking of submissions based on one technical
scoring formula:

\[ S = 100 `\cdot `{=tex}A `\cdot `{=tex}s_E\^{0.6}
`\cdot `{=tex}s_T\^{0.2} `\cdot `{=tex}s_L\^{0.2} \]

Where: - `S` --- technical score. - `A` --- accuracy factor. - `sE` ---
energy score. - `sT` --- throughput score. - `sL` --- latency score.

The factors are multiplied, not added. Accuracy acts as a soft factor;
energy has the largest exponent. Throughput and latency scores saturate
at `1`.

## 2. Evaluation tracks

  ------------------------------------------------------------------------
  Track                         Requests Purpose          Counts toward
                                                          graded result?
  ---------------- --------------------- ---------------- ----------------
  Validation                         100 Practice and     No
                                         iteration; score 
                                         is indicative    
                                         only             

  Final Test                         300 One graded       **Yes --- only
                                         evaluation round Final counts**
  ------------------------------------------------------------------------

-   Each evaluation round is capped at **30 minutes**.
-   Requests unfinished when the 30-minute cap is reached count as
    failed.
-   The Final Test is the only graded result.

## 3. Baseline and energy target

The baseline is the **untuned model served with default vLLM in BF16**.

  Parameter                                  Final Test baseline stated in the evaluation header
  ---------------------------------------- -----------------------------------------------------
  Baseline energy efficiency (`η_base`)                             `0.00163` SLO-met requests/J
  Energy multiplier for full marks (`K`)                                `3×` baseline efficiency
  Reference macro-accuracy                                                               `87.8%`

Energy efficiency is defined as:

\[ `\eta `{=tex}=
`\frac{\text{SLO-met requests}}{\text{GPU energy in joules}}`{=tex} \]

-   Energy is measured using the **NVML counter**.
-   Idle energy is included.
-   The energy score is measured relative to the untuned baseline.
-   Full energy marks are reached at `3×` baseline efficiency.

The energy scoring formula is:

\[ s_E = `\operatorname{clip}`{=tex}`\left`{=tex}(
`\frac{\ln(\eta / \eta_{\text{base}})}{\ln K}`{=tex}, 0, 1
`\right`{=tex}), `\quad `{=tex}K = 3 \]

Here, `clip(x, 0, 1)` limits the result to the interval from 0 to 1.

    Efficiency relative to baseline   Energy score (`sE`)
  --------------------------------- ---------------------
                            `1.00×`                `0.00`
                            `1.25×`                `0.20`
                            `1.50×`                `0.37`
                            `2.00×`                `0.63`
                            `2.50×`                `0.83`
                  `3.00×` or higher                `1.00`

## 4. Accuracy factor (`A`)

Accuracy is a **soft scoring factor**: - Full accuracy credit is given
at **98% accuracy retention** relative to the baseline. - Below 98%
retention, the factor fades smoothly. - The accuracy factor is described
as **never exactly zero**.

Reference macro-accuracy for the Final Test header: **87.8%**.

Accuracy retention is relative to the baseline, not simply the raw
percentage-point difference. The supplied evaluation description does
not provide the complete implemented equation for `A`; do not infer
unprovided thresholds or class-level penalties from this file alone.

## 5. Throughput score (`sT`)

-   Throughput is an SLO-related component of the overall score.
-   It saturates at `1`.
-   The supplied evaluation description does not provide the full
    implementation formula or exact thresholds for `sT`.

## 6. Latency score (`sL`)

-   Latency is an SLO-related component of the overall score.
-   It saturates at `1`.
-   The supplied evaluation description does not provide the full
    implementation formula or exact thresholds for `sL`.

## 7. Scoring interpretation

\[ S = 100 `\cdot `{=tex}A `\cdot `{=tex}s_E\^{0.6}
`\cdot `{=tex}s_T\^{0.2} `\cdot `{=tex}s_L\^{0.2} \]

Practical implications: 1. **Energy has the largest weight** through the
exponent `0.6`. 2. **Accuracy matters multiplicatively**; a lower
accuracy factor reduces the entire score. 3. **Throughput and latency
saturate at 1**. Improving them beyond their scoring ceiling does not
directly increase their factors. 4. Requests unfinished at the 30-minute
cap count as failed. 5. Energy includes idle consumption, so measure the
full evaluation window rather than only active generation.

## 8. Baseline discrepancy to verify

The supplied evaluation text contains **two different baseline sets**:

  -----------------------------------------------------------------------
  Source text                          `η_base`  Reference macro-accuracy
  ------------------- ------------------------- -------------------------
  "Final Test"                `0.00163` SLO-met                   `87.8%`
  baseline header                    requests/J 

  Separate Validation         `0.00154` SLO-met                   `87.2%`
  / Final Test                       requests/J 
  description                                   
  -----------------------------------------------------------------------

Both state `K = 3×` for full energy marks. These baseline values
conflict and should **not** be silently treated as equivalent. Confirm
the active baseline values in the live grader or with the organizers
before calculating expected scores.

## 9. Known details vs. unspecified details

### Specified in the supplied evaluation description

-   Overall score formula and exponents.
-   Validation: 100 requests, indicative only.
-   Final Test: 300 requests, only graded result.
-   30-minute cap per round; unfinished requests fail.
-   Energy efficiency: SLO-met requests per joule, NVML counter, idle
    included.
-   Energy target: `K = 3×` baseline efficiency.
-   Accuracy receives full credit at 98% retention and fades smoothly
    below it.
-   Throughput and latency factors saturate at 1.

### Not fully specified in the supplied description

-   The exact implemented accuracy-factor equation below 98% retention.
-   Exact throughput and latency formulas and thresholds.
-   Whether any additional per-class accuracy rules apply.
-   Which of the two stated baseline sets is active in the grader.

Use the live grader's detailed specification or organizer clarification
for these unresolved details.

------------------------------------------------------------------------

**Document purpose:** A compact reference for the hackathon's evaluation
tracks, baseline, scoring formula, and criteria, based only on the
supplied evaluation description.

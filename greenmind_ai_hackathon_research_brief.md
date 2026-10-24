# GreenMind AI Hackathon --- Research Brief

**Research date:** October 24, 2026\
**Competition dates:** October 24--25, 2026\
**Primary source for event-specific scoring/rules:** User-provided
GreenMind hackathon briefing\
**External sources:** Official CMKL event page, official MANGO model
card, official Qwen model card, vLLM documentation, NVIDIA GPU
performance guide.

> **Source discipline:** Event-specific technical rules and scoring
> formulas below are transcribed from the supplied briefing. External
> technical notes are identified separately. If the briefing and
> external documentation differ, verify competition requirements with
> the organizers; the grader's contract takes precedence for the
> competition.

## 1. Executive summary

GreenMind is a sustainable LLM inference optimization competition. The
goal is to serve correct answers on time while minimizing GPU energy
consumption---not simply to maximize raw tokens per second.

The challenge is to optimize a local inference server for the
organizer-provided **CMKL/MANGO1.5-Qwen3.5-9B** model or a permitted
derivative. The endpoint must satisfy an OpenAI-compatible
chat-completions contract, including streaming and tool calling.

The technical score combines: - **Accuracy retention** as a
multiplicative gate. - **Energy efficiency** (largest
exponent/weight). - **Peak-phase throughput**. - **Tail latency** (p95
TTFT and TPOT).

The final competition ranking combines Round 1 technical score (40%) and
Round 2 pitch score (60%). The top eight teams advance to the pitch
round.

## 2. Official event information

According to the [official CMKL University event
page](https://cmkl.ac.th/news-events/can-you-make-ai-faster-while-using-less-energy):

-   **Event:** GreenMind AI Hackathon --- "Can you make AI faster while
    using less energy?"
-   **Dates:** October 24--25, 2026.
-   **Format:** In person.
-   **Venue:** 3rd Floor, King Mongkut Chaokhunthahan Hospital (KMCH),
    Bangkok.
-   **Hosts/collaborators:** CMKL University, ExxonMobil Thailand, and
    the AIEI network.
-   **Eligibility stated on the page:** University students; teams of
    3--5.
-   **Registration period shown:** August 20--October 2, 2026.
-   **Prizes advertised:** Prizes worth up to THB 10,000, a CMKL
    University application fee waiver, and a participation certificate.
-   **Event language:** Thai.
-   Participants are asked to bring their own laptops.

Links: - Official event announcement:
https://cmkl.ac.th/news-events/can-you-make-ai-faster-while-using-less-energy -
Event registration link is linked from the official page; registration
period listed above has passed as of the research date. - Event Discord
provided in the briefing: https://discord.gg/Wvy2SwZxKh

## 3. Model and hardware

### 3.1 Competition model

The briefing identifies: - **Baseline:** `CMKL/MANGO1.5-Qwen3.5-9B` in
BF16, served using default `vllm serve`. - **Provided optimization
candidate:** `CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp`, described in the
briefing as a quantized variant with a multi-token-prediction head. -
**Architecture:** Hybrid Mamba / Gated-DeltaNet. The briefing says only
about 8 of 32 layers use a conventional KV cache, so long-context memory
behavior differs from a plain Transformer.

Official model card: https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B\
Model files: https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B/tree/main\
Base Qwen model card: https://huggingface.co/Qwen/Qwen3.5-9B

### 3.2 External model-card context

The official MANGO model card describes MANGO1.5-Qwen3.5-9B as: - A
dense 9B-parameter Thai/English bilingual fine-tune of Qwen3.5-9B. -
Text-only instruction fine-tuning, despite the base architecture's
broader multimodal capabilities. - Trained using LoRA supervised
fine-tuning; the published checkpoint has the adapter merged into the
base weights. - Based on a reported 5-million-sample English/Thai
instruction corpus. - Licensed under Apache 2.0 according to the model
card.

The Qwen3.5-9B model card describes a 32-layer hybrid architecture
combining Gated DeltaNet and gated attention blocks, and documents
native context length and model details. These model-card statements are
useful background, **not additional competition rules**. Always check
the exact checkpoint/configuration supplied by organizers before
assuming a feature is available in the hackathon build.

### 3.3 Hardware environment from the briefing

  Resource   Specification
  ---------- ---------------------------------------------------------------
  GPU        1 × NVIDIA A100-SXM4 40 GB, dedicated via PCI passthrough
  CPU        16 vCPU, AMD EPYC 7742
  RAM        48 GB (about 47 GiB usable)
  Disk       About 145 GB root disk; approximately 110 GB free at hand-out
  OS         Ubuntu 24.04 LTS
  Driver     NVIDIA driver 580
  Runtime    Docker

Every team receives the same stated hardware environment to support
comparable results.

## 4. Hidden evaluation workload

The final test track contains **300 requests**, divided as follows:

  Workload class               Requests
  -------------------------- ----------
  Chat / instructions                90
  RAG / long documents               60
  Agentic tool calling               60
  Reasoning, math, code              45
  Thai                               30
  Long context (up to 32K)           15
  **Total**                     **300**

Load shape: 1. **Ramp:** arrival rate increases from 0 to 4
requests/second. 2. **Peak:** constant 4 requests/second. 3. **Quiet:**
1 request/second.

Other test details from the briefing: - Open-loop load: requests arrive
on schedule regardless of whether earlier requests have completed. -
Thinking mode is enabled. - `max_tokens = 8192`. - `temperature = 0`. -
Some multi-turn tool-calling episodes can reach 15 turns.

**Implication:** Short-prompt microbenchmarks are not enough. Test long
prompts, mixed classes, streaming, sustained peak load, tail latency,
and energy over the full run.

## 5. Evaluation rounds and final ranking

### Round 1 --- automated technical evaluation (40%)

The grader replays a hidden trace against the team's endpoint and
calculates technical score `S`. The top eight teams, ranked by best
final score, advance. Ties are broken by higher accuracy retention, then
lower p95 TTFT.

### Round 2 --- pitch (60%)

-   7-minute presentation.
-   7-minute Q&A with the judging panel.
-   Both rounds are scored on a 0--100 scale.
-   Teams outside the top eight do not pitch and do not appear in final
    standings.

Final formula:

\[ F = 0.4 `\times `{=tex}R_1 + 0.6 `\times `{=tex}R_2 \]

Where: - `F` = final score. - `R1` = Round 1 technical score. - `R2` =
Round 2 pitch score.

### Pitch rubric

  ------------------------------------------------------------------------
  Criterion                                   Weight What judges assess
  --------------------- ---------------------------- ---------------------
  Technical approach                             40% Why the approach
  and trade-offs                                     worked, what was
                                                     sacrificed, and which
                                                     experiments failed

  Sustainability impact                          40% Whether the energy
                                                     gains matter beyond
                                                     the leaderboard and
                                                     hold up at production
                                                     scale

  Clarity and delivery                           20% Time management,
                                                     clear baseline
                                                     comparisons, results,
                                                     and Q&A
  ------------------------------------------------------------------------

Before pitching, teams are asked to submit: - GitHub link to
experiments, serving commands, configurations, code, results, and
explanations of failed attempts. - Presentation slides as a PDF. -
Hugging Face links for every optimized weight used, or a statement that
only original weights were used.

## 6. Five SLO conditions for useful work

A request counts as useful work only when **all five** conditions pass:

1.  The response is streamed, allowing TTFT to be observed.
2.  There is no error or timeout; the stated timeout is 900 seconds.
3.  The response is not cut off at the 8,192-token limit.
4.  TTFT is within its prompt-length-dependent SLO.
5.  TPOT is at most 50 ms; this condition is skipped for one-token
    answers.

The TTFT threshold is:

\[ TTFT\_{`\mathrm{SLO}`{=tex}} = 0.5 + 0.25
`\times `{=tex}`\frac{P}{1000}`{=tex} `\text{seconds}`{=tex} \]

where `P` is the number of prompt tokens.

    Prompt length   TTFT SLO
  --------------- ----------
       300 tokens    0.575 s
     6,000 tokens      2.0 s
    20,000 tokens      5.5 s

Late, failed, and cut-off requests still consume energy but contribute
no useful work. A server that returns quickly but violates accuracy,
completion, or latency requirements can score poorly.

## 7. Round 1 technical scoring

The briefing gives this formula:

\[ S = 100 `\cdot `{=tex}A `\cdot `{=tex}s_E\^{0.6}
`\cdot `{=tex}s_T\^{0.2} `\cdot `{=tex}s_L\^{0.2} \]

Where: - `S` = technical score. - `A` = accuracy factor, ranging from
0.05 to 1 in the briefing. - `sE` = energy score. - `sT` = throughput
score. - `sL` = latency score.

The factors multiply. Accuracy acts as a gate; energy carries the
largest exponent. Speed is valuable when it improves SLO compliance or
energy per useful request, but raw speed alone is not the objective.

### 7.1 Accuracy factor `A`

First calculate relative macro-accuracy:

\[ R =
`\frac{\text{your macro-accuracy}}{\text{baseline macro-accuracy}}`{=tex}
\]

Then:

\[ x =
`\operatorname{clip}`{=tex}`\left`{=tex}(`\frac{R - 0.85}{0.13}`{=tex},
0, 1`\right`{=tex}) \]

\[ `\operatorname{smoothstep}`{=tex}(x) = 3x\^2 - 2x\^3 \]

\[ A = `\max`{=tex}(0.05, `\operatorname{smoothstep}`{=tex}(x)
`\times `{=tex}c_f) \]

The weakest class can apply an additional factor:

\[ c_f = `\operatorname{smoothstep}`{=tex}`\left`{=tex}(
`\operatorname{clip}`{=tex}`\left`{=tex}(`\frac{c - 0.50}{0.25}`{=tex},
0, 1`\right`{=tex}) `\right`{=tex}) \]

Where: - `R` = your macro-accuracy divided by baseline macro-accuracy,
averaged over the six classes. - `c` = weakest class's accuracy divided
by baseline accuracy for that class. - `clip(z, 0, 1)` clamps a value to
the range 0--1. - `smoothstep(x) = 3x² − 2x³` is a smooth transition
from 0 to 1.

Rules/interpretation in the briefing: - `R >= 0.98` gives `A = 1` before
class penalties. - `R <= 0.85` reaches the accuracy-factor floor of
`0.05`. - A class with at least 20 questions and less than 75% of its
baseline accuracy applies a class penalty. - The class factor falls from
1 at 75% retention to 0 at 50% retention. - Example: weakest class
retention of 62.5% makes the class factor 0.5. - Beating baseline
accuracy does not provide extra credit.

**Source ambiguity to verify:** The briefing describes an accuracy floor
of 0.05 while also describing a class factor reaching zero at 50%.
Confirm with organizers exactly how the floor and class factor interact
in the grader implementation, and how classes with fewer than 20
questions are treated.

### 7.2 Energy score `sE`

Energy efficiency is on-time requests per GPU joule:

\[ `\eta `{=tex}=
`\frac{\text{SLO-passing requests}}{\text{total GPU joules}}`{=tex} \]

The briefing's score formula is:

\[ s_E = `\operatorname{clip}`{=tex}`\left`{=tex}(
`\frac{\ln(\eta/\eta_{\mathrm{baseline}})}{\ln K}`{=tex}, 0, 1
`\right`{=tex}) \]

with `K = 3` for both Validation and Final.

Interpretation: - Efficiency is measured across the whole timed window,
including idle gaps and drain. - The score is logarithmic: each doubling
of efficiency adds the same amount on the logarithmic scale. - Three
times baseline efficiency reaches full energy marks. - Failed or late
requests still burn energy but do not add useful work.

    Efficiency relative to baseline   Energy score
  --------------------------------- --------------
                              1.00×           0.00
                              1.25×           0.20
                              1.50×           0.37
                              2.00×           0.63
                              2.50×           0.83
                              3.00×           1.00

**Scoring edge case:** The briefing says the untuned baseline scores
`S = 0` by definition. The displayed energy formula also returns zero at
baseline efficiency. Confirm whether any baseline-specific handling
exists beyond this formula.

### 7.3 Throughput score `sT`

\[ s_T = `\frac{\text{peak-phase requests that passed SLO}}`{=tex}
{`\text{peak-phase requests that arrived}`{=tex}} \]

-   Only the constant high-rate peak phase counts.
-   Late, failed, or cut-off requests count as not served.
-   Throughput score saturates at 1.0 when all peak requests pass SLO.

### 7.4 Latency score `sL`

\[ s_L = `\sqrt{s_{L,TTFT} \times s_{L,TPOT}}`{=tex} \]

\[ s\_{L,TTFT} =
`\min`{=tex}`\left`{=tex}(1,`\frac{1}{p95(TTFT/TTFT_{\mathrm{SLO}})}`{=tex}`\right`{=tex})
\]

\[ s\_{L,TPOT} =
`\min`{=tex}`\left`{=tex}(1,`\frac{50\text{ ms}}{p95(TPOT)}`{=tex}`\right`{=tex})
\]

-   `p95` is the 95th percentile: the slowest 5% of requests influence
    the tail metric.
-   TTFT is normalized by each request's own TTFT SLO.
-   TPOT target is 50 ms.
-   Geometric mean combines the two sub-scores.
-   Inside target limits, further speed gains do not directly raise the
    latency score; they may still reduce energy consumption.

## 8. Validation and Final submissions

  Property                                 Validation                Final
  ------------------ -------------------------------- --------------------
  Requests                                        100                  300
  Submission limit                         5 per hour           2 per hour
  Purpose              Practice, iteration, debugging        Graded result
  Ranking impact                      Indicative only   Counts for ranking

-   A track's score is the best **finished** submission.
-   Failed, running, or interrupted submissions are not ranked.
-   Validate stability before using a Final submission.
-   Briefing deadline: Final grader submissions close on **October 25 at
    11:00 AM**.
-   Pitch materials due by **11:30 AM on Day 2 (October 25)**.

These deadlines are copied from the briefing and should be checked
against the live event portal in case organizers change them.

## 9. Rules and constraints

### Model and data

-   Serve `CMKL/MANGO1.5-Qwen3.5-9B` or a model derived from it.
-   Allowed: quantization, pruning, calibration, weight conversion, and
    adding/removing speculative-decoding heads such as MTP.
-   Fine-tuning and distillation are allowed on open data only.
-   Derived weights must be made by the team during the event from the
    official MANGO weights.
-   A speculative draft model may be any open-source model, but must be
    disclosed; its energy counts.
-   Calibration/compression datasets must be open and must not contain
    hidden test questions.

### Software

-   Engines, frameworks, tools, libraries, and datasets must be open
    source.
-   Examples in the briefing: vLLM, SGLang, TensorRT-LLM, llama.cpp, or
    custom kernels.
-   No closed-source binaries, hosted APIs, or proprietary services.
-   Custom kernels, schedulers, and serving code are welcome; source
    must be available to organizers on request.

### Serving contract

-   OpenAI-compatible `/chat/completions` with streaming and token
    usage.
-   Tool calling must work with `tool_choice=auto`.
-   The grader fixes max tokens, temperature, thinking mode, and
    sampling.
-   Serve from the team's own VM and its single GPU.
-   Do not cache graded responses; normal KV and prefix caching are
    allowed.

### Hardware and fair play

-   Fixed power limit or locked clocks are allowed only if held constant
    throughout the run.
-   No settings that apply only during the measured window.
-   No measurement tampering, including `LD_PRELOAD` or replacing the
    NVIDIA management library (`nvml`).
-   One serving process, no other GPU workloads, and no external calls
    during a graded run.
-   No collusion or sharing submissions/credentials; do not reconstruct
    hidden tests or touch other teams' VMs or the grader host.
-   Organizers may rerun submissions and inspect configurations.
    Violations may cause disqualification.

## 10. Submission workflow

The briefing's operational flow:

1.  Start the server and ensure the endpoint is reachable at
    `http://<vm-ip>:<port>/v1`.
2.  Enable streaming, token usage, and tool calling. The briefing
    specifies:
    -   `--enable-auto-tool-choice`
    -   `--tool-call-parser qwen3_coder`
3.  Log into the grader, change the password and display/team name, save
    the endpoint, and select the model.
4.  Start with Validation: run the health check (chat and GPU energy
    counter), submit, and inspect results in History.
5.  Record each experiment and only spend Final submissions on stable
    configurations.

Example baseline command from the official MANGO model card:

``` bash
vllm serve "CMKL/MANGO1.5-Qwen3.5-9B"
```

The official model card also documents a basic OpenAI-compatible request
to `/v1/chat/completions`. The competition may require extra arguments
and a particular software version; use the briefing/grader instructions
rather than assuming the simplest example is sufficient.

## 11. External technical references and what they contribute

This section summarizes external documentation that was fetched during
research. These are technical references, not additional competition
rules.

### 11.1 CMKL official event announcement

https://cmkl.ac.th/news-events/can-you-make-ai-faster-while-using-less-energy

Confirms the event's dates, venue, in-person format, host organizations,
university-student eligibility, team size, model/hardware focus, and
publicly advertised prizes. It describes the goal as optimizing LLM
performance while reducing compute and energy consumption.

### 11.2 Official MANGO model card

https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B

Useful for: - Model architecture and intended use. - License and
training description. - Baseline `vllm serve` example. - SGLang serving
example. - Chat template and model-specific behavior.

Model card baseline example:

``` bash
pip install vllm
vllm serve "CMKL/MANGO1.5-Qwen3.5-9B"
```

The model card's sample client uses
`http://localhost:8000/v1/chat/completions`. The hackathon briefing
specifies its own grader endpoint and may require tool-calling flags.

### 11.3 Qwen3.5-9B model card

https://huggingface.co/Qwen/Qwen3.5-9B

Useful for: - Base-model architecture. - Layer composition and Gated
DeltaNet/gated attention details. - Model configuration and
context-length documentation. - Understanding which properties originate
in Qwen and which are specific to the MANGO fine-tune.

Do not infer that every advertised model-card feature is enabled or
supported in the exact hackathon runtime without testing.

### 11.4 vLLM OpenAI-compatible server documentation

https://docs.vllm.ai/en/latest/serving/online_serving/

Specific endpoint documentation:
https://docs.vllm.ai/en/latest/serving/online_serving/openai_compatible_server/

The docs describe vLLM's HTTP server and supported OpenAI-style APIs,
including `/v1/chat/completions`. They also explain that tool-call
behavior depends on the model and request parameters. This matters
because the grader expects a compatible streaming endpoint and working
tool calls.

Practical checks: - Confirm streaming chunks arrive correctly. - Confirm
the endpoint returns expected token usage. - Verify tool calls are
serialized in the expected format. - Test the exact parser and
auto-tool-choice settings required by the briefing. - Pin the runtime
version and configuration used for every experiment.

### 11.5 vLLM speculative-decoding acceptance metrics

https://docs.vllm.ai/en/latest/features/speculative_decoding/acceptance_metrics/

The docs describe per-request acceptance metrics for speculative
decoding, including mean acceptance length and accepted-draft-length
distribution. The page labels the feature experimental and notes its
output shape may change, so pin a vLLM version if relying on it.

Why it matters: - Speculative decoding is only a useful optimization if
draft tokens are accepted often enough to reduce target-model work. -
Acceptance metrics help explain why a configuration improves or fails to
improve latency. - Measure actual end-to-end SLO and joules; acceptance
statistics alone do not prove a better competition score.

### 11.6 NVIDIA GPU Performance Background User's Guide

https://docs.nvidia.com/deeplearning/performance/dl-performance-gpu-background/

The guide covers: - GPU architecture and execution model. - Streaming
multiprocessors (SMs), on-chip cache, and high-bandwidth memory. -
Parallel execution and arithmetic intensity. - Distinguishing
latency-limited, compute-limited, and memory-limited operations.

A useful diagnostic principle from the guide: estimate arithmetic
intensity (operations per byte moved) and available parallelism to
reason about whether an operation is likely limited by compute, memory
bandwidth, or insufficient parallelism. For the hackathon, use profiling
and repeatable measurements to test the hypothesis rather than guessing
from GPU utilization alone.

## 12. Highest-value experiment priorities

These are **hypotheses to test**, not guaranteed winning optimizations.

### Priority 1 --- Reproduce the baseline

-   Run the official BF16 MANGO baseline.
-   Save exact server command, environment, package versions, model
    revision, and logs.
-   Run the grader health check and a Validation submission.
-   Record accuracy, energy, SLO pass rate, peak throughput, p95 TTFT,
    and p95 TPOT.
-   Repeat enough to identify run-to-run variation.

### Priority 2 --- Quantization (AWQ W4A16)

Hypothesis: lower weight memory traffic and/or improved effective
serving efficiency may reduce energy and improve throughput.

Measure: - Macro-accuracy and per-class retention. - SLO pass rate and
cut-off/error rate. - GPU joules over the complete timed window. - p95
TTFT and TPOT. - Memory use and stability.

Risk: quantization can damage accuracy or introduce runtime/architecture
compatibility issues. Do not infer a win from smaller model files alone.

### Priority 3 --- MTP / speculative decoding

Hypothesis: predicting multiple candidate tokens can reduce the number
of expensive target-model decode steps if enough drafted tokens are
accepted.

Measure: - End-to-end TTFT and TPOT. - Speculative acceptance metrics if
supported. - GPU energy per SLO-passing request. - Accuracy and output
behavior. - Compatibility with the exact model, serving engine, and
grader.

Risk: draft overhead, low acceptance, memory use, or unsupported
architecture paths can erase benefits.

### Priority 4 --- Serving and batching configuration

Hypothesis: scheduling and batching settings may improve peak SLO
compliance and GPU utilization.

Measure: - Peak-phase SLO pass ratio. - Queueing and TTFT under
open-loop load. - p95 TPOT. - GPU joules and utilization. - Errors,
timeouts, and output truncation.

Change one meaningful variable at a time and keep all other conditions
fixed.

### Priority 5 --- Power limits and clocks

Hypothesis: a lower fixed power limit may improve requests per joule if
throughput and SLO compliance remain acceptable.

Measure: - Total GPU joules. - SLO-passing requests. - Peak throughput
and p95 latency. - Full load profile including quiet and drain periods.

Rule: any power limit or clock setting must remain constant throughout
the run. Never change settings only during the measured window.

## 13. Experimental method and decision log

Use a table like this for every run:

  Field                    Record
  ------------------------ ---------------------------------------------------
  Experiment ID            Unique ID and timestamp
  Baseline/configuration   Exact model, engine, flags, and version
  Hypothesis               Expected bottleneck and mechanism
  Single change            What differs from the previous run
  Accuracy                 Macro and per-class results
  SLO                      Useful requests / total; peak SLO pass rate
  Latency                  p95 TTFT normalized to SLO; p95 TPOT
  Energy                   Total GPU joules; SLO-passing requests per joule
  Score                    `A`, `sE`, `sT`, `sL`, `S` if grader exposes them
  Outcome                  Improved, neutral, regressed, invalid
  Explanation              Evidence for why it happened
  Next action              Keep, revert, or test follow-up

Recommended workflow: 1. Make a valid server. 2. Reproduce the BF16
baseline. 3. Check measurement reliability. 4. Diagnose the dominant
failure: accuracy, SLO, throughput, latency, energy, or compatibility.
5. Change one variable. 6. Run Validation. 7. Compare all metrics, not
only one. 8. Keep or revert based on score and reliability. 9. Use Final
only when the configuration is stable. 10. Prepare a concise explanation
of successful and failed experiments for the pitch.

## 14. Common failure modes

-   **Optimizing only tokens/second:** may increase energy or fail
    TTFT/TPOT thresholds.
-   **Optimizing only average latency:** p95 tail latency is scored.
-   **Ignoring class-level accuracy:** a strong average can hide a weak
    class penalty.
-   **Using short prompts only:** long-context requests and RAG behave
    differently.
-   **Ignoring open-loop load:** a server may look good under
    closed-loop tests but build queues when arrivals continue
    independently.
-   **Ignoring idle/drain energy:** the entire timed window counts.
-   **Assuming quantization is always better:** smaller weights do not
    guarantee better accuracy, energy, or score.
-   **Changing several settings together:** makes causal diagnosis
    difficult.
-   **Using an unpinned runtime:** makes results hard to reproduce.
-   **Skipping Validation:** consumes scarce Final submissions on
    unstable configurations.
-   **Treating model-card claims as grader guarantees:** the exact model
    build and grader contract control.

## 15. Questions to verify with organizers

1.  What exact dataset, answer normalization, and metric implementation
    define accuracy?
2.  How does the grader apply the `A >= 0.05` floor when the
    weakest-class factor reaches zero?
3.  How are classes with fewer than 20 questions handled?
4.  Is the baseline's zero score hard-coded, or entirely a consequence
    of the displayed formula?
5.  How exactly is GPU energy sampled, and what are the boundaries of
    the timed window?
6.  What exact vLLM version, model revision, and launch flags are
    expected?
7.  What is the exact streaming and token-usage contract?
8.  Have the October 25 submission and pitch-material deadlines changed?

## 16. Quick reference sheet

  Item                Definition / threshold
  ------------------- -----------------------------------------------------
  Technical score     `S = 100 × A × sE^0.6 × sT^0.2 × sL^0.2`
  Final score         `F = 0.4 × R1 + 0.6 × R2`
  TTFT SLO            `0.5 + 0.25 × prompt_tokens / 1000` seconds
  TPOT SLO            `<= 50 ms`, except one-token answers
  Timeout             900 seconds
  Output cap          8,192 tokens; cut-off requests fail useful-work SLO
  Energy efficiency   SLO-passing requests / total GPU joules
  Energy score        `clip(ln(η/ηbaseline) / ln(3), 0, 1)`
  Throughput score    Peak requests passing SLO / peak requests arrived
  Latency score       `sqrt(sL_TTFT × sL_TPOT)`
  Validation          100 requests; 5 submissions/hour
  Final               300 requests; 2 submissions/hour
  Round weighting     40% technical, 60% pitch
  Pitch               7 minutes + 7 minutes Q&A
  Top teams           Top 8 advance

## 17. Glossary

-   **A100:** NVIDIA data-center GPU used by the competition.
-   **Accuracy retention:** How much of baseline accuracy is preserved.
-   **AWQ:** Activation-aware weight quantization, a method for
    compressing model weights.
-   **BF16:** 16-bit brain floating-point format.
-   **Batching:** Serving multiple requests together to improve hardware
    utilization.
-   **Decode:** Autoregressive phase that generates output tokens.
-   **Energy efficiency (`η`):** SLO-passing requests divided by GPU
    joules.
-   **GPU joule:** Unit of energy consumed by the GPU; power integrated
    over time.
-   **MTP:** Multi-token prediction, a mechanism that can support
    speculative generation.
-   **Open-loop load:** Requests arrive according to a schedule,
    independent of completion of earlier requests.
-   **p95:** 95th percentile; 95% of measured values are at or below
    this value.
-   **Prefill:** Processing the prompt before generating the response.
-   **Quantization:** Representing model weights/activations with
    lower-precision numbers.
-   **RAG:** Retrieval-augmented generation, where external retrieved
    content is included in the prompt.
-   **SLO:** Service-level objective; a threshold a request must meet.
-   **Speculative decoding:** Using a draft mechanism to propose tokens
    that a target model verifies.
-   **Streaming:** Returning generated output incrementally rather than
    waiting for the entire response.
-   **Throughput:** Work completed per unit time; competition throughput
    score is specifically peak-phase SLO pass rate.
-   **TPOT:** Time per output token.
-   **TTFT:** Time to first token.
-   **vLLM:** Open-source inference and serving engine for language
    models.
-   **W4A16:** 4-bit weights with 16-bit activations, as used in the
    briefing's AWQ candidate label.

## 18. Reference list

1.  **CMKL University --- GreenMind AI Hackathon announcement**\
    https://cmkl.ac.th/news-events/can-you-make-ai-faster-while-using-less-energy\
    Event dates, location, host organizations, eligibility, event focus,
    and public prize description.

2.  **CMKL --- MANGO1.5-Qwen3.5-9B model card**\
    https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B\
    Model details, license, training notes, and serving examples.

3.  **CMKL --- MANGO model files**\
    https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B/tree/main\
    Checkpoint/configuration files.

4.  **Qwen --- Qwen3.5-9B model card**\
    https://huggingface.co/Qwen/Qwen3.5-9B\
    Base-model architecture and configuration details.

5.  **vLLM --- OpenAI-compatible server**\
    https://docs.vllm.ai/en/latest/serving/online_serving/openai_compatible_server/\
    API endpoints and compatibility behavior.

6.  **vLLM --- Online serving**\
    https://docs.vllm.ai/en/latest/serving/online_serving/\
    Serving architecture and supported interfaces.

7.  **vLLM --- Speculative-decoding acceptance metrics**\
    https://docs.vllm.ai/en/latest/features/speculative_decoding/acceptance_metrics/\
    How to inspect per-request speculative acceptance metrics; feature
    is marked experimental in the docs.

8.  **NVIDIA --- GPU Performance Background User's Guide**\
    https://docs.nvidia.com/deeplearning/performance/dl-performance-gpu-background/\
    GPU architecture, execution model, arithmetic intensity, and
    diagnosing compute/memory/parallelism limits.

9.  **Hackathon Discord from the supplied briefing**\
    https://discord.gg/Wvy2SwZxKh\
    Use for organizer communication; verify current invite availability.

------------------------------------------------------------------------

**Last updated:** October 24, 2026.\
**Caveat:** The competition formulas, detailed SLOs, resource
allocation, submission limits, and deadlines in this document come from
the supplied hackathon briefing. Public references provide supporting
context, not independent verification of every grader implementation
detail.

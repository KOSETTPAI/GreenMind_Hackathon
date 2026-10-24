# GreenMind Hackathon — Experimentation Plan and Final Submission Runbook

**Team:** 17  
**Target:** `CMKL/MANGO1.5-Qwen3.5-9B` on 1 × NVIDIA A100-SXM4 40 GB  
**Deadline:** Sunday, 25 October 2026, 11:00 (UTC+7, Bangkok time)  
**Planning horizon:** approximately 17 hours from the current evening work session  
**Submission capacity:** up to **5 Validation submissions per hour and 5 Final submissions per hour**, with each track's quota renewing hourly. Confirm the live counters in the grader rather than assuming a particular reset boundary.

> **Mission:** identify a stable configuration with higher official score, more SLO-met work per GPU joule, and no accuracy or tool-calling regression. Use the submission capacity to run controlled, high-information tests—not to make random changes.

---

## 0. Executive decision

The first experiment should be **remove MTP**, keeping the other settings unchanged. The current `run4/full` configuration is below the team's earlier Validation reference and returned a zero score on the recorded Final.

Then test, in order:

1. **Scheduler token budget** (`max-num-batched-tokens`): 4,096 versus 8,192, then 16,384 only if results justify it.
2. **Hybrid prefix caching**: compare on/off with MTP disabled. Monitor cache-hit metrics instead of assuming that caching helps this Qwen3.5 hybrid architecture.
3. **Partial-prefill scheduling**: limit concurrent long prefills so short prompts can make progress, if the exact vLLM image supports the flags.
4. **MTP**: only reintroduce it after the no-MTP winner is known; test with prefix caching disabled first.
5. **GPU memory headroom**: test a higher utilization value only if preemption or cache pressure appears in telemetry.
6. **Power cap**: do this last, only after on-time completion is high. A cap that pushes TPOT over 50 ms can lower useful work per joule.

**Do not change several variables together in the early experiments.** A configuration that happens to improve is not useful scientific evidence if there is no way to identify why.

---

## 1. Known facts and score interpretation

### 1.1 Current recorded results

| Run | Track | Configuration | Score | SLO-met | Efficiency vs. track baseline | p95 TTFT | p95 TPOT | Accuracy |
|---|---|---|---:|---:|---:|---:|---:|---:|
| V0 | Validation | Team's earlier reference configuration | **34.8** | 56/100 | Not copied | Not copied | Not copied | Not copied |
| E1 | Validation | V0 + 40,960 max context | Not copied | 52/63 visible | Not copied | Not copied | Not copied | Not copied |
| R4-full | Validation | AWQ + MTP k=1 + hybrid prefix cache | 32.8 | 50/100 | 1.38× | 3.12 s | 55 ms | 86.9% |
| R4-full | Final | Same `full` tier | **0.0** | 93/300 | **0.92×** | 3.59 s | 91 ms | 88.4% |

The Validation and Final requests differ in size and composition. Do **not** treat their absolute values as a controlled A/B comparison. Compare configurations on the same track and prefer repeated results over a single noisy sample.

### 1.2 Why the Final was zero

The Final efficiency was below baseline:

- Final baseline: `η_base = 0.00163` SLO-met requests per GPU joule.
- Measured efficiency: approximately `0.92 × η_base`.
- Energy score: `s_E = clip(ln(η / η_base) / ln(3), 0, 1) = 0` below baseline.
- Since `s_E` is multiplied into the total score, the final score becomes zero even though accuracy retention was strong.

The main goal is therefore not merely fewer watts. It is **more requests meeting every SLO condition per measured GPU joule**.

### 1.3 Score formula and practical meaning

`S = 100 × A × s_E^0.6 × s_T^0.2 × s_L^0.2`

- `A`: accuracy-retention gate. Accuracy must stay close to the baseline, and weak task classes can incur an extra penalty.
- `s_E`: energy efficiency, computed from SLO-met requests divided by total GPU joules across the measured window.
- `s_T`: share of peak-phase arrivals that meet SLO.
- `s_L`: composite score from p95 TTFT relative to each prompt's allowed TTFT and p95 TPOT relative to 50 ms.
- **Only the Final counts.** Final: `η_base = 0.00163`, reference macro-accuracy 87.8%. Validation (practice, for checking the server works): `η_base = 0.00154`, 87.2%. Keep each track's constants separate.
- **Validation does not predict the Final.** run6 scored 95.6 on Validation (peak 35 running, p95 TPOT 18 ms) and 19.1 on Final (peak 111 running, p95 TPOT 82 ms). Rank configurations on Final results or a Final-shaped replay, not on Validation.

### 1.4 What an SLO-met request must satisfy

The request must stream, complete without error/timeout, not be truncated at 8,192 output tokens, meet the prompt-length-dependent TTFT allowance, and meet TPOT ≤ 50 ms (except one-token answers). Failed/late/truncated work still consumes energy but adds no useful work to the efficiency numerator.

### 1.5 Key bottleneck hypothesis

The R4-full logs show p95 TTFT far above the prompt-specific limits and p95 TPOT above 50 ms. The startup warning says the scheduler is using a 2,048-token budget in association with speculative decoding. Long 20K–32K prompts can therefore create substantial prefill work while short requests wait. This is a **strong hypothesis supported by logs**, not a guarantee that increasing the batch-token budget will improve the total score; measure both TTFT and TPOT.

---

## 2. Constraints and safety rules

1. The official endpoint must remain OpenAI-compatible at `/v1/chat/completions`, with streaming, usage, reasoning mode and automatic tool calling working.
2. Use one serving process and the assigned GPU only. Do not run Validation, Final, synthetic load replay, warmup, profiling, or a second model workload concurrently on that GPU.
3. Keep power limits or clock settings constant throughout an evaluation. Never make changes that apply only during the measured window.
4. No response caching of grader requests. Ordinary engine KV/prefix caching is allowed, subject to correctness and performance testing.
5. Do not inspect, reconstruct, or attempt to obtain hidden questions. Use only synthetic/public prompts for local replay.
6. Do not modify NVML, use `LD_PRELOAD` tricks, contact external inference APIs during a graded run, or use closed-source software.
7. **Never launch a Final while a Validation is running, even if the grader exposes independent track quotas.** Both tests use the same serving VM/GPU and can contaminate each other's measured results.
8. Save a profile and log entry before each submission. After launching a new tier, run its preflight and verify endpoint reachability from outside the VM.
9. Keep `BIND=0.0.0.0` on the grader-facing server. A loopback-only bind previously caused the grader health check to fail.
10. If a configuration produces malformed output, tool-call failures, cache corruption, or accuracy degradation, immediately return to the last known-good tier.

---

## 3. Experimental method

### 3.1 Establish the control

The current candidate is `run4/full`:

- AWQ W4A16 MANGO checkpoint
- GPU memory utilization 0.90
- max model length 40,960
- MTP k=1
- prefix caching enabled with `--mamba-cache-mode align`
- Qwen3 reasoning parser and `qwen3_coder` tool parser
- nightly vLLM image

The first A/B experiment removes only MTP, keeping the current cache setting and other arguments constant. Do not change the model, serving image, memory utilization, context length, power limit, or API behavior at the same time.

### 3.2 One-factor-at-a-time rule

For every experiment, record:

- parent/baseline profile;
- exact changed argument(s);
- vLLM container image digest and version;
- official Validation or Final score;
- SLO-met requests / arrivals;
- accuracy and per-class accuracy if available;
- `η / η_base`, joules per incoming request, and joules per SLO-met request;
- p95 TTFT and p95 TPOT;
- peak running/waiting sequences, preemptions, prefix-cache hit rate, MTP acceptance if applicable;
- any startup warning, tool-call failure, malformed output, or request timeout.

An experiment is only a **keep** if the official score improves or it is a deliberate intermediate step that improves the bottleneck metric needed for the next experiment without causing a serious regression elsewhere.

### 3.3 Do not rank by a single metric

Use the official score as the primary metric. Use SLO-met count, p95 TTFT, p95 TPOT, energy efficiency, and accuracy as diagnostic metrics. Lower average latency or lower watts alone does not establish a better score.

### 3.4 Use synthetic replay carefully

If time allows, run `vllm bench serve` with synthetic random prompts at roughly the grader's open-loop arrival rate to cheaply reject obviously poor configurations. Check flags using the installed image's `vllm bench serve --help`; nightly-build CLI flags change. Never run replay during a graded evaluation. Replay can rank latency/throughput candidates but cannot verify the hidden-set accuracy or score gate, so a promising configuration still needs Validation.

Example template (adjust prompt/output lengths to observed non-sensitive workload distributions and confirm flags first):

```bash
docker exec mango-vllm vllm bench serve \
  --base-url http://127.0.0.1:8000 \
  --model mango1.5-awq-w4a16 \
  --dataset-name random \
  --random-input-len 4000 \
  --random-output-len 1500 \
  --request-rate 4 \
  --num-prompts 100
```

Use replay only when no Validation or Final is running. If the harness cannot approximate open-loop arrival behavior accurately, skip it rather than trust the numbers.

---

## 4. Quota-aware schedule to the deadline

The limit is **five submissions per hour in each track**, Validation and Final separately. Quotas renew hourly; the actual platform counter is authoritative. Do not use all slots just because they are available.

### 4.1 Recommended time budget

The wall-clock deadline is 25 October at 11:00 UTC+7. Prioritize experiments in the evening, then reserve a clean morning window for the best configuration and final submission(s).

| Window | Purpose | Exit condition |
|---|---|---|
| First 20–30 minutes | Housekeeping; verify quotas, current process, active evaluations, image digest, flags, profile backup, telemetry | Safe to relaunch and reproduce the current setup |
| First 2–3 hours | Main scheduler experiments: no-MTP, prefix-cache comparison, budgets 4,096 and 8,192, partial-prefill scheduling | Select a strong serving configuration, not yet power-tuned |
| Next 2–3 hours | Explore the winning branch: 16,384 budget if justified, prefix/MTP interaction, higher utilization only if telemetry demands it | Identify a stable candidate and at least one alternative |
| Later evening | Submit Final runs on the strongest candidates; run extra Validation only for high-value unresolved questions | A completed Final result exists for the leading candidate |
| Overnight | Avoid risky code changes; use new quota windows for a clearly motivated test, a repeat of a noisy winner, or candidate Final evaluation | No unresolved critical regression; experiment ledger up to date |
| Morning, no later than 09:30–10:00 | Freeze the best configuration, clean Validation if needed, then clean Final submission(s) early enough to finish | Completed result(s), no overlap, enough time for recovery |
| Final 30–60 minutes | No experimental changes. Confirm History, profile, endpoint, logs, deliverables | Deadline passed with the best completed result preserved |

**Schedule by completion, not by the clock alone.** Do not start the next test until the previous evaluation has finished and its result has been recorded. If a Final is still running, the schedule moves; it is not safe to start other GPU workloads.

### 4.2 How to spend hourly quotas

- Use Validation slots for **discovery and causal comparisons**.
- Use Final slots for candidates that have already demonstrated promise on Validation, or for a strategically important recheck when a prior Final may have been contaminated.
- Do not spend multiple Final submissions on a configuration that failed to beat the known Validation reference unless there is a concrete reason (for example, the first Final overlapped another workload or the track was misconfigured).
- When a quota renews, choose the next experiment from measured evidence. Keep a short queue of two to three eligible next experiments rather than committing blindly to a fixed sequence.
- Reserve at least one morning opportunity for a final clean run. Do not leave the only viable Final submission until the last minutes before the deadline.

---

## 5. Validation experiment ladder

The exact run order should adapt to results, but the initial ladder below is the recommended default.

### V1 — Remove MTP

**Profile:** existing `run4/no-mtp` if it removes only the speculative config and otherwise preserves the current `full` profile. Inspect the argument diff before launching.

**Question:** Does MTP k=1 cost more GPU compute/latency under the grader's peak concurrency than it saves in decoding steps?

**Keep if:** score, SLO-met rate, or the decisive latency bottleneck improves without accuracy/tool regressions. If the score is lower but TTFT is substantially better, keep it as an intermediate parent for scheduler tests—not as the final candidate yet.

### V2 — Prefix caching off, MTP still off

**Profile:** V1, plus prefix caching disabled. Do not accidentally reintroduce MTP when using the existing `no-prefix` tier; its current profile may still enable MTP.

**Question:** Is prefix caching useful for this hybrid Qwen3.5 workload, given `mamba_cache_mode=align` and the observed cache behavior?

**Why this matters:** vLLM documents hybrid Mamba cache-alignment behavior and its effect on reuse. A recent vLLM issue also reports an MTP + prefix-caching output-corruption problem on a Qwen3.5-class hybrid model. This is not proof that Team 17's failures came from this bug, but it makes **MTP plus prefix caching a poor first choice**. See [vLLM automatic prefix caching docs](https://docs.vllm.ai/en/stable/features/automatic_prefix_caching/) and [vLLM issue #53912](https://github.com/vllm-project/vllm/issues/53912).

**Keep if:** on-time requests, score, or efficiency improves. If cache-hit rate is effectively zero, there is little evidence for keeping the setting for this workload.

**Conditional follow-up — hybrid shared-prefix checkpoint:** if cache-on is better than cache-off, but telemetry shows low cache hits for repeated multi-turn prefixes, check whether the installed vLLM image supports `--enable-mamba-shared-prefix-checkpoint`. vLLM's hybrid-cache documentation describes this as a way to checkpoint a shared-prefix junction in `align` mode. Test it as a separate profile change with MTP disabled; do not combine it with an MTP change. Keep it only if cache hits and official score improve. Reference: [vLLM automatic prefix caching docs](https://docs.vllm.ai/en/stable/features/automatic_prefix_caching/).

### V3 — Explicit batched-token budget 4,096

**Profile:** best of V1/V2 plus `--max-num-batched-tokens 4096`.

**Question:** Does a larger token budget reduce long-prefill queueing and improve TTFT while keeping decode TPOT below the 50 ms target?

**Keep if:** SLO-met count and score improve. Watch TPOT, scheduler latency, and preemption. A large batch-token budget can boost prefill throughput but may increase interference with decode.

### V4 — Batched-token budget 8,192

**Profile:** same base as V3; change only `--max-num-batched-tokens 8192`.

**Question:** Does the additional prefill budget produce enough TTFT improvement to compensate for any TPOT regression?

**Keep if:** official score improves, or the metrics clearly suggest this is the right direction and there remains a follow-up budget to test. Do not assume a bigger number is better.

### V5 — Partial-prefill scheduling

Only run after `vllm serve --help` confirms the exact flags on the deployed image and confirms chunked/partial prefill is active or can be enabled.

Candidate settings to test as one logical scheduling experiment:

```text
--max-num-partial-prefills 2
--max-long-partial-prefills 1
--long-prefill-token-threshold 4096
```

The purpose is to stop several long prompts from monopolizing the prefill path, allowing shorter prompts a better chance of meeting their short TTFT targets. `--max-long-partial-prefills` should be less than `--max-num-partial-prefills` if the goal is to let shorter prompts get scheduled while a long prompt is partial-prefilling.

**Caution:** option names/defaults vary by vLLM release. `--long-prefill-token-threshold` only has meaning for chunked prefill in relevant versions. Do not paste flags blindly into a nightly image. Current CLI docs: [vLLM CLI reference](https://docs.vllm.ai/en/latest/cli/index.html).

**Keep if:** short-prompt TTFT and on-time rate improve without a meaningful TPOT or score regression.

### V6 — Budget 16,384 (conditional)

Run only if 8,192 materially improved TTFT and TPOT still has headroom, or if current metrics show the prefill budget remains the bottleneck. Do not test this merely because it is the next number.

### V7 — MTP k=1 without prefix caching (conditional)

Only after a no-MTP winner is identified:

- use the best batched-token / partial-prefill settings;
- turn prefix caching off for this first MTP comparison;
- add `--speculative-config '{"method":"mtp","num_speculative_tokens":1}'` using the format accepted by the current launcher;
- compare MTP acceptance and achieved output throughput, not acceptance rate alone.

If k=1 helps, k=2 is a secondary experiment. Do not try multiple speculative values at once. If MTP reintroduces the scheduler-token warning, capture it and verify the effective scheduler budget in logs.

### V8 — GPU memory utilization 0.92 (conditional)

Run only when telemetry indicates preemption, constrained KV/state capacity, or unused memory headroom. Do not expect 0.92 alone to solve queueing. Keep model/context length and scheduler settings unchanged.

### V9 — Constant GPU power limit (late-stage only)

Only run after the leading config is reliably meeting a high fraction of requests, ideally at least about 90/100 during Validation, and p95 TPOT is not already materially over 50 ms.

Suggested order:

1. Current/default power limit as reference.
2. Fixed **250 W** limit for the entire test.
3. Fixed **200 W** only if 250 W preserved SLO rate and improved efficiency.
4. A lower cap only if previous data supports it and enough time remains for recovery.

Use `run4/power.sh` so the limit is recorded and set before the evaluation. Never change power during a measured run. Record the limit and restore the known-good setting after the test. A cap wins only when it improves the official score/energy efficiency without pushing requests over TPOT/TTFT SLOs.

### V10 — Repeat the apparent winner

A repeat is worthwhile when the winner's improvement is small, the run was noisy, or telemetry indicates possible interference. Use the same arguments and power state; do not change the configuration between repetitions.

---

## 6. Efficient use of Final submissions

Validation and Final limits are independently five per hour, but Final traces consume more time and should be used selectively.

### Final submission policy

1. **First Final:** submit the strongest configuration from the first meaningful Validation sweep, once all traffic has stopped and preflight passes.
2. **Candidate-comparison Final:** if another profile has a materially stronger Validation score/SLO trade-off, submit it as the next Final candidate. Do not launch it alongside the first Final.
3. **Improved candidates:** every new configuration must first have a plausible Validation win or a strong reason to revisit an earlier Final (such as known overlap/measurement contamination).
4. **Repeat a winner:** use a repeat Final if the top score margin is narrow or a previous test might have been contaminated. An uninterrupted repeat increases confidence.
5. **Morning Final:** use the best validated, stable profile. Avoid unvalidated changes after the final clean Validation.

The briefing says the best completed submission on a track counts. Confirm that statement against the live grader UI/History. Treat only a **finished** result as usable; do not rely on running, interrupted, or failed submissions.

### Suspected overlap from the earlier run

The notes indicate that the earlier Final began around 09:42:30 and Validation started at 09:47:19. If the Final was still active, its performance could have been affected by simultaneous requests. Before attributing the entire regression to the model configuration, inspect the grader's timestamps and the server telemetry. Regardless, all remaining experiments must be strictly sequential.

---

## 7. Exact per-run checklist

### Before the run

- [ ] Read current Validation and Final quota counters.
- [ ] Confirm no Validation, Final, synthetic replay, or other GPU work is active.
- [ ] Save/commit the profile and add a one-line experiment hypothesis to the ledger.
- [ ] Check `vllm serve --help` for the flags being tested.
- [ ] Check current image digest and version; keep the image fixed during the experiment ladder.
- [ ] Launch using `BIND=0.0.0.0` and the existing run4 script.
- [ ] Run the full preflight: health endpoint, chat, streaming with usage, tool-call streaming, thinking mode, model name, exact args, context length.
- [ ] Confirm endpoint is reachable from an external machine.
- [ ] For power tests, set the power limit before the run and record it.

### During the run

- [ ] Do not restart or mutate the configuration.
- [ ] Do not run local benchmarks or warmups on the same GPU.
- [ ] If telemetry is enabled, record NVML energy, running/waiting requests, preemptions, prefix cache hits and MTP acceptance.
- [ ] If the endpoint fails or produces malformed output, record the evidence and stop treating the profile as a viable candidate.

### After the run

- [ ] Wait for an explicit finished result in grader History.
- [ ] Save the raw console output and result JSONL/metadata where available.
- [ ] Record score, accuracy, η vs baseline, SLO-met, p95 TTFT, p95 TPOT and run timestamps.
- [ ] Mark the profile `KEEP`, `REJECT`, or `INTERMEDIATE` and state why.
- [ ] Update the next experiment based on the observed bottleneck.
- [ ] Ensure the next test starts only when the GPU is idle.

---

## 8. Run decision tree

Use the official score first, then use component metrics to select the next experiment.

| Result pattern | Interpretation | Next action |
|---|---|---|
| Score improves and accuracy stays sound | Configuration likely improves the actual objective | Keep it; proceed to the next single-factor experiment |
| `η ≤ η_base` or `s_E = 0` | Energy efficiency cannot produce score | Prioritize SLO rescue; do not power-cap |
| TTFT ratio very poor; TPOT near/under 50 ms | Prefill queueing is a leading candidate | Test 4,096 / 8,192 budget and partial-prefill scheduling |
| TTFT improves, TPOT worsens | More prefill is interfering with decode | Compare adjacent lower token budget; do not chase TTFT alone |
| TPOT remains above 50 ms after TTFT improves | Decode / concurrency / MTP cost remains high | Compare no-MTP vs MTP at the same scheduler settings; inspect peak concurrency |
| Prefix-cache hits approximately zero | Cache provides little observed reuse under current run | Prefer cache-off unless there is another measured benefit; consider hybrid alignment behavior |
| MTP acceptance looks high but score falls | Acceptance is not translating into useful end-to-end throughput/energy | Reject MTP or test a smaller draft token count |
| Preemption count is high | Cache/memory pressure may be reducing throughput | Test memory utilization 0.92 or context/memory settings, one at a time |
| SLO rate is strong but energy multiplier is modest | Now power may be a useful trade-off | Run a constant 250 W cap, then compare |
| Score changes slightly between identical runs | Run-to-run noise or environmental interference | Repeat the same profile before changing it |
| Any class accuracy or tool behavior regresses | Overall score can be gated or operational behavior can fail | Revert and do not submit as the primary candidate |

---

## 9. Suggested first-hour run sequence

This is the default sequence for the first five available Validation slots; adapt if a result clearly changes the next best experiment.

| Slot | Candidate | Changed factor | Expected signal |
|---|---|---|---|
| 1 | V1 `no-mtp` | Remove MTP only | Establish whether MTP hurts under load |
| 2 | V2 `no-mtp`, cache off | Disable prefix cache relative to V1 | Determine if hybrid prefix caching pays off |
| 3 | V3 best of V1/V2 + budget 4,096 | Explicit batched-token budget | Improve long-prompt TTFT/queueing |
| 4 | V4 same parent + budget 8,192 | Budget only | Test stronger prefill scheduling |
| 5 | V5 best + partial-prefill controls, or repeat best | Scheduling or repeat | Improve short-request TTFT or assess noise |

**If any test is clearly bad, do not blindly continue its branch.** For example, if budget 8,192 makes TPOT much worse, return to 4,096 and use slot 5 on partial-prefill scheduling or a repeat. The run count is a ceiling, not a requirement to try every listed option.

---

## 10. Suggested hourly adaptive sequence after the first five tests

### Next quota window

Use the next five Validation slots to answer only the unresolved questions that most affect score:

1. Budget 4,096 vs 8,192 winner confirmed/repeated.
2. Partial-prefill threshold variant if that method helped.
3. Budget 16,384 only when justified by the previous trend.
4. MTP k=1 with prefix cache disabled, if no-MTP is not clearly superior.
5. Repeat the best profile or test the single most promising alternative.

At this stage, run a Final for the strongest candidate once Validation and preflight support it. A Final slot is not reserved for the next experiment unless that experiment has a plausible path to improving the current best result.

### Later quota windows

Spend additional Validation submissions on:

- one controlled comparison of partial-prefill settings;
- one MTP comparison (k=1, then k=2 only if justified);
- one memory-utilization test only if telemetry supports it;
- a repeat of the best Validation candidate;
- a power cap only after high SLO success.

Use Final submissions for leading candidates, repeats of a leading configuration if results are suspect/noisy, and the final frozen configuration. The moment an experimental change no longer has time to be validated and safely evaluated before deadline, reject that change.

---

## 11. Configuration management

### 11.1 Profile changes

The run4 launcher accepts named tiers and the preflight checks profile arguments against the running container. To add an experiment, copy a profile and edit only the intended parameter. Example for `no-mtp` plus 4,096 batched tokens:

1. Copy `run4/profiles/r4-no-mtp.args` to a new file such as `run4/profiles/r4-no-mtp-mbt4k.args`.
2. Add the single argument `--max-num-batched-tokens 4096` in the format expected by the profile.
3. Add a corresponding tier to the case statement in `run4/start.sh` and the tier help text.
4. Run `./run4/flag-check.sh <tier>` before stopping the currently running service.
5. Once a graded run is finished, launch with the external bind enabled, run the full preflight and check from outside the VM.
6. Record the profile hash/diff in the experiment ledger.

Use the existing script's argument format; do not assume each argument must be on a separate line if the profile parser expects something different.

### 11.2 Version control and artifacts

Before and after a profile change:

```bash
git status --short
git diff -- run4/profiles run4/start.sh
```

Record the container image digest:

```bash
docker inspect mango-vllm --format '{{.Image}}'
```

Keep raw outputs and experiment reports in the repository. Do not overwrite the original Final log with Validation output; separate the logs, e.g. `run4/final_log.md` and `run4/validation_log.md`.

---

## 12. Experiment ledger template

Copy one row for every Validation and Final submission.

| ID | Track | Start time (UTC+7) | Parent profile | Single change | Image digest/version | Score | SLO-met | Accuracy | η / baseline | J / incoming req | p95 TTFT | p95 TPOT | Preemptions | Cache hit rate | MTP acceptance | Decision / notes |
|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| V1 | Validation | | run4/full | remove MTP | | | | | | | | | | | n/a | |
| V2 | Validation | | V1 | prefix cache off | | | | | | | | | | | n/a | |
| V3 | Validation | | V1 or V2 | budget 4,096 | | | | | | | | | | | n/a | |

For Final runs, add a short note on whether any other GPU activity occurred. The required answer should be `none`; if any overlap happened, mark the result as potentially contaminated and do not use it to compare configurations confidently.

---

## 13. Final freeze checklist

Run this checklist for the selected configuration and do not change it once the clean Final is launched.

- [ ] Best completed Validation score and the rationale for selecting this profile are recorded.
- [ ] No experiment has shown unacceptable accuracy retention or tool-call failure.
- [ ] The selected profile passes chat, streaming, token-usage, reasoning and automatic tool-call smoke tests.
- [ ] Model ID, `/v1` endpoint, external reachability, port and public bind are correct.
- [ ] `max_model_len` still supports long prompts up to 32K plus up to 8,192 output tokens. Current 40,960 setting was chosen for this requirement; don't lower it casually.
- [ ] Power limit is the intended constant setting and will not be changed during evaluation.
- [ ] No local benchmark, warmup or telemetry-heavy profiling is running during the official measured window.
- [ ] Current run4 profile and container image digest are written to the ledger.
- [ ] The selected profile has enough time for the full 300-request Final to finish before the deadline.
- [ ] Final History confirms the completed result; save its output and score.
- [ ] Do not make a late optimization after the final validation unless there is enough time to validate and run Final on it.

---

## 14. What not to spend time on now

Unless the main ladder is exhausted and the candidate is already stable, avoid:

- switching to SGLang, TensorRT-LLM or llama.cpp;
- retraining/distillation or a new quantization recipe;
- custom CUDA kernels;
- speculative external draft models;
- FP8 KV cache experiments (low priority on this A100 + hybrid cache workload);
- arbitrary `max-num-seqs` caps without evidence that excess concurrency is the problem;
- extra API processes, which conflict with the serving constraints;
- any noncompliant clock/power manipulation or hidden-test interference.

The checkpoint's own model card specifically targets vLLM on Ampere GPUs for the AWQ W4A16 compressed-tensors model. The time remaining favors optimizing the existing stack rather than migrating engines. See [checkpoint model card](https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp).

---

## 15. Pitch notes to preserve while experimenting

Track the engineering story as well as the score:

- **Initial hypothesis:** quantization saves weight memory/traffic, but scheduler behavior and tail latency determine how much work passes SLO under open-loop load.
- **Observed failure:** run4/full preserved accuracy but was below the Final energy baseline and had poor p95 TTFT/TPOT.
- **New hypothesis:** removing MTP and increasing/controlling prefill scheduling may recover timely work; hybrid prefix caching must be measured rather than assumed useful.
- **Sustainability metric:** SLO-met requests per GPU joule, with idle gaps and final drain included in the energy window.
- **Trade-offs:** TTFT versus TPOT, speculative verification overhead, cache hit rate versus recurrent-state alignment, higher power versus shorter duration, and accuracy retention versus compression.
- **Failed approaches:** keep the exact configuration, score, observed result, and why it was rejected. The judging rubric values explaining attempts that did not work.

Do not claim that an optimization improved performance unless the result was measured in the official grader or supported by a reproducible local load replay.

---

## 16. References

Use the documentation corresponding to the **installed vLLM image**, because nightly builds and CLI defaults change frequently.

1. **MANGO AWQ W4A16 + MTP checkpoint card:** https://huggingface.co/CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp
2. **vLLM CLI reference:** https://docs.vllm.ai/en/latest/cli/index.html
3. **vLLM automatic prefix caching, including hybrid Mamba notes:** https://docs.vllm.ai/en/stable/features/automatic_prefix_caching/
4. **vLLM issue documenting reported MTP + prefix-cache output corruption on a hybrid Qwen3.5-class model:** https://github.com/vllm-project/vllm/issues/53912
5. **vLLM issue on hybrid prefix-cache hit-rate behavior:** https://github.com/vllm-project/vllm/issues/45238
6. **Official GreenMind participant briefing:** `GreenMind_Participant_Briefing.pdf` in the team materials.
7. **Team's scoring and current run notes:** `scoring_criteria.md`, `run4/README.md`, `run4/PLAN.md`, `run4/ENDPOINT_RUNBOOK.md`, `run4/log.md`, `run4/validation_log.md`, and `experiments/results/`.

---

## Final operating principle

**Use Validation to explain what works; use Final to confirm the best candidates; protect the last clean run.** More submissions are useful only when each one answers a question or improves the best completed result. The target is a stable score above the team's previous Validation reference, with `η > η_base`, high SLO success, acceptable p95 latency, and no accuracy or tool-calling regression.

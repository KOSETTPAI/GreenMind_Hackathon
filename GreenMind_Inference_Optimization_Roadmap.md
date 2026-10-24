# GreenMind LLM Inference Optimization Hackathon
## Complete concept roadmap, competition playbook, scoring reference, and glossary

**Audience:** Backend engineer learning ML systems and GPU inference from first principles.  
**Purpose:** Learn to optimize, measure, evaluate, and explain a local inference server for the organizer-provided MANGO1.5-Qwen3.5-9B model.

> **Source-of-truth warning.** The material supplied for this task describes the hackathon and its environment, but does **not** include the full organizer briefing with the exact scoring equations, numeric thresholds, five useful-request conditions, or pitch-round weights. Therefore, this document distinguishes stated event context from general technical knowledge and hypotheses. It deliberately does not invent official score formulas or thresholds. Fill in the marked items from the actual briefing before tuning against the grader.

## 1. Roadmap overview and knowledge gaps

Your backend experience already helps with HTTP APIs, queues, concurrency, caching, observability, profiling, load tests, and reproducibility. The new material is the interaction between neural-network computation, GPU memory/compute, token-by-token generation, model quality, and the evaluator's definition of useful work.

### Dependency order

1. **Read the grader and rules first.** Establish what is scored, what is a hard gate, what invalidates a submission, what is fixed, and what can be changed.
2. **Learn model and token basics.** Understand what the model computes and why output length and prompt length matter.
3. **Learn GPU and numerical basics.** Understand the difference between compute capacity, memory capacity, memory bandwidth, and power.
4. **Learn inference serving.** Separate prefill from decode; understand batching, cache/state, scheduling, streaming, and SLOs.
5. **Build and measure the reference server.** Do not optimize until you can reproduce correctness, latency, throughput, and energy measurements.
6. **Change one thing at a time.** Start with low-risk serving configuration; move to precision/quantization and decoding only after diagnosis.
7. **Validate and pitch.** Select by the real scoring function, not by a single speed number.

### Competition context (from the supplied prompt, not independently confirmed organizer rules)

- Model: **MANGO1.5-Qwen3.5-9B**, described as a hybrid Mamba/Gated-DeltaNet architecture.
- Hardware: **NVIDIA A100 40 GB**.
- Baseline/serving context: **vLLM**, with alternatives worth investigating.
- Interface: OpenAI-compatible chat completions, streaming, and tool calling.
- Workloads: chat, RAG, agentic tool calls, reasoning, coding, Thai, and long-context requests.
- Goals: preserve correctness/accuracy, meet request-level SLOs, deliver throughput, and minimize GPU energy.
- Evaluation: automated scoring plus a final pitch.

These details should be verified against the actual briefing and the supplied model files/configuration before being treated as binding implementation facts.

## 2. Learning stages

### Stage 0 — Understand the evaluator and constraints

**Priority:** Must know. **Prerequisites:** Backend testing and metrics are enough.

**Why it matters:** The grader defines the optimization problem. A faster server can score worse if it misses deadlines, changes answers too much, fails tool-call formatting, drops requests, or consumes more energy per useful answer.

**Concept checklist:** eligibility gates; hard SLOs; continuous score components; baseline; validation versus final submission; workload mix; request arrival schedule; measurement window; energy boundary; allowed artifacts and dependencies; network restrictions; deterministic settings; final pitch rubric.

**Plain English and technical depth:** A hard gate is a condition that must be satisfied, not a smooth reward. A continuous metric improves the score gradually. A baseline is the reference point against which performance or accuracy is compared. A validation run is a feedback mechanism, not proof of hidden-test performance.

**Backend connection:** Treat the grader like a production contract and load-test harness. Read the request schema, timeout behavior, retry policy, expected response shape, and acceptance criteria before changing the service.

**Exercises:** Make a one-page table of every rule, exact formula, threshold, measurement source, and failure consequence. Mark unknowns explicitly. Reproduce a baseline run before tuning.

**Mastery:** You can explain what makes a request count, which constraints are gates, and how the final score is computed without guessing.

**Common mistakes:** Optimizing average latency while ignoring p95; assuming a failed or late request contributes partial credit; confusing validation scores with final scores; treating a prompt summary as the complete official rulebook.

**Briefing items to fill in:** exact accuracy formula; accuracy-retention cutoff; five conditions for useful work; TTFT/TPOT limits; p95 definition and normalization; throughput definition; energy score formula and clipping; component weights; final pitch weights; submission limits.

### Stage 1 — ML and LLM fundamentals

**Priority:** Must know. **Prerequisites:** Stage 0.

**Concept checklist:** parameters; weights; checkpoint; tokenizer; token IDs; vocabulary; embeddings; logits; softmax; sampling; autoregressive generation; context window; prompt and completion tokens; normalization; attention; feed-forward network; residual connections; inference versus training.

**Plain-English explanations:**
- A **token** is a unit the model processes: often a word fragment, punctuation, or byte-related unit—not necessarily a word.
- A **tokenizer** maps text to token IDs and maps generated IDs back to text. Different tokenizers can make the same text a different number of tokens.
- **Weights/parameters** are learned numbers stored in the checkpoint. A 9B-parameter model has roughly nine billion learned scalar parameters, though actual memory use also includes non-weight state and runtime overhead.
- **Embeddings** turn token IDs into vectors. Hidden states are the evolving vector representations computed through layers.
- **Logits** are unnormalized scores over the vocabulary. **Softmax** converts them to a probability distribution. **Sampling/decoding** selects the next token according to the configured strategy.
- **Autoregressive generation** predicts one next token, appends it to the sequence, then repeats. Output tokens therefore incur repeated model work.
- **Inference** runs a trained model to produce outputs; training additionally computes gradients and updates weights.
- **Attention** lets a token use information from other tokens. **Feed-forward/MLP blocks** transform each token representation. **Normalization** stabilizes layer activations. **Residual connections** add a block's input back to its output.

**Technical depth:** For a logits vector `z`, softmax is `p_i = exp(z_i) / sum_j exp(z_j)`. Temperature `T` changes the distribution to `softmax(z/T)`. Lower temperature usually concentrates probability; top-p/top-k restrict candidate tokens. Sampling settings can affect both quality and repeatability. Do not alter them unless the rules permit it.

**Context length:** Longer prompts generally increase prefill work and may increase cache/state requirements. Longer generations increase decode steps and total energy. The cost curve depends on architecture and implementation, not just the token count.

**Backend connection:** Tokenization resembles a serialization/encoding boundary; logits are a ranked candidate list; sampling is a policy; a checkpoint is an immutable model artifact; generation is a stateful loop rather than one ordinary stateless database query.

**Exercises:** Tokenize English and Thai examples; compare token counts for semantically equivalent prompts; inspect the model config and tokenizer; calculate approximate raw weight storage at 16-bit: `9e9 parameters × 2 bytes ≈ 18 GB` decimal before overhead. This is a lower-bound estimate, not the full runtime footprint.

**Competition application:** Understand why max output tokens, prompt templates, chat templates, Thai tokenization, and tool-call formatting affect speed and correctness.

**Mastery:** Explain how input text becomes next-token probabilities and why a request's prompt/output length matters.

**Common mistakes:** Treating a token as a word; assuming temperature changes speed materially; assuming model size equals total VRAM requirement; changing chat templates and blaming the kernel for quality changes.

### Stage 2 — GPU, numerical formats, and energy

**Priority:** Must know basics; should know profiling details. **Prerequisites:** Stage 1.

**Concept checklist:** GPU; SM (streaming multiprocessor); CUDA core; Tensor Core; VRAM/HBM; memory bandwidth; cache; register/shared memory; kernel; FLOP/FLOPS; TOPS; arithmetic intensity; compute-bound; memory-bound; occupancy; launch overhead; CPU/RAM/storage/network; watts; joules; energy measurement.

**Plain-English explanations:**
- GPU compute is many parallel execution units running kernels. Tensor Cores accelerate supported matrix operations and data formats.
- VRAM is capacity; bandwidth is how quickly data can be moved. A model can fit in memory but still be slow because weights or cache must be moved repeatedly.
- A **FLOP** is a floating-point operation; **FLOPS** is a rate. These peak rates are not application throughput guarantees.
- **Compute-bound** means arithmetic throughput is the main limit. **Memory-bound** means data movement is the main limit. A workload can shift between them by phase and batch size.
- **Power** is a rate of energy use (watts = joules/second). **Energy** over an interval is `E = ∫ P(t) dt`; with sampled telemetry, approximate it by summing `power × time interval`.

**Hardware anchor:** NVIDIA's A100 Ampere family supports Tensor Core operations including BF16, FP16, TF32, INT8, and INT4; the 40 GB A100 variant is commonly specified with about 1.555 TB/s HBM bandwidth. Exact peak throughput and power limits vary by PCIe/SXM SKU and system configuration; check the actual device with `nvidia-smi` and the installed environment. Official A100 datasheet and architecture resources are listed below.

**Numerical formats:**
- **FP32:** higher precision and larger storage; often not the best inference default.
- **BF16:** 16-bit format with FP32-like exponent range and fewer mantissa bits; often robust for model inference.
- **FP16:** 16-bit floating point with a narrower exponent range than BF16.
- **FP8:** 8-bit floating-point formats; hardware/library support and calibration/scaling details matter.
- **INT8/INT4:** integer representations, often used for quantized weights. Effective quality depends on scaling, group/channel granularity, outliers, and kernels.

**Backend connection:** Think of GPU memory bandwidth as database I/O bandwidth and Tensor Core throughput as specialized vectorized compute. A CPU utilization graph alone does not tell you whether the GPU is saturated.

**Exercises:** Capture GPU model, free memory, power draw, clocks, temperature, utilization, and memory use during idle, model load, prefill, decode, and full benchmark. Compare GPU energy with total system energy if the organizer specifies a boundary; do not substitute one for the other.

**Competition application:** Determine whether to target memory traffic, compute, batch scheduling, CPU tokenization, or energy-per-useful-request.

**Mastery:** Explain why lower precision may reduce memory traffic yet fail to improve end-to-end latency, and distinguish W from J.

**Common mistakes:** Using peak TFLOPS as predicted speed; comparing runs with different clocks/thermal conditions; measuring instantaneous watts instead of integrated joules; assuming GPU utilization alone identifies the bottleneck.

### Stage 3 — Inference server architecture and request behavior

**Priority:** Must know. **Prerequisites:** Stages 1–2.

**Concept checklist:** model loading; warmup; prefill; decode; batch; dynamic/continuous batching; scheduler; request queue; concurrency; backpressure; streaming; TTFT; TPOT/ITL; end-to-end latency; p50/p95/p99; throughput; open-loop load; arrival rate; queueing; cancellation; timeouts; tool calls; multi-turn agents; chat templates; usage accounting.

**Prefill versus decode:** Prefill processes the input tokens to establish model state and produce the first next-token distribution. Decode repeatedly generates the next token. Prefill often has larger parallel matrix work; decode often repeatedly reads model weights and is sensitive to batch size and memory bandwidth. This is a tendency, not a universal law.

**Continuous batching:** Instead of waiting for a fixed batch to finish, a serving engine can admit new requests and remove completed ones between generation steps. It improves GPU utilization under mixed request lengths but adds scheduler and cache-management complexity.

**Caching:** A Transformer commonly caches key/value tensors for prior tokens to avoid recomputing them on every decode step. A hybrid Mamba/Gated-DeltaNet model may have a mixture of attention KV cache and recurrent/convolutional state. Do not assume all layers use the same cache layout. Verify how the actual model and vLLM version implement hybrid state management.

**Metrics:**
- **TTFT** (time to first token) = first output-token time minus request arrival time, subject to the grader's exact start/end event definitions.
- **TPOT** (time per output token) often means `(completion latency − TTFT)/(output tokens − 1)` or a related convention. Verify the evaluator's formula, especially for one-token outputs.
- **ITL** (inter-token latency) is the time between successive generated tokens.
- **End-to-end latency** runs from request arrival to completion.
- **Throughput** can mean requests/second, output tokens/second, or successful/on-time requests per second. Never assume which one the grader uses.
- **p95** is the 95th percentile: 95% of observations are at or below it. It is a tail measure, not an average.

**Open-loop versus closed-loop load:** Open-loop generators issue requests according to a schedule regardless of previous response completion. This avoids the coordinated-omission trap where a slow service automatically receives less offered load. Arrival rate, ramp, peak, quiet, and drain periods must be interpreted from the official test plan.

**Agentic workload:** One user task may create several model calls, tool calls, and follow-up prompts. It can increase total generated tokens and prompt lengths, and may produce bursts or dependencies. A correct tool call must preserve the expected structured format, not merely mention a tool in prose.

**Backend connection:** Continuous batching is a specialized work-conserving scheduler; the KV/state cache is per-request state; streaming is chunked response delivery; backpressure prevents unlimited queue growth; tail latency reflects queueing and interference.

**Exercises:** Send a short prompt, a long prompt, a short output, and a long output. Record TTFT, TPOT, end-to-end latency, tokens, errors, and queue behavior. Repeat under concurrency and mixed prompt lengths.

**Mastery:** Explain why a throughput improvement may worsen TTFT or p95, and why longer output changes both latency and energy.

**Common mistakes:** Reporting only average latency; confusing model tokens/sec with requests/sec; comparing closed-loop and open-loop results; assuming API compatibility guarantees correct streaming/tool calling.

### Stage 4 — Hybrid Mamba/Gated-DeltaNet architecture

**Priority:** Must know the high-level differences; advanced to implement kernels. **Prerequisites:** Stages 1–3.

**Concept checklist:** self-attention; KV cache; state-space model (SSM); recurrent state; selective state update; linear attention; Delta rule; gate; hybrid layer stack; recurrent inference; architecture-specific kernels.

**Conventional attention:** A query compares with keys from prior tokens and uses the resulting weights to combine values. Full attention typically has sequence-length-dependent memory and computation; caching K/V avoids recomputing previous projections but the cache grows with context.

**Mamba:** A selective state-space model uses input-dependent state updates so the recurrent state selectively retains or forgets information. This can yield linear scaling with sequence length for relevant operations, but kernel efficiency and quality depend on implementation and workload. It is not simply “attention without cost.”

**Gated DeltaNet:** Combines gating-based memory control with a delta-rule update that modifies a compact recurrent memory. It is designed to make targeted updates to the state. A hybrid architecture can combine recurrent/linear-attention layers with conventional attention layers to balance efficiency and retrieval behavior.

**Implication for MANGO:** The model name in the prompt suggests architecture-specific state/cache behavior. Confirm layer types, configuration, and supported vLLM implementation. Generic advice about Transformer KV cache, attention backends, speculative decoding, and quantization may not transfer uniformly to every hybrid layer.

**Exercises:** Inspect `config.json`, model architecture names, layer list, dtype, tokenizer, and runtime logs. Identify supported attention/state backends in the installed engine. Check whether cache settings are hybrid-aware.

**Competition application:** Prioritize tested engine support and correctness before attempting a different engine or custom kernel. Architecture mismatches can lead to unsupported paths, fallback kernels, memory inefficiency, or wrong outputs.

**Mastery:** Explain the difference between a growing attention cache and a compact recurrent state, and why hybrid models need layer-aware serving support.

**Common mistakes:** Assuming every layer uses attention; assuming linear-time architecture guarantees fastest wall-clock latency; transferring a kernel optimization from a standard Transformer without verifying compatibility.

### Stage 5 — Establish a valid baseline and measurement harness

**Priority:** Must know. **Prerequisites:** Stages 0–4.

**Baseline checklist:** exact model/checkpoint; exact tokenizer and chat template; engine and library versions; launch command; dtype; GPU model and driver; environment variables; seed/sampling settings; max context/output limits; endpoint semantics; tool calling; streaming; warmup; load schedule; telemetry source; test dataset/version; scoring script version.

**Protocol:**
1. Read all rules and record unknowns.
2. Launch the unmodified reference configuration (the prompt identifies BF16/vLLM as a baseline to establish; verify the briefing says this).
3. Wait for load and warmup to complete. Separate cold-start and steady-state metrics if relevant.
4. Run a small smoke test for basic chat, streaming, tool call, Thai, long prompt, long output, and errors.
5. Run the official validation workload unchanged.
6. Save raw logs, outputs, server logs, GPU telemetry, and exact command/environment.
7. Repeat enough times to estimate run-to-run variation.

**Energy:** If telemetry gives power samples `P_i` in watts at intervals `Δt_i` seconds, approximate energy as `E_J ≈ Σ P_i Δt_i`. If using cumulative energy counters, subtract start from end and check units. Include only the energy boundary specified by the grader. Report warmup and idle inclusion explicitly.

**Experiment log columns:** ID; date; code commit; model hash; engine version; config diff; hypothesis; workload; repetitions; accuracy; accuracy retention; TTFT/p95; TPOT; throughput; SLO pass rate; GPU joules; joules/useful request; score components; final score; failure notes; decision.

**Mastery:** Another person can reproduce your run from the log.

**Common mistakes:** Changing multiple flags at once; running a benchmark during another GPU process; omitting warmup; comparing different output lengths; logging only a screenshot of aggregate metrics.

### Stage 6 — Low-risk serving optimizations

**Priority:** Must know how to test; should know internals. **Prerequisites:** Stage 5.

**Candidates:** batch token budget; max active sequences; chunked prefill; prefix caching; scheduling policy; CPU/API worker capacity; CUDA graphs/compilation options; startup versus steady-state trade-offs; memory allocation; hybrid cache manager settings.

**How to reason:** A larger batched-token budget may help TTFT or throughput but let long prefills delay decode. A smaller budget may improve inter-token latency while lowering peak throughput. Prefix caching helps only when prompts share reusable prefixes and the engine supports the relevant model state. More concurrent sequences can improve GPU utilization until cache pressure, preemption, or queueing makes latency worse.

Official vLLM tuning documentation explains these trade-offs and notes that preemption/recomputation can hurt latency; chunked prefill balances prefill and decode workloads. Use the documentation for your installed vLLM release, since defaults and flags evolve.

**Exercises:** Change one setting per experiment. Measure quality, TTFT, TPOT, p95, throughput, preemptions, memory, and joules. Repeat under the actual mixed workload, not only a single prompt.

**Mastery:** Explain the observed effect in terms of queueing, cache pressure, prefill/decode interference, or CPU overhead.

### Stage 7 — Precision, quantization, and model artifacts

**Priority:** BF16/FP16 must know; quantization should know; pruning/fine-tuning advanced and rule-dependent. **Prerequisites:** Stages 1, 2, and 5.

**Precision/quantization concepts:**
- **BF16/FP16:** 16-bit floating-point choices. BF16 has a wider exponent range; actual speed is determined by supported kernels and workload.
- **FP8:** 8-bit floating point; scaling, calibration, layer coverage, and engine support determine practical results.
- **INT8/INT4:** quantized integer weights/activations; lower storage can reduce bandwidth and memory needs, but dequantization and kernel choices matter.
- **Weight-only quantization:** compress weights while activations remain at a higher precision; W4A16 means 4-bit weights and 16-bit activations in the common shorthand.
- **AWQ:** activation-aware weight quantization; calibration helps identify weight channels/values whose quantization matters most.
- **Calibration:** representative samples are used to choose scales or transformations; calibration data should reflect task/language/context distributions.
- **Pruning:** remove weights/structures; sparse representation only helps if the hardware and kernels exploit it.
- **Weight conversion:** transform a checkpoint to a supported layout/precision. This is distinct from training and may be constrained by rules.
- **Fine-tuning/distillation:** change model behavior or create a smaller student. Only consider if the event explicitly permits it; verify artifact and training restrictions first.

**Benefits and failure modes:** Quantization can reduce weight memory and data movement, potentially allowing larger batches. It can also degrade accuracy, Thai performance, code/reasoning behavior, tool-call structure, or long-context recall. Some quantization formats lack an efficient kernel for a particular architecture; then the smaller model can be slower.

**Exercises:** First test any organizer-provided compatible checkpoint. Compare outputs against BF16 on a representative evaluation slice, then run the full official validation suite. Track accuracy by category/language and not only aggregate accuracy.

**Mastery:** Explain why “4-bit” does not mean exactly one quarter of total VRAM or exactly four times the speed.

### Stage 8 — KV/state cache, speculative decoding, kernels, and engine alternatives

**Priority:** Cache behavior should know; speculative decoding and kernel changes advanced. **Prerequisites:** Stages 3–7.

**KV cache/prefix cache:** Reuses previous attention keys/values or common prompt computation. Benefits depend on prefix reuse and model architecture. Costs include memory, hashing/lookup, cache fragmentation, and possible interference. For hybrid recurrent layers, the cached state is not necessarily ordinary KV tensors.

**Speculative decoding:** A smaller draft model proposes tokens and the target model verifies them. It helps when the draft's proposals are accepted often enough and verification is efficient. It can lose when draft compute, synchronization, memory, or acceptance rate offsets savings. Model compatibility and rules must be checked.

**MTP (multi-token prediction):** An architecture/training feature that may provide additional prediction heads or future-token information. Do not assume the supplied checkpoint supports it or that vLLM can exploit it.

**Kernel/attention optimization:** Fused operations reduce launch and intermediate-memory overhead. FlashAttention-style algorithms reduce memory traffic for attention; they do not automatically optimize recurrent Mamba/DeltaNet layers. Custom kernels require correctness tests and often extensive hardware-specific work.

**Engine alternatives:**
- **vLLM:** strong focus on high-throughput serving and continuous batching; best starting point if it is the official baseline and supports the model.
- **SGLang:** serving runtime with request/radix/prefix caching and structured generation features; verify hybrid architecture and API compatibility.
- **TensorRT-LLM:** NVIDIA-oriented optimized inference stack; can offer strong performance but conversion/build effort and model support are key risks.
- **llama.cpp:** broad quantized CPU/GPU inference ecosystem; compatibility with the exact hybrid model, required endpoint semantics, and A100 efficiency must be established.

**Experiment gate:** Before migrating engines, verify (1) model architecture support, (2) identical request semantics, (3) streaming/tool call compatibility, (4) quality retention, (5) measurement parity, and (6) startup/operational stability.

### Stage 9 — Energy-aware optimization and score-aware decisions

**Priority:** Must know energy measurement; advanced power tuning. **Prerequisites:** Stages 0, 2, and 5.

**Core distinctions:**
- Watts = instantaneous rate of energy consumption.
- Joules = energy accumulated over a time interval.
- Joules/request = energy divided by the specified request count; if only successful/on-time requests count, the denominator must follow the briefing.
- Useful requests/joule = useful completed requests divided by joules; it is not interchangeable with tokens/second.

**Power controls:** GPU power caps and clock settings can lower instantaneous power but also lower throughput or increase latency. Energy can fall even if power stays similar when runtime falls; conversely a faster, higher-power run can consume more joules. Test end-to-end energy per useful request under the actual workload.

**General equation:** `E = ∫ P(t) dt`. For a steady average `P_avg` over `T`, `E ≈ P_avg × T`. Example: 250 W for 40 s is approximately 10,000 J. If 800 requests are useful, energy per useful request is 12.5 J/request. This is an illustrative calculation, not an official score.

**Mastery:** You can tell whether a proposed optimization improves the metric the grader actually rewards and whether it crosses a hard SLO boundary.

### Stage 10 — Validation, submission discipline, and final pitch

**Priority:** Must know. **Prerequisites:** All previous stages.

**Workflow:** Freeze a candidate; run smoke tests; run validation; compare every score component and hard gate; inspect per-category accuracy and errors; repeat to check noise; preserve artifact hashes and launch instructions; only then use a limited final submission. Never tune directly to hidden tests or exploit evaluator behavior.

**Pitch:** Explain the baseline, bottleneck evidence, hypothesis, controlled experiment, result, trade-offs, energy impact, limitations, and reproducibility. Distinguish measured facts from interpretation. A failed experiment is valuable if it narrows the bottleneck hypothesis.

**Mastery:** Defend why the final configuration is better under the actual score, not merely faster in one metric.

## 3. Metrics and scoring reference

### Important source boundary

The supplied prompt names the metrics and says the briefing contains a logarithmic energy score, baseline, clipping, saturation, component scores, final technical score, five conditions for useful work, and weighted pitch ranking. It does **not** provide their exact equations or numeric values. The formulas below are general metric definitions only; they are not substitutes for the official score sheet.

| Metric / term | General definition | Example / interpretation | What to verify in briefing |
|---|---|---|---|
| Accuracy | Fraction of evaluated items judged correct under the evaluator's rule | 90 correct of 100 = 90% | Exact judge, dataset, normalization, category weighting |
| Per-class accuracy | Accuracy computed separately for each class/category | Thai 80%, coding 92% | Which categories/classes and whether macro averaging applies |
| Macro-accuracy | Unweighted mean of class accuracies: `(1/K) Σ accuracy_k` | Class scores 80%, 90% → 85% | Exact class definitions and treatment of missing classes |
| Baseline accuracy | Accuracy of the designated reference configuration | Reference run is the denominator/reference | Exact baseline artifact/config and dataset |
| Accuracy retention | Often candidate accuracy divided by baseline accuracy, expressed as a ratio/percentage | 0.95 / 1.00 = 95% retention | Exact formula, whether absolute or relative loss is used |
| Relative accuracy loss | Commonly `(baseline − candidate) / baseline` | 1.00 to 0.95 = 5% relative loss | Whether loss uses macro accuracy or another value |
| Accuracy factor `A` | Event-specific score factor based on accuracy/retention | **Unknown until official formula is supplied** | Exact formula, floors, thresholds, clipping |
| SLO | Service-level objective; request performance/correctness constraints | A request may be disqualified if a condition fails | Five exact useful-work conditions and thresholds |
| TTFT | Time from the defined request start to first generated token | 0.4 s first-token delay | Exact timestamp boundaries and percentile |
| TPOT | Average time per generated output token under the evaluator's convention | 20 tokens over 1.9 s after first token ≈ 0.1 s/token | Formula for one-token outputs and exact timing boundaries |
| p95 latency | 95th percentile of measured latency | p95 = 2 s means 95% of samples are ≤ 2 s | Which requests, percentile method, normalization |
| Throughput | Work completed per unit time | 100 requests / 20 s = 5 req/s | Requests, tokens, useful requests, or on-time requests? |
| Arrival rate `λ` | Offered requests per second | 10 requests/s offered | Exact open-loop schedule and ramp/peak/quiet/drain periods |
| Energy `E` | Integrated power over the defined measurement interval | 250 W × 40 s ≈ 10 kJ | GPU-only vs system, warmup/idle inclusion, telemetry source |
| Energy/request | Energy divided by the specified request count | 10 kJ / 800 = 12.5 J/request | Whether denominator includes all, successful, or on-time requests |
| Useful requests/J | Useful completed requests divided by energy | 800 / 10 kJ = 0.08 useful requests/J | Official definition of “useful” and measurement window |
| Energy score `s_E` | Event-specific score with a stated logarithmic form | **Cannot reconstruct without formula/constants** | Baseline, log base, scale, clipping, saturation |
| Throughput score `s_T` | Event-specific normalized throughput score | **Unknown** | Normalizer, cap, whether SLO failures count |
| Latency score `s_L` | Event-specific normalized latency score | **Unknown** | TTFT/TPOT/p95 combination and normalization |
| Final technical score `S` | Event-specific combination of score components and accuracy factor | **Unknown** | Exact equation, weights, gates, rounding order |
| Pitch/final ranking | Weighted combination of technical and pitch-round criteria | **Unknown** | Criteria, weights, tie-breaks, eligibility requirements |

### Illustrative formulas (general, not official scoring equations)

- Macro accuracy: `MacroAcc = (1/K) × Σ(k=1..K) Acc_k`.
- Relative accuracy loss: `Loss_rel = (Acc_base − Acc_candidate) / Acc_base`, if `Acc_base > 0`.
- Accuracy retention: `Retention = Acc_candidate / Acc_base`, if the briefing defines it this way.
- Average throughput: `Throughput = completed_work / measurement_duration`.
- Energy: `E_J ≈ Σ_i P_i(W) × Δt_i(s)`.
- Energy per useful request: `J_per_useful = E_J / N_useful`.
- Useful requests per joule: `Efficiency = N_useful / E_J`.
- Percentile: sort observations; p95 is the value at the 95th percentile under the selected percentile convention.

### Worked example: why faster may score worse

Suppose two candidate runs process the same nominal 1,000-request workload. These numbers are invented solely to demonstrate the trade-off.

| Metric | Candidate X | Candidate Y |
|---|---:|---:|
| Wall time | 80 s | 65 s |
| GPU energy | 20 kJ | 22 kJ |
| Useful/on-time requests | 980 | 900 |
| Useful requests/joule | 0.049 | 0.0409 |

Candidate Y is faster in wall-clock time but consumes more energy and completes fewer useful requests. Its useful-request energy efficiency is worse. If the official score rewards energy efficiency and requires requests to satisfy hard SLO conditions, Y could lose despite its raw speed. The actual outcome depends on the missing official scoring equation.

### Hard gates versus continuous rewards

Create two separate columns in your score sheet:

1. **Hard eligibility/SLO conditions:** pass/fail or request qualification rules. Failure may invalidate a submission, exclude requests, or cap the score.
2. **Continuous score terms:** values that smoothly affect a component score, possibly with clipping or saturation.

Do not assume the distinction for any particular event metric until you read the official rules. Ask the organizers to clarify boundary equality, missing/failed requests, retries, malformed tool calls, and how a run is scored when a component has zero valid samples.

## 4. Practical competition workflow

### Phase A — Inventory and baseline

- [ ] Obtain the complete organizer briefing and write down every exact formula and threshold.
- [ ] Record model artifact, config, tokenizer, engine, CUDA/driver/PyTorch versions, GPU SKU, and launch command.
- [ ] Establish the BF16/vLLM reference run if that is the official baseline.
- [ ] Verify API compatibility: chat, streaming, tool calls, stop conditions, errors, usage fields, and request cancellation.
- [ ] Run smoke tests across chat, RAG-like long prompts, agent/tool calls, reasoning/coding, Thai, and long context.
- [ ] Save outputs and telemetry; run validation repeatedly to estimate noise.

### Phase B — Diagnose before optimizing

- [ ] Is the GPU saturated during prefill and decode?
- [ ] Is the workload dominated by long input, long output, or concurrency?
- [ ] Are TTFT and TPOT both bad, or only one?
- [ ] Are cache preemptions, out-of-memory errors, or queue growth present?
- [ ] Is CPU tokenization/template rendering/streaming a bottleneck?
- [ ] Does power rise while useful throughput remains flat?
- [ ] Does the same config behave differently across languages or request categories?

### Phase C — High-value experiment queue

| Order | Hypothesis / experiment | Potential benefit | Main risk | Measure |
|---|---|---|---|---|
| 1 | Reproduce baseline across multiple runs | Establish noise floor and valid comparison | Time cost | All official metrics, variance |
| 2 | Tune `max_num_batched_tokens` / chunked prefill | Improve prefill/decode balance | TTFT/TPOT trade-off | TTFT, TPOT, p95, throughput, energy |
| 3 | Tune max concurrent sequences / cache allocation | Improve utilization or reduce preemption | OOM, queueing, tail latency | Cache use, preemptions, SLO pass rate |
| 4 | Test prefix caching on repeated-prefix workload | Reduce repeated prefill work | No benefit without reuse; cache overhead | Cached tokens, TTFT, energy |
| 5 | Check CPU/API processing saturation | Improve tokenization, streaming, scheduling | Extra processes add overhead | CPU, queue delay, GPU idle gaps |
| 6 | Test a supported lower-precision or quantized artifact | Reduce weight memory/bandwidth | Accuracy loss or slower unsupported kernels | Per-category accuracy, latency, energy |
| 7 | Test speculative decoding only if supported | Reduce target decode steps | Draft overhead / low acceptance | Acceptance rate, TPOT, energy, quality |
| 8 | Test engine alternative in a separate branch | Better kernels/scheduler possible | Compatibility, conversion, correctness | Full parity suite and official score |
| 9 | Test GPU power/clock settings if permitted | Lower joules per useful request | Lower throughput or SLO violations | Power, duration, useful requests/J |
| 10 | Custom kernels / architecture-specific changes | Potential high upside | High engineering and correctness risk | Microbench + full validation |

These are hypotheses, not promised wins. Do not move to a riskier experiment before preserving the best known configuration.

### Phase D — Controlled experiment rules

1. One independent change per experiment; record every config diff.
2. Use the same workload, arrival schedule, random seeds where applicable, warmup, measurement window, and hardware state.
3. Repeat runs; compare medians and spread, not a single lucky result.
4. Keep raw per-request records, not just aggregates.
5. Evaluate correctness and API semantics before comparing speed.
6. Keep category-level metrics so an aggregate does not hide Thai/coding/tool-call regression.
7. Use the actual official scoring formula to rank candidates.
8. Maintain a rollback path and a frozen “best-known” artifact.
9. Avoid hidden-test overfitting and never exploit grader bugs.
10. Save a final reproducibility bundle: launch script, environment, artifact hashes, logs, and known limitations.

## 5. Diagnostic guide

| Symptom | Plausible causes | First experiment |
|---|---|---|
| High TTFT, acceptable TPOT | Long prefill, queueing, tokenizer/template overhead, large prompt batches | Split TTFT into queue/preprocess/prefill where possible; vary batched-token budget |
| Good TTFT, poor TPOT | Decode bandwidth/compute bottleneck, low batching, cache pressure, inefficient kernels | Measure decode throughput and active sequences; test supported batch/cache settings |
| Good average, poor p95 | Queue bursts, long requests starving short ones, preemption, CPU contention | Inspect per-request traces and request-length mix; test chunked prefill/scheduling |
| High GPU utilization but poor throughput | Inefficient kernels, memory stalls, too much padded/wasted work, synchronization | Profile kernel/memory behavior; compare tokens/s and useful requests/s |
| Low GPU utilization | CPU bottleneck, small batches, request gaps, API bottleneck, unsupported fallback | Check CPU, engine logs, GPU idle gaps, kernel/backend selection |
| OOM or frequent preemption | Too many sequences, long contexts, insufficient cache headroom | Reduce concurrency or context limits; inspect cache allocation and preemption counters |
| Lower precision is slower | Unsupported/inefficient kernel, conversion overhead, poor batching, CPU offload | Verify kernel path and benchmark same workload; check engine support matrix |
| Faster but lower accuracy | Quantization, changed sampling, tokenizer/template mismatch, altered model artifact | Compare exact outputs and category-level evaluation; restore settings one by one |
| Lower watts but higher joules | Longer runtime outweighs power reduction | Compare integrated energy and useful work, not watts alone |
| Energy score varies run to run | Telemetry sampling, clock/thermal variance, warmup, unrelated GPU work | Repeat under controlled conditions; use same energy boundary and timing window |
| Tool calls fail while plain chat passes | Chat template, structured output, parser, stream chunk semantics, API mismatch | Run exact tool-call tests and inspect raw streamed chunks |
| Thai quality or token cost degrades | Tokenization distribution, quantization sensitivity, dataset imbalance | Report Thai-specific accuracy, tokens, and latency separately |

## 6. Dependency map in compact form

`Grader/rules → model/token basics → GPU/precision basics → serving phases/metrics → architecture-aware cache/state → baseline harness → low-risk scheduling → quantization/decoding/engine experiments → score-aware validation → pitch`.

Do not skip from “I can launch the server” directly to quantization or custom kernels. The baseline and measurement harness are prerequisites for interpreting whether an optimization helped.

## 7. Categorized glossary

### Model and ML terms

- **Autoregressive generation:** Repeatedly predicts the next token conditioned on prior tokens. Practical impact: output length directly influences decode work and energy.
- **Attention:** Computes relevance between query and key vectors and mixes value vectors. Related: KV cache, context length, attention kernels.
- **Checkpoint:** Serialized model weights/configuration/tokenizer assets. Practical impact: hash and preserve exact artifact identity.
- **Embedding:** Vector representation associated with a token ID. Related: vocabulary, hidden state.
- **Feed-forward network / MLP:** Per-token neural transformation inside a model block. Often a large share of model compute.
- **Hidden state:** Intermediate vector representation computed by layers.
- **Logits:** Raw output scores before normalization. Related: softmax and sampling.
- **Normalization:** Layer operation that stabilizes activation scale/distribution.
- **Parameter/weight:** Learned scalar used by the network. Parameter count approximates weight storage but not total runtime memory.
- **Sampling:** Rule for selecting the next token from scores/probabilities. Related: temperature, top-k, top-p, seed.
- **Softmax:** Converts logits into normalized probabilities: `p_i = exp(z_i)/Σ exp(z_j)`.
- **Token/tokenizer:** Processing unit and text-to-ID mapping. Token count affects prompt and output costs.
- **Vocabulary:** Set of token IDs the model can emit.
- **Context window:** Maximum supported sequence/context size under a configuration; longer inputs may increase memory and latency.

### Architecture and inference terms

- **Decode:** Iterative generation phase after prefill; generates output tokens.
- **Mamba:** Selective state-space model family using input-dependent state updates; relevant to recurrent-state inference.
- **Gated DeltaNet:** Linear/recurrent attention mechanism using gating and delta-rule memory updates.
- **Hybrid model:** Model combines different layer families; each family may have different state/cache behavior.
- **Inference:** Running a trained model without updating its weights.
- **KV cache:** Cached attention keys and values from earlier tokens, avoiding repeated computation.
- **Prefill:** Processes prompt tokens and initializes model state before/while producing first-token logits.
- **Speculative decoding:** Draft-and-verify approach that can reduce target-model decode work when proposals are accepted efficiently.
- **MTP:** Multi-token prediction; model-specific feature, not automatically available to every checkpoint/runtime.
- **Continuous batching:** Dynamically schedules active requests across generation steps.
- **Backpressure:** Limits incoming work or queue growth when downstream capacity is constrained.
- **Prefix caching:** Reuses computation/state for repeated prompt prefixes when supported.
- **Preemption:** Scheduler interrupts/recomputes or otherwise reclaims resources from a request when cache/resources are insufficient.

### GPU, performance, and energy terms

- **A100:** NVIDIA Ampere data-center GPU family; verify exact 40 GB SKU and runtime limits.
- **Arithmetic intensity:** Operations performed per byte moved; helps reason about compute- versus memory-bound kernels.
- **Bandwidth:** Amount of data transferred per second; HBM bandwidth is important for weight-heavy decode.
- **CUDA:** NVIDIA's GPU programming platform and execution model.
- **CUDA graph:** Captured sequence of GPU operations that can reduce CPU launch overhead in supported cases.
- **FLOP/FLOPS:** Floating-point operation / rate of operations.
- **HBM:** High-bandwidth GPU memory.
- **Kernel:** GPU function executed on the device.
- **Memory-bound/compute-bound:** Performance limited primarily by data movement / arithmetic throughput.
- **Occupancy:** How much of the GPU's execution capacity is active with resident warps/blocks; not a score by itself.
- **SM:** Streaming multiprocessor, a major GPU execution unit.
- **Tensor Core:** Specialized hardware for matrix/tensor arithmetic.
- **VRAM:** GPU memory capacity; different from memory bandwidth.
- **Watt (W):** Joule per second, a power unit.
- **Joule (J):** Energy unit; energy is power integrated over time.
- **Energy per useful request:** Energy divided by the count of requests meeting the official useful-work definition.

### Precision and optimization terms

- **BF16:** 16-bit floating point with a wide exponent range; common baseline format.
- **FP16:** 16-bit floating point with narrower exponent range than BF16.
- **FP8:** 8-bit floating-point family; scaling and kernel support matter.
- **INT8/INT4:** 8-/4-bit integer quantization formats.
- **Quantization:** Represents weights and/or activations with fewer bits to reduce memory and potentially computation.
- **Weight-only quantization:** Quantizes weights while activations use higher precision.
- **W4A16:** Common shorthand for 4-bit weights and 16-bit activations.
- **AWQ:** Activation-aware Weight Quantization, using activation-informed methods to preserve important weights during low-bit compression.
- **Calibration:** Uses representative inputs to determine quantization scales or transformations.
- **Pruning:** Removes weights or structures; speed gains depend on sparse-kernel support.
- **Distillation:** Trains a smaller model to imitate a larger model; permission and artifacts are rule-dependent.
- **Kernel fusion:** Combines operations to reduce launch overhead and intermediate memory traffic.

### Evaluation and serving metrics

- **Accuracy:** Correctness rate under a defined evaluator.
- **Accuracy retention:** Candidate accuracy relative to a designated baseline; exact event formula must be checked.
- **Macro-accuracy:** Mean of class-level accuracies, giving equal weight to each class.
- **SLO:** Service-level objective, a target/constraint for correctness, latency, or completion.
- **TTFT:** Time to first token.
- **TPOT:** Time per output token under the evaluator's exact convention.
- **ITL:** Inter-token latency.
- **Latency:** Time between defined request start and end events.
- **p50/p95/p99:** 50th/95th/99th percentile of a metric.
- **Throughput:** Work completed per unit time; specify requests, tokens, or useful requests.
- **Open-loop load:** Request arrivals follow a schedule independent of prior completions.
- **Arrival rate:** Offered requests per unit time.
- **Ramp/peak/quiet/drain:** Phases of a load schedule; exact durations/rates come from the briefing.
- **Baseline:** Designated reference configuration or score.
- **Clipping/saturation:** Score behavior that caps values beyond a boundary; exact formula is event-specific.
- **`s_E`, `s_T`, `s_L`, `A`, `S`:** Event-specific energy, throughput, latency, accuracy, and total-score symbols. Do not infer their formula from notation alone.

### API and systems terms

- **OpenAI-compatible API:** An API that matches a defined request/response interface; compatibility is not guaranteed for every optional field or behavior.
- **SSE/streaming:** Incremental response delivery, often via server-sent events; test chunk boundaries and final usage metadata.
- **Tool calling:** Structured model output requesting an external function/action; correctness includes the schema and protocol, not only the semantic intent.
- **RAG:** Retrieval-augmented generation; retrieved documents increase prompt length and can introduce repeated prefixes.
- **Agentic workload:** Multi-step interaction involving model calls and tools.
- **Reproducibility:** Ability to repeat an experiment with controlled artifacts/configuration and obtain comparable results.
- **Profiling:** Measuring where time/resources are spent.
- **Telemetry:** Recorded operational measurements such as power, utilization, memory, and latency.
- **Coordinated omission:** A load-testing artifact where a generator sends fewer requests during slowdowns, underreporting the impact on latency.

## 8. External learning resources

Use current documentation for the installed release and treat performance advice as a hypothesis to test on the exact model/GPU.

1. vLLM optimization and tuning: https://docs.vllm.ai/en/stable/configuration/optimization/ — chunked prefill, cache pressure, preemption, and CPU-side serving considerations.
2. vLLM OpenAI-compatible server: https://docs.vllm.ai/en/stable/serving/openai_compatible_server/ — API behavior and supported interfaces.
3. NVIDIA A100 datasheet: https://resources.nvidia.com/en-us-gpu-resources/nvidia-a100-datashee-1 — SKU-dependent compute, memory, and power specifications.
4. NVIDIA Ampere architecture overview: https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/ — Tensor Cores, memory hierarchy, and A100 architecture.
5. Mamba paper: https://arxiv.org/abs/2312.00752 — selective state-space modeling and sequence-length scaling.
6. Gated Delta Networks paper: https://arxiv.org/abs/2412.06464 — gating and delta-rule updates; hybrid architectures.
7. Hugging Face quantization overview: https://huggingface.co/docs/transformers/main/en/quantization/overview — formats and supported methods.
8. Hugging Face AWQ documentation: https://huggingface.co/docs/transformers/main/en/quantization/awq — AWQ concepts and implementation caveats.
9. NVIDIA DCGM documentation: https://docs.nvidia.com/datacenter/dcgm/latest/ — GPU monitoring, power and energy telemetry.
10. CUDA programming model refresher: https://developer.nvidia.com/blog/cuda-refresher-cuda-programming-model/ — GPU execution and memory hierarchy.

## 9. Final mastery checklist

### Rules and scoring
- [ ] I can state every hard eligibility gate and useful-request condition exactly.
- [ ] I can write down the exact `A`, `s_E`, `s_T`, `s_L`, and `S` formulas from the briefing.
- [ ] I know all score thresholds, clipping/saturation rules, and pitch weights.

### Model and serving
- [ ] I can explain tokens, logits, sampling, prefill, decode, and model state.
- [ ] I can explain why this hybrid architecture differs from a conventional Transformer.
- [ ] I can verify the endpoint, streaming, tool calling, Thai, and long-context behavior.

### Measurement and optimization
- [ ] I can reproduce the baseline from a written environment/configuration record.
- [ ] I can calculate throughput, p95, accuracy retention, and energy using the official definitions.
- [ ] I can identify whether a bottleneck is CPU, queueing, prefill, decode, memory, compute, or cache pressure.
- [ ] I can run one-variable experiments with repeated trials and category-level correctness checks.
- [ ] I can explain why each tested optimization helped or failed.
- [ ] I can select the best configuration using the official score rather than raw speed.

### Final submission and pitch
- [ ] I have a frozen best-known configuration and rollback path.
- [ ] I have validation results, raw logs, telemetry, hashes, and launch instructions.
- [ ] I can quantify energy impact and distinguish measurement from hypothesis.
- [ ] I can present the bottleneck, experiment, result, trade-offs, limitations, and reproducibility clearly.

## 10. Immediate next actions

1. **Get the full official briefing.** The exact score equations and thresholds are essential and cannot be reconstructed from the supplied prompt summary.
2. **Run the unmodified baseline.** Save environment, model/config hashes, official workload outputs, per-request metrics, and GPU energy telemetry.
3. **Build the experiment ledger.** Then test one low-risk serving setting at a time and score every candidate using the actual evaluator.

**Rule of thumb:** Never call an optimization a win until it preserves required behavior, passes the hard conditions, improves the relevant official score, and can be reproduced.

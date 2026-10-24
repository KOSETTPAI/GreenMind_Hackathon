# 7. Measurement Window

**Stage:** 0 | **Priority:** Must know | **Prerequisites:** [Workload Mix](6_Workload_Mix.md)

## In one sentence
The measurement window is the exact time interval (start and end events) over which the grader counts requests, latency, throughput, and energy.

## Plain-English explanation
"How much energy did you use?" depends on *when* you start and stop the stopwatch. Does it include model loading? Warmup? Idle time before the first request? The drain period after the last request arrives? The same server can look very different depending on these choices.

## Technical depth
Questions to answer from the briefing:
- Does the window start at server launch, at first request, or after a warmup phase?
- Does it end at the last request arrival, the last completion, or a fixed time?
- Are requests that start inside but finish outside the window counted?
- Is idle power during quiet phases included in energy? (If yes, idle efficiency matters.)
- For per-request latency, what are the exact start (arrival? send? accepted?) and end (first byte? first token chunk?) timestamps?

Throughput = completed work / window duration, so the window definition directly changes the number.

## Backend-engineer analogy
Like defining the billing period for cloud cost, or the SLO measurement window (rolling 30 days vs calendar month) — the window is part of the metric.

## Why it matters for GreenMind
If idle time is in the energy window, a server that burns power while waiting is penalized. Because full energy marks need 3× baseline efficiency (0.00462 SLO-met requests/J, roughly one third of baseline energy for the same requests), idle energy can be a large share of what's left to cut. If warmup is excluded, aggressive pre-compilation (e.g., CUDA graphs) is "free."

## Common mistakes
- Measuring energy over a different window than the grader.
- Including warmup in one run and not another.

## Related concepts
[Energy Boundary](8_Energy_Boundary.md) · [Arrival Rate and Load Phases](68_Arrival_Rate_and_Load_Phases.md) · [Model Loading and Warmup](52_Model_Loading_and_Warmup.md) · [Throughput](66_Throughput.md)

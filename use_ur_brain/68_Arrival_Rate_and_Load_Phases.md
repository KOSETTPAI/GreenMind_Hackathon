# 68. Arrival Rate and Load Phases (Ramp / Peak / Quiet / Drain)

**Stage:** 0 / 3 | **Priority:** Must know | **Prerequisites:** [Queueing](67_Queueing.md)

## In one sentence
The arrival rate (λ) is how many requests per second are offered to the server, and the load schedule describes how λ changes over the test — ramp-up, peak, quiet, and drain phases.

## Plain-English explanation
The grader doesn't send requests at a constant pace. A typical schedule:
- **Ramp:** load increases gradually — tests how the server adapts.
- **Peak:** maximum arrival rate — tests capacity and tail latency.
- **Quiet:** low load — tests idle efficiency (power while waiting) and small-batch latency.
- **Drain:** no new arrivals; in-flight requests finish.

Each phase stresses a different aspect. Exact durations and rates must come from the briefing.

## Technical depth
- Arrivals are often **Poisson** (exponential inter-arrival times) — bursty even at a constant average rate.
- During peak, if `λ > μ` (service rate), queues grow; the drain phase then reveals how long the backlog takes to clear.
- Quiet phases: GPU idles at ~50–60 W (A100) but still burns energy if the window includes it; small-batch decode is overhead-bound.
- Agentic workloads create **dependent** arrivals: a follow-up request is sent only after a previous response + tool execution.

## Backend-engineer analogy
A realistic load-test profile (k6/Locust stages): ramp, soak, spike, cool-down.

## Why it matters for GreenMind
Config that's best at peak (big batches) may not be best in quiet periods (latency, idle energy). Analyze metrics per phase.

## Common mistakes
- Benchmarking only at a constant rate.
- Ignoring idle energy in quiet phases.

## Related concepts
[Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md) · [Measurement Window](7_Measurement_Window.md) · [Queueing](67_Queueing.md) · [Agentic Workloads](74_Agentic_Workloads_and_Multi_Turn.md)

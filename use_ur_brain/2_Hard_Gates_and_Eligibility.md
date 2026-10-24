# 2. Hard Gates and Eligibility

**Stage:** 0 — Understand the evaluator | **Priority:** Must know | **Prerequisites:** [Inferencing](1_Inferencing.md)

## In one sentence
A hard gate is a pass/fail condition: if you fail it, you don't get "slightly less score" — the request, run, or whole submission can be excluded or capped.

## Plain-English explanation
Some rules are cliffs, not slopes. Examples of what *might* be a gate (verify in the official briefing):
- Accuracy retention must stay above a cutoff versus the baseline.
- A request only counts if TTFT and TPOT are under limits.
- Responses must follow the OpenAI-compatible format, including streaming and tool calls.
- The server must start within a time limit, not use the network, and use only allowed artifacts.

A 2× speedup is worthless if it drops accuracy below the cutoff.

## Technical depth
- Gates can apply at three levels: **per request** (does this request count as useful?), **per run** (is this run valid?), and **per submission** (is the team eligible?).
- Boundary rules matter: is the limit `<` or `≤`? What happens to failed, retried, timed-out, or malformed requests? What if a score component has zero valid samples?
- Keep gates in a **separate column** from continuous score terms in your score sheet.

## Backend-engineer analogy
A gate is like a contract SLA with a penalty clause or a CI check that blocks merge: "p95 < 2 s" in a contract isn't a gradient, it's a breach/no-breach line.

## Why it matters for GreenMind
The roadmap explicitly notes that "five conditions for useful work" and an accuracy-retention cutoff exist in the briefing. Those are almost certainly gates. **Confirmed:** retention is measured against a reference macro-accuracy of **87.8% on the Final (graded)** and 87.2% on Validation. `A` is full at `R ≥ 0.98` and fades to a floor of 0.05 at `R ≤ 0.85`. Only **SLO-met** requests count toward energy efficiency: streamed, not truncated, TTFT ≤ 0.5 s + 0.25 s per 1k input tokens, TPOT ≤ 50 ms. Your tuning must keep a safety margin from every gate, because run-to-run noise can push you over the edge.

## Common mistakes
- Assuming a late or failed request still earns partial credit.
- Tuning right up to a threshold with no margin for noise.
- Treating a prompt summary as the complete official rulebook.

## Exercise
Build a one-page table: rule | exact threshold | measurement source | consequence of failure | unknown? Mark every unknown explicitly and ask organizers.

## Related concepts
[Continuous Score Components](3_Continuous_Score_Components.md) · [SLO](11_SLO.md) · [Useful Requests](12_Useful_Requests.md) · [Accuracy Retention](120_Accuracy_Retention_and_Relative_Loss.md)

# 70. Coordinated Omission

**Stage:** 3 | **Priority:** Should know | **Prerequisites:** [Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md)

## In one sentence
Coordinated omission is a load-testing flaw where the generator sends fewer requests while the server is slow, so the slowest periods are under-sampled and latency looks better than it really is.

## Plain-English explanation
Imagine measuring a checkout line by having one shopper return to the line only after being served. If the cashier takes a 10-minute break, your shopper waits once — you record one slow sample. But in reality, everyone who *would* have arrived in those 10 minutes also waited. Your test "coordinated" with the server and omitted those bad samples.

## Technical depth
- Term popularized by Gil Tene (HdrHistogram, wrk2).
- Happens in closed-loop testers and in naive scripts that send the next request after the previous completes.
- **Fix:** open-loop generation with latency measured from the **intended** send time, not the actual send time (wrk2 approach).
- Also watch for client-side bottlenecks: if your Python load generator is CPU-saturated, it delays sends → hidden coordinated omission.

## Backend-engineer analogy
Exactly the classic HTTP load-testing pitfall; same fix.

## Why it matters for GreenMind
If your harness suffers from it, you'll believe your p95 TTFT is fine when the grader's open-loop schedule will reveal violations.

## Common mistakes
- Using a sequential "send-wait-send" loop as a load test.
- Not checking that the load generator itself keeps up with the schedule.

## Related concepts
[Open-Loop vs Closed-Loop Load](69_Open_Loop_vs_Closed_Loop_Load.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Measurement Harness](89_Measurement_Harness.md)

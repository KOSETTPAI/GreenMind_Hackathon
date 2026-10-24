# 50. Watts vs Joules (Power vs Energy)

**Stage:** 2 / 9 | **Priority:** Must know | **Prerequisites:** none (basic physics)

## In one sentence
Watts measure power (energy per second, a rate); joules measure energy (the total amount consumed over time) — the score is about joules, not watts.

## Plain-English explanation
Power is your car's speed; energy is the distance driven. A GPU at 300 W for 10 s uses 3,000 J. The same GPU at 200 W for 20 s uses 4,000 J — *lower power, more energy*. So "reduce watts" is not the goal; "reduce joules per useful request" is.

## Technical depth
- `1 W = 1 J/s`; `1 kWh = 3.6 MJ`.
- Energy over an interval: `E = ∫ P(t) dt`.
- With sampled telemetry: `E ≈ Σ P_i × Δt_i`.
- With a steady average: `E ≈ P_avg × T`. Example: 250 W × 40 s = 10,000 J.
- Energy per useful request: `E / N_useful`. Example: 10,000 J / 800 = 12.5 J/request.
- Race-to-idle vs slow-and-steady: finishing faster at higher power can use fewer joules if the GPU then idles at low power (or if idle isn't counted); a power cap can lower joules if runtime doesn't grow much.

## Backend-engineer analogy
Watts = cost per hour of an instance; joules = the total bill. A pricier instance that finishes the batch job in a third of the time can be cheaper overall.

## Why it matters for GreenMind
The energy score (reportedly logarithmic vs baseline) is computed from integrated energy over the official window and boundary. Instantaneous watt readings alone are misleading.

## Common mistakes
- Measuring instantaneous watts instead of integrated joules.
- Comparing power across runs of different duration.

## Related concepts
[Energy Measurement and Telemetry](51_Energy_Measurement_and_Telemetry.md) · [Energy per Useful Request](121_Energy_per_Useful_Request.md) · [GPU Power Caps and Clocks](122_GPU_Power_Caps_and_Clocks.md) · [Energy Boundary](8_Energy_Boundary.md)

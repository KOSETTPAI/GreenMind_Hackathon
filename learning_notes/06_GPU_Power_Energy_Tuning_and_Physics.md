# Module 06: GPU Power, Energy Physics, and Frequency Tuning

---

## 1. The Physics of Silicon Power Consumption

Total GPU electrical power ($P_{\text{total}}$) consists of dynamic switching power and static leakage power:

$$P_{\text{total}} = P_{\text{dynamic}} + P_{\text{static}} = \alpha \cdot C \cdot V^2 \cdot f + V \cdot I_{\text{leak}}$$

* $C$ = Load capacitance of the silicon circuits.
* $V$ = Operating voltage.
* $f$ = Operating clock frequency.
* $\alpha$ = Switching activity factor.

### The Cubic Power Law ($P \propto f^3$):
To push a GPU core to a higher frequency $f$, the voltage regulator must also increase the voltage $V$ proportionally ($V \propto f$). 
Substituting $V \propto f$ into dynamic power yields:

$$P_{\text{dynamic}} \propto f^3$$

**Power scales with the CUBE of frequency!**
* Running the A100 at its maximum boost clock (1,410 MHz) pushes board power to **400 W**.
* Dropping the clock by just **20%** (to 1,095 MHz) cuts dynamic power by **$\approx 50\%$**!

```
Power (Watts)
  ▲
400W│                                         ╭───── Top 15% clock burns 40% more watts!
   │                                     ╭───╯
   │                                 ╭───╯
250W│                        ╭───────╯
   │                 ╭──────╯   ◄── Optimal Efficiency Operating Point (250W - 275W)
   │         ╭───────╯
 52W│────────┴─────────────────────────────────────► Idle / Static Draw (50 - 57W)
   └────────────────────────────────────────────────► Frequency (MHz)
```

---

## 2. The Energy vs. Frequency U-Curve (Zeus / GreenLLM)

Total energy consumed for an inference request is the integral of power over time:

$$E = \int_0^T P(t) \, dt \approx P_{\text{average}} \times T_{\text{generation}}$$

There is a fundamental trade-off:
1. **If you clock the GPU too low**: Power is low, but execution time $T$ becomes very long. The constant **idle power drain ($P_{\text{idle}} \approx 52\text{ W}$)** accumulates over time, driving total Joules back up.
2. **If you clock the GPU too high**: Generation is fast, but the cubic power penalty ($400\text{ W}$) consumes massive active energy.
3. **The Sweet Spot**: Operating between **225 W and 275 W** minimizes total Joules per token.

---

## 3. Why Memory-Bound Decodes Do Not Need 400 Watts

During the **Decode Phase**:
* The GPU is waiting for memory transfers from HBM (1.555 TB/s).
* The 312 TFLOPS Tensor Cores are mostly stalled.
* Running the Tensor Cores at 1,410 MHz / 400 W generates heat and burns electricity while waiting on memory.
* **Empirical Fact**: Clamping the A100 from **400 W down to 250 W** reduces power by **37.5%**, while decode token throughput drops by **$< 6\%$**!
* In the hackathon formula, $s_E$ carries a weight of **0.6** while latency carries **0.2**. Trading a 5% latency drop for a 37.5% energy cut is an overwhelming mathematical victory.

---

## 4. Hardware Knobs for Systems Engineers

### A. Static Power Capping:
```bash
# Enable persistence mode (keeps driver loaded)
sudo nvidia-smi -pm 1

# Limit A100-SXM4 power limit to 250 Watts (default is 400 W)
sudo nvidia-smi -pl 250
```

### B. Core Clock Locking:
Under varying workloads, the GPU driver constantly throttles clocks up and down via Dynamic Voltage and Frequency Scaling (DVFS). This transition introduces micro-stutters.
```bash
# Lock graphics clock to 1095 MHz min and max
sudo nvidia-smi -lgc 1095,1095
```
Locking the clock eliminates DVFS hunting and stabilizes TPOT tail latency.

---

## 5. Measuring Energy via NVML (NVIDIA Management Library)

In Linux, GPU board energy is read from the hardware accumulator:
```bash
nvidia-smi --query-gpu=total_energy_consumption --format=csv,noheader,nounits
```
* Returns cumulative millijoules (mJ) consumed by the GPU board since driver boot.
* Energy over an evaluation window:
  $$E_{\text{window}} = \frac{\text{mJ}_{\text{end}} - \text{mJ}_{\text{start}}}{1000} \text{ Joules}$$
* **Energy Efficiency Metric ($\eta$)**:
  $$\eta = \frac{\text{SLO-met Requests}}{E_{\text{window}}} \quad \left[\frac{\text{requests}}{\text{Joule}}\right]$$

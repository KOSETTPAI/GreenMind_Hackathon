# Approach 0: Baseline and Measurement (Prerequisite)

**Rank:** prerequisite (every other approach depends on it)

**Goal:** a valid, grader-compatible server and a reproduced BF16 baseline, so every later change is compared against real numbers.

**One-line thesis:** without a reproduced baseline and a measured noise floor, we can't tell whether a change helped or the run was just lucky.

---

## 1. Targets to reproduce

| Reference | Value | Note |
|---|---|---|
| `η_base` | 0.00154 or 0.00163 SLO-met req/J | `scoring_criteria.md` lists both; confirm with organizers |
| Reference macro-accuracy | 87.2% or 87.8% | same discrepancy |
| Round cap | 30 minutes | unfinished requests count as failed |
| Energy source | NVML counter, idle included | |

Concepts: [Baseline](../use_ur_brain/4_Baseline.md) · [Measurement Window](../use_ur_brain/7_Measurement_Window.md) · [Energy Boundary](../use_ur_brain/8_Energy_Boundary.md)

---

## 2. Proposed steps (untested — run on the VM to confirm)

Source: the launch flags come from the briefing (see `greenmind_ai_hackathon_research_brief.md` §10).

```bash
vllm serve CMKL/MANGO1.5-Qwen3.5-9B --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

1. Smoke test: streaming chat, streaming tool call, Thai prompt, long prompt, `usage` present in the stream.
2. Run the grader health check, then one Validation submission.
3. Repeat the Validation run at least twice with no changes → noise floor.
4. Record telemetry: `P_idle`, average `P_active`, window length, busy fraction (Approach 1 §3.2 uses these).

Concepts: [Smoke Testing](../use_ur_brain/88_Smoke_Testing.md) · [Run-to-Run Variance](../use_ur_brain/91_Run_to_Run_Variance.md) · [Experiment Log](../use_ur_brain/90_Experiment_Log.md)

---

## 3. Record for every run

Exact launch command, vLLM version, model revision/hash, GPU power limit and clocks, macro-accuracy, per-category accuracy, SLO-met count, window energy (kJ), η, η/η_base, s_E, TTFT p95 (normalized), TPOT p95, preemptions, errors/timeouts/cut-offs.

---

## 4. Done when

- Reproduced η and macro-accuracy are near the official reference values.
- The spread across repeated runs is known (minimum believable improvement).
- The launch command is saved and restartable in one step (rollback point).

If the reproduced numbers are far off, fix the harness or setup before starting any approach.

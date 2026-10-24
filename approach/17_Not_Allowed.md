# Approach 17: Not Allowed — Never Do These

**Verdict:** never. These can get the team disqualified; organizers may rerun submissions and inspect configurations.

| Idea | Why it's tempting | Why it's banned |
|---|---|---|
| Changing GPU clocks or power **during** the run (dynamic frequency scaling) | Research like GreenLLM reports up to 34% energy savings this way ([arXiv 2508.16449](https://arxiv.org/pdf/2508.16449)) | Power/clock settings must stay constant for the whole run |
| Settings that apply **only** during the measured window | Lower energy just while being measured | Explicitly banned |
| Caching graded responses | Skip all generation for repeat questions | Only normal KV / prefix caching is allowed |
| `LD_PRELOAD` or replacing NVML | Change what the energy counter reports | Measurement tampering |
| Other GPU workloads or external API calls during a graded run | Offload work elsewhere | One serving process, own VM and GPU only, no external calls |
| Closed-source binaries, hosted APIs, proprietary services | Faster engines or kernels | All software must be open source |
| Calibration data containing hidden test questions | Better quantization accuracy | Calibration data must be open and exclude test questions |
| Reconstructing the hidden test set, sharing submissions/credentials | Tune to the exact questions | Fair-play rules |

Concepts: [Allowed Artifacts, Dependencies, and Network Rules](../use_ur_brain/9_Allowed_Artifacts_Dependencies_and_Network_Rules.md) · [Energy Boundary](../use_ur_brain/8_Energy_Boundary.md)

Source: rules section of `greenmind_ai_hackathon_research_brief.md` §9.

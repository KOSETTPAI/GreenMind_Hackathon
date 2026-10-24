# 112. MTP (Multi-Token Prediction)

**Stage:** 8 | **Priority:** Advanced | **Prerequisites:** [Speculative Decoding](111_Speculative_Decoding.md)

## In one sentence
MTP is a model/training feature that adds extra prediction heads or modules so the model can predict more than one future token at a time, often used as a built-in draft for speculative decoding.

## Plain-English explanation
Normally the model predicts only the next token. A model trained with MTP has extra small modules that also guess token +2, +3. At inference, these guesses can serve as drafts that the main model verifies — speculative decoding without a separate draft model.

## Technical depth
- Used in several recent model families (e.g., DeepSeek-V3, some Qwen-family hybrid releases ship MTP modules).
- MTP weights must actually be present in the checkpoint (look for extra `mtp` layers/params in the weight index and `config.json`, e.g., a `num_nextn_predict_layers`-style field).
- vLLM supports MTP-based speculative decoding for specific architectures via the speculative config (method name varies by model/version).
- Same win/loss conditions as speculative decoding: acceptance rate, batch size, overhead; plus hybrid recurrent-state rollback support.

## Backend-engineer analogy
A built-in prefetcher shipped with the system, versus bolting on an external one.

## Why it matters for GreenMind
If the MANGO checkpoint includes MTP modules and vLLM supports them for this architecture, it could be a lower-friction speculative-decoding experiment. **Do not assume** — the roadmap explicitly warns to verify.

## Common mistakes
- Assuming the supplied checkpoint has MTP weights.
- Assuming vLLM can exploit them for this architecture.

## Related concepts
[Speculative Decoding](111_Speculative_Decoding.md) · [Checkpoint](14_Checkpoint.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md) · [vLLM](113_vLLM.md)

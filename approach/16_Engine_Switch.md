# Approach 16: Switching Serving Engine (SGLang, TensorRT-LLM, llama.cpp)

**Rank:** 16 · **Effort:** high to very high · **Risk:** high to very high · **Verdict:** no, unless vLLM blocks us

**Goal:** replace vLLM with another open-source engine that might have faster kernels or a better scheduler.

**Why it ranks low:**
- Every engine must pass the six-point [Engine Migration Gate](../use_ur_brain/117_Engine_Migration_Gate.md): hybrid architecture support, identical request semantics, streaming and tool-call compatibility (`qwen3_coder` format), accuracy retention, measurement parity, and stable startup.
- The hybrid Mamba / Gated DeltaNet layers need dedicated kernels; support is newest in vLLM.
- With 2 days and limited Final submissions, a failed migration costs more than most approaches can gain.

| Engine | Main risk for us |
|---|---|
| SGLang | hybrid-layer support and tool-call parser must be verified |
| TensorRT-LLM | model conversion/build effort; hybrid support uncertain |
| llama.cpp | hybrid support, OpenAI streaming/tool semantics, and A100 efficiency all unproven |

Concepts: [vLLM](../use_ur_brain/113_vLLM.md) · [SGLang](../use_ur_brain/114_SGLang.md) · [TensorRT-LLM](../use_ur_brain/115_TensorRT_LLM.md) · [llama.cpp](../use_ur_brain/116_llama_cpp.md)

---

## 1. Proposed steps (untested — run on the VM to confirm)

Only if vLLM can't run a needed feature (for example, the quantized model or MTP):
1. Work in a separate branch; keep the best vLLM config frozen and runnable.
2. Pass the full migration gate before any Validation submission.
3. Compare against our **tuned** vLLM, not the untuned baseline.

## 2. Abandon criteria

Any gate item fails, or no clear S gain over tuned vLLM.

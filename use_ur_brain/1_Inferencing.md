# 1. Inferencing (Inference vs Training)

**Stage:** Orientation | **Priority:** Must know | **Prerequisites:** none

## In one sentence
Inference is running an already-trained model to produce outputs; training is the (much more expensive) process of computing gradients and updating the model's weights.

## Plain-English explanation
A model is a big function with billions of learned numbers (weights). Training is how those numbers were found: show examples, measure error, nudge the weights, repeat for weeks on many GPUs. Inference is what happens afterwards: the weights are frozen and you just *use* the function — text goes in, predicted text comes out.

In this hackathon you never train. You serve the organizer's model (MANGO1.5-Qwen3.5-9B) on one NVIDIA A100 40 GB and make that serving faster, cheaper in energy, and still correct.

## Technical depth
- **Training step:** forward pass → loss → backward pass (gradients) → optimizer update. It needs memory for weights, gradients, optimizer state (often 2 extra copies), and saved activations.
- **Inference step:** forward pass only. Memory = weights + per-request state (KV cache / recurrent state) + temporary activations + runtime overhead.
- **LLM inference is a loop:** one forward pass over the prompt ([Prefill](53_Prefill.md)), then one forward pass per generated token ([Decode](54_Decode.md)). That loop is called [Autoregressive Generation](25_Autoregressive_Generation.md).
- Inference optimization is mostly about **systems**: memory traffic, batching, scheduling, numerical precision, and kernels — not about changing what the model has learned.

## Backend-engineer analogy
Training = building and indexing the database. Inference = serving queries against it. Your job here is the query-serving layer: throughput, tail latency, resource cost, and correctness under a load test.

## Why it matters for GreenMind
The scoring is about *inference* properties: correctness retention, request-level SLOs (TTFT/TPOT), throughput, and GPU energy. Every later concept in this folder is a lever or a measurement for that serving loop.

## Common mistakes
- Thinking "optimization" means retraining the model. It usually means serving the same model more efficiently.
- Assuming the model's file size equals the memory it needs at serving time.
- Treating an LLM call like a single stateless function call — it's a stateful, token-by-token loop.

## Check yourself
1. Name two memory consumers that exist in training but not in inference.
2. Why does generating 500 tokens cost more than generating 50, even with the same prompt?

## Related concepts
[Parameters and Weights](13_Parameters_and_Weights.md) · [Autoregressive Generation](25_Autoregressive_Generation.md) · [Prefill](53_Prefill.md) · [Decode](54_Decode.md) · [Fine-Tuning and Distillation](108_Fine_Tuning_and_Distillation.md)

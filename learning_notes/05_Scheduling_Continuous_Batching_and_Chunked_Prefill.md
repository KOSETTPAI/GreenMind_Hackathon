# Module 05: Scheduling, Continuous Batching, and Chunked Prefill

---

## 1. The Evolution of LLM Batching

Batching increases GPU utilization by amortizing model weight loading across multiple requests. But traditional deep learning batching does not fit LLMs because different requests generate different numbers of tokens.

```
Static Batching:
Req 1: [Prompt][Tok 1][Tok 2] ───────────────────────► [Done] ──► (IDLE / WASTED COMPUTE) ──┐
Req 2: [Prompt][Tok 1][Tok 2][Tok 3][Tok 4][Tok 5] ──► [Done] ──► (IDLE / WASTED COMPUTE) ──┼──► Wait for slowest!
Req 3: [Prompt][Tok 1][Tok 2] ... [Tok 500] ───────────────────────────────────────────────┴──► Finished

Continuous (Iteration-Level) Batching:
Step t:   [Req 1: Tok 2]  [Req 2: Tok 4]  [Req 3: Tok 18]  (Req 1 finishes here!)
Step t+1: [Req 4: Prefill][Req 2: Tok 5]  [Req 3: Tok 19]  (Req 4 immediately injected into batch!)
```

* **Static Batching**: All requests in a batch must wait until the slowest request finishes generating. Fast requests sit idle, wasting massive compute.
* **Continuous Batching (Orca, OSDI 2022)**: Operates at the **iteration level**. As soon as a sequence emits an `<EOS>` (End-of-Sequence) token, it is evicted, and a new waiting request is inserted into the batch on the very next token step.

---

## 2. The Two Essential Knobs in vLLM

Every AI Systems Engineer must master these two configuration parameters:

### A. `--max-num-seqs` (Maximum Number of Concurrent Sequences)
* **What it controls**: The maximum number of active requests allowed to execute in parallel in a single iteration.
* **The Trade-off**:
  * Too small (e.g., 16 or 32): GPU compute is underutilized; incoming requests wait in queue, inflating **TTFT**.
  * Too large (e.g., 128+ on small GPUs): Decodes contend for HBM memory bandwidth, inflating **TPOT**.

### B. `--max-num-batched-tokens` (Token Budget Per Step)
* **What it controls**: The maximum total tokens (sum of prefill prompt tokens + decode tokens) processed in a single forward pass.
* **Default on A100**: Typically `2048`.

---

## 3. Chunked Prefill Mechanics (Sarathi-Serve)

Without chunked prefill, a 4,000-token prompt prefill completely blocks the GPU, forcing ongoing decode requests to pause for 1–2 seconds, causing massive latency spikes (high tail TPOT).

* **Chunked Prefill**: Chops a 4,000-token prompt into chunks of size $C = \text{max\_num\_batched\_tokens}$ (e.g., 2,048 tokens).
* Chunks are co-scheduled alongside active decode tokens:
  $$\text{Batch Budget} = \underbrace{2,048\text{ prefill tokens}}_{\text{Chunk of Prompt A}} + \underbrace{48\text{ decode tokens}}_{\text{48 active requests}}$$

---

## 4. The "Concurrency Cliff" Teardown (From the Hackathon)

In `run6` and `final-run1`, the team encountered a catastrophic failure during the 4 req/s peak:
* **Validation (35 peak running requests)**: $p_{95}\text{ TPOT} = \mathbf{18\text{ ms}}$ (Passed SLO!).
* **Final (111 peak running requests)**: $p_{95}\text{ TPOT} = \mathbf{82\text{ ms}}$ (Failed SLO $\le 50\text{ms}$!).

### Why Did TPOT Explode from 18 ms to 82 ms?
Under default `max_num_batched_tokens = 2048`:
1. When 111 requests are alive, large prompts arrive continuously.
2. Because 2048 is small, each long prompt is sliced into **dozens of tiny chunks**.
3. Consequently, **EVERY SINGLE DECODE STEP IS A "MIXED STEP"** (Prefill chunk + decode tokens).
4. In mixed steps, the A100 Tensor Cores down-clock, memory access is irregular, and decode tokens are trapped behind prefill scans. Decode steps drag out to 80+ ms!

### The Solution: High Batch Token Budget (`--max-num-batched-tokens 8192`)
* By expanding the budget to **8192**, vLLM ingests prompts in **1 or 2 dense, high-throughput steps**.
* Once the prefill burst is digested, all subsequent steps become **Pure Decode Steps**.
* In pure decode mode, the A100 processes all 111 sequences at **15–25 ms per step**, safely beneath the 50 ms ceiling!

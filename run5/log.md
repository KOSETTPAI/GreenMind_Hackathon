# Log

Blank cells are missing, not zero. Copy them from grader History after the run finishes.

Image for the ladder: `vllm/vllm-openai:nightly`. Record the digest from `docker inspect mango-vllm --format '{.Image}'` at launch. Do not change the image between runs.

| ID | Track | Start (UTC+7) | Parent | Single change | Image digest | S | SLO-met | Accuracy | η / baseline | J/request | p95 TTFT | p95 TPOT | Preemptions | Cache hit rate | MTP acceptance | Decision |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| V1 | Validation | | run4 full | remove MTP; prefix caching stays | | | | | | | | | | | | |

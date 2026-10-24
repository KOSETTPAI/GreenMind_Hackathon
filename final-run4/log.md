# final-run4: cold Final of the 19.1 server

Final only. Baseline η 0.00163 and 87.8%. `S = 0` whenever η ≤ 0.00163, because `s_E` clips to 0. J/request is total GPU joules / 300, including misses. A run clears the cliff only when SLO-met > 0.489 × (J/request).

Blank cells are missing, not zero. This Final has not been submitted, so its History row is empty.

| Run | Start (UTC+7) | Power | S | A | R | sE | sT | sL | η / 0.00163 | J/request | p95 TTFT | p95 TPOT | SLO-met | Accuracy | Prefix hits |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Reference: 19.1 Final (run5 container, warm) | 2026-10-24 11:54 | card default | 19.1 | 1.00 | 0.975 | 0.15 | 0.16 | 0.50 | 1.18× | 221 | 2.16 s | 82 ms | 127/300 | 85.6% | 44% |
| **final-run4** (same flags, cold) |  | card default (400 W) |  |  |  |  |  |  |  |  |  |  | /300 |  |  |

Compare the final-run4 row with the reference: SLO-met against 127/300, p95 TTFT against 2.16 s, p95 TPOT against 82 ms, η against 1.18×. If η is under 1.00×, this launch is under the cliff and `S` is 0.

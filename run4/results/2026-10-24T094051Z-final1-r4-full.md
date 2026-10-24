# run4 final test log\`

Baseline (untuned, default vLLM BF16): η\_base = 0.00163 SLO-met requests/J · K = 3× for full energy marks · reference macro-accuracy 87.8%

benchmarks

| **#** | **Started** | **Model** | **Score S** | **A** | **R** | **sE** | **sT** | **sL** | **η vs base** | **J/request** | **p95 TTFT** | **p95 TPOT** | **SLO-met** | **Accuracy** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 2026-10-24 09:40:51 | mango1.5-awq-w4a16 | **0.0** | 1.00 | 1.007 | 0.00 | 0.05 | 0.31 | 0.92× | 208 | 3.59s | 91 ms | 93/300 | 88.4% |

<table style="min-width: 375px;">
<colgroup><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"></colgroup><tbody><tr><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th></tr><tr><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th><th colspan="1" rowspan="1"><p></p></th></tr><tr><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td><td colspan="1" rowspan="1"><p></p></td></tr></tbody>
</table>

How each column is computed

- **Score S** — 100 · A · sE0.6 · sT0.2 · sL0.2. Ties: higher retention R, then lower p95 TTFT.
- **A (accuracy gate)** — R = macro-accuracy ÷ the baseline's macro-accuracy; A = smoothstep((R − 0.85) ÷ 0.13): 1 at R ≥ 0.98, fading smoothly below it, floor 0.05. A task family (≥ 20 items) keeping under 75% of the baseline's accuracy multiplies A by a smooth penalty (full at 75%, minimum at 50%).
- **sE (energy)** — η = SLO-met requests ÷ GPU joules over the timed window; sE = clip(ln(η ÷ ηbase) ÷ ln K, 0, 1). A request counts only if it streamed, finished (not truncated), TTFT ≤ 0.5 s + 0.25 s per 1k input tokens and TPOT ≤ 50 ms.
- **sT (throughput)** — share of peak-phase requests that met their SLO.
- **sL (latency)** — √(min(1, 1 ÷ p95 TTFT/SLO) · min(1, 50 ms ÷ p95 TPOT)).
- Energy = GPU board energy from the NVML total-energy counter (CPU/DRAM RAPL and BMC/PDU are not readable on these VMs).

run 20261024T094230: 300 calls | 1 models x 300 tasks x 1

run 20261024T094230: 300 calls | 1 models x 300 tasks x 1\
\[1/300\] mango1.5-awq-w4a16         mxv2_411_instruction  0.00    1.9s\
\[2/300\] mango1.5-awq-w4a16         mxv2_215_rag_grounded  1.00    3.5s\
\[3/300\] mango1.5-awq-w4a16         mxv2_243_rag_grounded  1.00    1.0s\
\[4/300\] mango1.5-awq-w4a16         mxv2_199_longctx  1.00    5.8s\
\[5/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    2.9s\
\[6/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.4s\
\[7/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s\
\[8/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.2s\
\[9/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.2s\
\[10/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.6s\
\[11/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.1s\
\[12/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    2.9s\
\[13/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s\
\[14/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.6s\
\[15/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    1.9s\
\[16/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    0.8s\
\[17/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.5s\
\[18/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.1s\
\[19/300\] mango1.5-awq-w4a16         ag061_calc_chain  1.00    4.2s

\[2/300\] mango1.5-awq-w4a16         mxv2_215_rag_grounded  1.00    3.5s\
\[3/300\] mango1.5-awq-w4a16         mxv2_243_rag_grounded  1.00    1.0s\
\[4/300\] mango1.5-awq-w4a16         mxv2_199_longctx  1.00    5.8s\
\[5/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    2.9s\
\[6/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.4s\
\[7/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s\
\[8/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.2s\
\[9/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.2s\
\[10/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.6s\
\[11/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.1s\
\[12/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    2.9s\
\[13/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s\
\[14/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.6s\
\[15/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    1.9s\
\[16/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    0.8s\
\[17/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.5s\
\[18/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.1s\
\[19/300\] mango1.5-awq-w4a16         ag061_calc_chain  1.00    4.2s\
\[20/300\] mango1.5-awq-w4a16         mxv2_111_math     1.00    2.3s\
\[21/300\] mango1.5-awq-w4a16         ag018_kv_prefix_sum  0.00    2.7s\
\[22/300\] mango1.5-awq-w4a16         mxv2_221_rag_grounded  1.00    2.9s\
\[23/300\] mango1.5-awq-w4a16         mxv2_209_rag_grounded  1.00    1.4s\
\[24/300\] mango1.5-awq-w4a16         mxv2_222_rag_grounded  1.00    4.3s\
\[25/300\] mango1.5-awq-w4a16         mxv2_245_rag_grounded  1.00    4.6s\
\[26/300\] mango1.5-awq-w4a16         mxv2_207_rag_grounded  1.00    8.1s\
\[27/300\] mango1.5-awq-w4a16         ag079_pages_agg   0.00    8.8s\
\[28/300\] mango1.5-awq-w4a16         mxv2_045_code_output  1.00    8.4s\
\[29/300\] mango1.5-awq-w4a16         mxv2_023_code_output  1.00   10.0s\
\[30/300\] mango1.5-awq-w4a16         mx169_longctx     1.00    5.8s\
\[31/300\] mango1.5-awq-w4a16         mxv2_229_rag_grounded  1.00    6.2s

\[34/300\] mango1.5-awq-w4a16         ag066_calc_chain  0.00   19.0s\
\[35/300\] mango1.5-awq-w4a16         mxv2_142_math     1.00    8.5s\
\[36/300\] mango1.5-awq-w4a16         ag074_pages_agg   0.00   22.8s\
\[37/300\] mango1.5-awq-w4a16         mxv2_433_instruction  1.00   21.2s\
\[38/300\] mango1.5-awq-w4a16         mxv2_236_rag_grounded  1.00   10.0s\
\[39/300\] mango1.5-awq-w4a16         ag089_inbox_flag  1.00   22.5s\
\[40/300\] mango1.5-awq-w4a16         mxv2_235_rag_grounded  1.00   10.4s\
\[41/300\] mango1.5-awq-w4a16         ag085_pages_agg   0.00   17.4s\
\[42/300\] mango1.5-awq-w4a16         mxv2_423_instruction  1.00   19.0s\
\[43/300\] mango1.5-awq-w4a16         mxv2_273_thai     1.00   18.2s\
\[44/300\] mango1.5-awq-w4a16         mxv2_212_rag_grounded  1.00   16.3s\
\[45/300\] mango1.5-awq-w4a16         mxv2_446_instruction  1.00   24.3s\
\[46/300\] mango1.5-awq-w4a16         mxv2_403_instruction  1.00   15.9s\
\[47/300\] mango1.5-awq-w4a16         mxv2_136_math     1.00   18.7s\
\[48/300\] mango1.5-awq-w4a16         mxv2_193_longctx  1.00   18.6s\
\[49/300\] mango1.5-awq-w4a16         ag004_kv_swap     1.00   25.9s\
\[50/300\] mango1.5-awq-w4a16         ag045_files_find_port  1.00   21.3s\
\[51/300\] mango1.5-awq-w4a16         mxv2_244_rag_grounded  1.00   11.1s\
\[52/300\] mango1.5-awq-w4a16         mx421_instruction  1.00   20.0s\
\[53/300\] mango1.5-awq-w4a16         mxv2_205_rag_grounded  1.00   13.4s\
\[54/300\] mango1.5-awq-w4a16         mx411_instruction  1.00   23.1s\
\[55/300\] mango1.5-awq-w4a16         mxv2_203_rag_grounded  1.00    9.6s\
\[56/300\] mango1.5-awq-w4a16         mx159_longctx     1.00   12.5s\
\[57/300\] mango1.5-awq-w4a16         mxv2_237_rag_grounded  1.00   14.1s\
\[58/300\] mango1.5-awq-w4a16         ag053_files_find_port  1.00   32.6s\
\[59/300\] mango1.5-awq-w4a16         mxv2_265_thai     1.00   27.4s\
\[60/300\] mango1.5-awq-w4a16         ag100_inbox_flag  0.00   27.9s\
\[61/300\] mango1.5-awq-w4a16         mxv2_208_rag_grounded  1.00    8.9s\
\[62/300\] mango1.5-awq-w4a16         mxv2_201_rag_grounded  1.00   14.7s\
\[63/300\] mango1.5-awq-w4a16         mx443_instruction  0.00   28.1s

\[77/300\] mango1.5-awq-w4a16         ag067_calc_chain  1.00   31.4s\
\[78/300\] mango1.5-awq-w4a16         mxv2_202_rag_grounded  1.00    5.3s\
\[79/300\] mango1.5-awq-w4a16         mx412_instruction  1.00   29.8s\
\[80/300\] mango1.5-awq-w4a16         mxv2_232_rag_grounded  1.00   13.0s\
\[81/300\] mango1.5-awq-w4a16         mxv2_434_instruction  1.00   36.2s\
\[82/300\] mango1.5-awq-w4a16         mxv2_169_longctx  1.00   14.1s\
\[83/300\] mango1.5-awq-w4a16         mxv2_183_longctx  1.00   15.7s\
\[84/300\] mango1.5-awq-w4a16         mxv2_444_instruction  1.00    8.0s\
\[85/300\] mango1.5-awq-w4a16         mx406_instruction  1.00   13.1s\
\[86/300\] mango1.5-awq-w4a16         mxv2_224_rag_grounded  1.00    6.5s\
\[87/300\] mango1.5-awq-w4a16         mxv2_032_code_output  1.00   20.8s\
\[88/300\] mango1.5-awq-w4a16         mx416_instruction  1.00   23.7s\
\[89/300\] mango1.5-awq-w4a16         mxv2_230_rag_grounded  1.00    6.9s\
\[90/300\] mango1.5-awq-w4a16         mxv2_256_thai     1.00   17.0s\
\[91/300\] mango1.5-awq-w4a16         mxv2_249_rag_grounded  1.00    6.3s\
\[92/300\] mango1.5-awq-w4a16         mxv2_164_longctx  1.00   15.6s\
\[93/300\] mango1.5-awq-w4a16         mxv2_447_instruction  1.00   22.1s\
\[94/300\] mango1.5-awq-w4a16         mx199_longctx     1.00   13.8s\
\[95/300\] mango1.5-awq-w4a16         mxv2_217_rag_grounded  1.00    8.8s\
\[96/300\] mango1.5-awq-w4a16         mx422_instruction  1.00   30.1s\
\[97/300\] mango1.5-awq-w4a16         mxv2_420_instruction  0.00   28.5s\
\[98/300\] mango1.5-awq-w4a16         mxv2_425_instruction  1.00   17.7s\
\[99/300\] mango1.5-awq-w4a16         mx433_instruction  1.00   36.6s\
\[100/300\] mango1.5-awq-w4a16         mxv2_487_complexity  1.00   29.3s\
\[101/300\] mango1.5-awq-w4a16         ag075_pages_agg   1.00   29.9s\
\[102/300\] mango1.5-awq-w4a16         mxv2_248_rag_grounded  1.00    8.0s\
\[103/300\] mango1.5-awq-w4a16         mxv2_125_math     1.00    6.8s\
\[104/300\] mango1.5-awq-w4a16         mxv2_409_instruction  1.00   34.4s\
\[105/300\] mango1.5-awq-w4a16         mxv2_218_rag_grounded  1.00    8.3s\
\[106/300\] mango1.5-awq-w4a16         ag044_files_fix_conflict  0.00   25.9s

\[150/300\] mango1.5-awq-w4a16         mxv2_206_rag_grounded  1.00    7.0s\
\[151/300\] mango1.5-awq-w4a16         mx439_instruction  1.00   24.8s\
\[152/300\] mango1.5-awq-w4a16         mx173_longctx     1.00   14.8s\
\[153/300\] mango1.5-awq-w4a16         mxv2_281_thai     1.00   41.2s\
\[154/300\] mango1.5-awq-w4a16         ag090_inbox_flag  1.00   29.3s\
\[155/300\] mango1.5-awq-w4a16         mxv2_426_instruction  1.00   31.7s\
\[156/300\] mango1.5-awq-w4a16         ag057_calc_chain  1.00   28.5s\
\[157/300\] mango1.5-awq-w4a16         mxv2_448_instruction  1.00   25.9s\
\[158/300\] mango1.5-awq-w4a16         mxv2_276_thai     1.00   46.2s\
\[159/300\] mango1.5-awq-w4a16         ag050_files_fix_conflict  0.00   16.1s\
\[160/300\] mango1.5-awq-w4a16         mx403_instruction  0.00    6.0s\
\[161/300\] mango1.5-awq-w4a16         mxv2_223_rag_grounded  1.00    4.5s\
\[162/300\] mango1.5-awq-w4a16         ag087_inbox_flag  1.00   23.3s\
\[163/300\] mango1.5-awq-w4a16         mxv2_288_thai     1.00   15.1s\
\[164/300\] mango1.5-awq-w4a16         ag099_inbox_flag  1.00   29.8s\
\[165/300\] mango1.5-awq-w4a16         mx409_instruction  0.00   31.2s\
\[166/300\] mango1.5-awq-w4a16         mx440_instruction  1.00   40.9s\
\[167/300\] mango1.5-awq-w4a16         mxv2_432_instruction  1.00   29.5s\
\[168/300\] mango1.5-awq-w4a16         mx442_instruction  1.00   16.5s\
\[169/300\] mango1.5-awq-w4a16         mx436_instruction  1.00   11.6s\
\[170/300\] mango1.5-awq-w4a16         ag033_orders_policy  1.00   55.4s\
\[171/300\] mango1.5-awq-w4a16         ag047_files_find_port  1.00   17.0s\
\[172/300\] mango1.5-awq-w4a16         mxv2_179_longctx  1.00   11.7s\
\[173/300\] mango1.5-awq-w4a16         mxv2_174_longctx  1.00   19.0s\
\[174/300\] mango1.5-awq-w4a16         ag070_calc_chain  0.00   37.2s\
\[175/300\] mango1.5-awq-w4a16         mxv2_440_instruction  1.00   24.7s\
\[176/300\] mango1.5-awq-w4a16         ag076_pages_agg   1.00   25.8s\
\[177/300\] mango1.5-awq-w4a16         ag020_orders_policy  1.00   53.5s\
\[178/300\] mango1.5-awq-w4a16         mxv2_455_complexity  1.00   48.5s\
\[179/300\] mango1.5-awq-w4a16         mxv2_428_instruction  1.00    8.5s

\[191/300\] mango1.5-awq-w4a16         mxv2_435_instruction  0.00   27.0s\
\[192/300\] mango1.5-awq-w4a16         ag088_inbox_flag  0.00   16.0s\
\[193/300\] mango1.5-awq-w4a16         ag063_calc_chain  0.00   21.4s\
\[194/300\] mango1.5-awq-w4a16         mxv2_282_thai     1.00   38.9s\
\[195/300\] mango1.5-awq-w4a16         mxv2_185_longctx  1.00   26.8s\
\[196/300\] mango1.5-awq-w4a16         mxv2_294_thai     1.00   47.6s\
\[197/300\] mango1.5-awq-w4a16         mxv2_424_instruction  1.00   23.9s\
\[198/300\] mango1.5-awq-w4a16         mxv2_195_longctx  1.00   48.8s\
\[199/300\] mango1.5-awq-w4a16         mx413_instruction  1.00   51.0s\
\[200/300\] mango1.5-awq-w4a16         mxv2_402_instruction  1.00   19.2s\
\[201/300\] mango1.5-awq-w4a16         ag096_inbox_flag  0.00   12.9s\
\[202/300\] mango1.5-awq-w4a16         ag029_orders_policy  1.00   38.0s\
\[203/300\] mango1.5-awq-w4a16         mxv2_438_instruction  1.00   24.4s\
\[204/300\] mango1.5-awq-w4a16         mx414_instruction  1.00   52.2s\
\[205/300\] mango1.5-awq-w4a16         mxv2_016_code_output  1.00    4.6s\
\[206/300\] mango1.5-awq-w4a16         ag038_orders_policy  1.00   45.3s\
\[207/300\] mango1.5-awq-w4a16         ag002_kv_winner   1.00   64.1s\
\[208/300\] mango1.5-awq-w4a16         mx423_instruction  1.00   20.1s\
\[209/300\] mango1.5-awq-w4a16         mxv2_412_instruction  1.00   18.0s\
\[210/300\] mango1.5-awq-w4a16         mxv2_070_sql_result  1.00   49.8s\
\[211/300\] mango1.5-awq-w4a16         mx430_instruction  1.00   52.5s\
\[212/300\] mango1.5-awq-w4a16         mxv2_269_thai     1.00    3.3s\
\[213/300\] mango1.5-awq-w4a16         mxv2_170_longctx  1.00   19.7s\
\[214/300\] mango1.5-awq-w4a16         mxv2_092_sql_result  1.00   41.9s\
\[215/300\] mango1.5-awq-w4a16         mxv2_408_instruction  1.00   19.6s\
\[216/300\] mango1.5-awq-w4a16         ag060_calc_chain  0.00   24.2s\
\[217/300\] mango1.5-awq-w4a16         mxv2_298_thai     1.00   44.5s\
\[218/300\] mango1.5-awq-w4a16         mxv2_418_instruction  1.00   19.2s\
\[219/300\] mango1.5-awq-w4a16         mxv2_130_math     1.00   46.0s\
\[220/300\] mango1.5-awq-w4a16         mx188_longctx     1.00   63.2s

\[212/300\] mango1.5-awq-w4a16         mxv2_269_thai     1.00    3.3s\
\[213/300\] mango1.5-awq-w4a16         mxv2_170_longctx  1.00   19.7s\
\[214/300\] mango1.5-awq-w4a16         mxv2_092_sql_result  1.00   41.9s\
\[215/300\] mango1.5-awq-w4a16         mxv2_408_instruction  1.00   19.6s\
\[216/300\] mango1.5-awq-w4a16         ag060_calc_chain  0.00   24.2s\
\[217/300\] mango1.5-awq-w4a16         mxv2_298_thai     1.00   44.5s\
\[218/300\] mango1.5-awq-w4a16         mxv2_418_instruction  1.00   19.2s\
\[219/300\] mango1.5-awq-w4a16         mxv2_130_math     1.00   46.0s\
\[220/300\] mango1.5-awq-w4a16         mx188_longctx     1.00   63.2s\
\[221/300\] mango1.5-awq-w4a16         ag058_calc_chain  0.00   21.7s\
\[222/300\] mango1.5-awq-w4a16         mxv2_066_sql_result  1.00   47.1s\
\[223/300\] mango1.5-awq-w4a16         mx450_instruction  1.00   19.1s\
\[224/300\] mango1.5-awq-w4a16         mx425_instruction  1.00   48.8s\
\[225/300\] mango1.5-awq-w4a16         ag008_kv_winner   1.00   40.2s\
\[226/300\] mango1.5-awq-w4a16         ag036_orders_policy  1.00   27.0s\
\[227/300\] mango1.5-awq-w4a16         mx437_instruction  1.00    7.2s\
\[228/300\] mango1.5-awq-w4a16         mxv2_030_code_output  1.00    3.2s\
\[229/300\] mango1.5-awq-w4a16         mxv2_126_math     1.00   59.1s\
\[230/300\] mango1.5-awq-w4a16         mxv2_231_rag_grounded  1.00    2.3s\
\[231/300\] mango1.5-awq-w4a16         ag028_orders_policy  1.00   48.2s\
\[232/300\] mango1.5-awq-w4a16         mxv2_430_instruction  1.00   29.5s\
\[233/300\] mango1.5-awq-w4a16         mxv2_405_instruction  0.00   78.8s\
\[234/300\] mango1.5-awq-w4a16         mxv2_422_instruction  1.00    9.5s\
\[235/300\] mango1.5-awq-w4a16         mxv2_404_instruction  1.00    5.9s\
\[236/300\] mango1.5-awq-w4a16         mxv2_278_thai     1.00   80.8s\
\[237/300\] mango1.5-awq-w4a16         mxv2_051_sql_result  1.00   14.7s\
\[238/300\] mango1.5-awq-w4a16         ag052_files_fix_conflict  0.00    6.0s\
\[239/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    6.3s\
\[240/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    5.3s\
\[241/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   21.0s

\[239/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    6.3s\
\[240/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    5.3s\
\[241/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   21.0s\
\[242/300\] mango1.5-awq-w4a16         mx445_instruction  1.00   13.3s\
\[243/300\] mango1.5-awq-w4a16         mxv2_443_instruction  0.00   50.6s\
\[244/300\] mango1.5-awq-w4a16         mxv2_120_math     1.00    4.5s\
\[245/300\] mango1.5-awq-w4a16         mx401_instruction  1.00    5.8s\
\[246/300\] mango1.5-awq-w4a16         mxv2_478_complexity  1.00   35.5s\
\[247/300\] mango1.5-awq-w4a16         mx404_instruction  1.00    4.9s\
\[248/300\] mango1.5-awq-w4a16         mxv2_262_thai     1.00    7.6s\
\[249/300\] mango1.5-awq-w4a16         mx415_instruction  1.00   10.3s\
\[250/300\] mango1.5-awq-w4a16         mxv2_213_rag_grounded  1.00    1.2s\
\[251/300\] mango1.5-awq-w4a16         mxv2_268_thai     1.00    6.6s\
\[252/300\] mango1.5-awq-w4a16         mx441_instruction  1.00    2.6s\
\[253/300\] mango1.5-awq-w4a16         mxv2_287_thai     1.00    2.8s\
\[254/300\] mango1.5-awq-w4a16         mxv2_225_rag_grounded  1.00    1.3s\
\[255/300\] mango1.5-awq-w4a16         mxv2_004_code_output  1.00    3.5s\
\[256/300\] mango1.5-awq-w4a16         ag082_pages_agg   1.00   12.3s\
\[257/300\] mango1.5-awq-w4a16         ag023_orders_policy  1.00    9.2s\
\[258/300\] mango1.5-awq-w4a16         mxv2_234_rag_grounded  1.00    1.4s\
\[259/300\] mango1.5-awq-w4a16         mxv2_100_sql_result  1.00   15.6s\
\[260/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    2.2s\
\[261/300\] mango1.5-awq-w4a16         mxv2_074_sql_result  1.00   64.9s\
\[262/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    5.0s\
\[263/300\] mango1.5-awq-w4a16         ag021_orders_policy  1.00    9.2s\
\[264/300\] mango1.5-awq-w4a16         mxv2_240_rag_grounded  1.00    1.6s\
\[265/300\] mango1.5-awq-w4a16         mxv2_419_instruction  0.00    1.4s\
\[266/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   40.0s\
\[267/300\] mango1.5-awq-w4a16         mxv2_429_instruction  0.00   65.1s\
\[268/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    9.6s

\[260/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    2.2s\
\[261/300\] mango1.5-awq-w4a16         mxv2_074_sql_result  1.00   64.9s\
\[262/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    5.0s\
\[263/300\] mango1.5-awq-w4a16         ag021_orders_policy  1.00    9.2s\
\[264/300\] mango1.5-awq-w4a16         mxv2_240_rag_grounded  1.00    1.6s\
\[265/300\] mango1.5-awq-w4a16         mxv2_419_instruction  0.00    1.4s\
\[266/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   40.0s\
\[267/300\] mango1.5-awq-w4a16         mxv2_429_instruction  0.00   65.1s\
\[268/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    9.6s\
\[269/300\] mango1.5-awq-w4a16         mx428_instruction  1.00   39.8s\
\[270/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    3.4s\
\[271/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    3.2s\
\[272/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    2.2s\
\[273/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    5.0s\
\[274/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    3.7s\
\[275/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    4.5s\
\[276/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    3.7s\
\[277/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    6.2s\
\[278/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.9s\
\[279/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    3.7s\
\[280/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00   13.1s\
\[281/300\] mango1.5-awq-w4a16         mx198_longctx     1.00  103.5s\
\[282/300\] mango1.5-awq-w4a16         mxv2_252_thai     1.00   13.7s\
\[283/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00   21.2s\
\[284/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   14.7s\
\[285/300\] mango1.5-awq-w4a16         mxv2_131_math     1.00   85.5s\
\[286/300\] mango1.5-awq-w4a16         mxv2_421_instruction  1.00   73.4s\
\[287/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00   11.9s\
\[288/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   22.0s\
\[289/300\] mango1.5-awq-w4a16         mx420_instruction  1.00   22.6s

\[260/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    2.2s\
\[261/300\] mango1.5-awq-w4a16         mxv2_074_sql_result  1.00   64.9s\
\[262/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    5.0s\
\[263/300\] mango1.5-awq-w4a16         ag021_orders_policy  1.00    9.2s\
\[264/300\] mango1.5-awq-w4a16         mxv2_240_rag_grounded  1.00    1.6s\
\[265/300\] mango1.5-awq-w4a16         mxv2_419_instruction  0.00    1.4s\
\[266/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   40.0s\
\[267/300\] mango1.5-awq-w4a16         mxv2_429_instruction  0.00   65.1s\
\[268/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    9.6s\
\[269/300\] mango1.5-awq-w4a16         mx428_instruction  1.00   39.8s\
\[270/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    3.4s\
\[271/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    3.2s\
\[272/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    2.2s\
\[273/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    5.0s\
\[274/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    3.7s\
\[275/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    4.5s\
\[276/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    3.7s\
\[277/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    6.2s\
\[278/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.9s\
\[279/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    3.7s\
\[280/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00   13.1s\
\[281/300\] mango1.5-awq-w4a16         mx198_longctx     1.00  103.5s\
\[282/300\] mango1.5-awq-w4a16         mxv2_252_thai     1.00   13.7s\
\[283/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00   21.2s\
\[284/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   14.7s\
\[285/300\] mango1.5-awq-w4a16         mxv2_131_math     1.00   85.5s\
\[286/300\] mango1.5-awq-w4a16         mxv2_421_instruction  1.00   73.4s\
\[287/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00   11.9s\
\[288/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   22.0s\
\[289/300\] mango1.5-awq-w4a16         mx420_instruction  1.00   22.6s

<span style="color: rgb(207, 232, 206);">\[300/300\] mango1.5-awq-w4a16         mx164_longctx     1.00  101.0s\
\
wrote /app/results/team-team17-final-20261024T094051-91e345-r1.jsonl</span>
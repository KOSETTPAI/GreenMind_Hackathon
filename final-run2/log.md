# final-run2: cap 64 + MTP k=1

Copy rows from grader History. Blank cells are missing, not zero. Each track has its own baseline: Final η 0.00163 and 87.8%, Validation η 0.00154 and 87.2%. Only the Final counts.

| **#** | **Started** | **Model** | **Score S** | **A** | **R** | **sE** | **sT** | **sL** | **η vs base** | **J/request** | **p95 TTFT** | **p95 TPOT** | **SLO-met** | **Accuracy** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2026-10-24 13:51:55 | mango1.5-awq-w4a16 | **0.0** | 1.00 | 1.000 | 0.00 | 0.02 | 0.24 | 0.80× | 208 | 7.82s | 63 ms | 81/300 | 87.8% |

| Track | Start (UTC+7) | Power | S | A | sE | sT | sL | η / track baseline | J/request | p95 TTFT | p95 TPOT | SLO-met | Accuracy | Prefix hits |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Validation (works-check) |  | card default (400 W) |  |  |  |  |  |  |  |  |  | /100 |  |  |
| **Final** |  | card default (400 W) |  |  |  |  |  |  |  |  |  | /300 |  |  |

run 20261024T135333: 300 calls | 1 models x 300 tasks x 1\
\[1/300\] mango1.5-awq-w4a16         mxv2_411_instruction  0.00    1.8s\
\[2/300\] mango1.5-awq-w4a16         mxv2_215_rag_grounded  1.00    3.5s\
\[3/300\] mango1.5-awq-w4a16         mxv2_243_rag_grounded  1.00    1.0s\
\[4/300\] mango1.5-awq-w4a16         mxv2_199_longctx  1.00    5.7s\
\[5/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    3.0s\
\[6/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.5s\
\[7/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s\
\[8/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.2s\
\[9/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.3s\
\[10/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.3s\
\[11/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    2.6s\
\[12/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s\
\[13/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.2s\
\[14/300\] mango1.5-awq-w4a16         mx444_instruction  1.00    8.8s\
\[15/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.6s\
\[16/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    2.1s\
\[17/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    0.9s\
\[18/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.5s\
\[19/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.1s\
\[20/300\] mango1.5-awq-w4a16         ag061_calc_chain  0.00    4.3s\
\[21/300\] mango1.5-awq-w4a16         mxv2_111_math     1.00    2.3s\
\[22/300\] mango1.5-awq-w4a16         ag018_kv_prefix_sum  0.00    2.7s\
\[23/300\] mango1.5-awq-w4a16         mxv2_221_rag_grounded  1.00    1.1s\
\[24/300\] mango1.5-awq-w4a16         mxv2_209_rag_grounded  1.00    1.5s

run 20261024T135333: 300 calls | 1 models x 300 tasks x 1\
\[1/300\] mango1.5-awq-w4a16         mxv2_411_instruction  0.00    1.8s\
\[2/300\] mango1.5-awq-w4a16         mxv2_215_rag_grounded  1.00    3.5s\
\[3/300\] mango1.5-awq-w4a16         mxv2_243_rag_grounded  1.00    1.0s\
\[4/300\] mango1.5-awq-w4a16         mxv2_199_longctx  1.00    5.7s\
\[5/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    3.0s\
\[6/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.5s\
\[7/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s\
\[8/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.2s\
\[9/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.3s\
\[10/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.3s\
\[11/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    2.6s\
\[12/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s\
\[13/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.2s\
\[14/300\] mango1.5-awq-w4a16         mx444_instruction  1.00    8.8s\
\[15/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.6s\
\[16/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    2.1s\
\[17/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    0.9s\
\[18/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.5s\
\[19/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.1s\
\[20/300\] mango1.5-awq-w4a16         ag061_calc_chain  0.00    4.3s\
\[21/300\] mango1.5-awq-w4a16         mxv2_111_math     1.00    2.3s\
\[22/300\] mango1.5-awq-w4a16         ag018_kv_prefix_sum  0.00    2.7s\
\[23/300\] mango1.5-awq-w4a16         mxv2_221_rag_grounded  1.00    1.1s\
\[24/300\] mango1.5-awq-w4a16         mxv2_209_rag_grounded  1.00    1.5s

\[77/300\] mango1.5-awq-w4a16         mx422_instruction  1.00   20.4s\
\[78/300\] mango1.5-awq-w4a16         mxv2_032_code_output  1.00   14.0s\
\[79/300\] mango1.5-awq-w4a16         mxv2_441_instruction  1.00   13.1s\
\[80/300\] mango1.5-awq-w4a16         mxv2_447_instruction  1.00   14.4s\
\[81/300\] mango1.5-awq-w4a16         mx427_instruction  1.00   25.3s\
\[82/300\] mango1.5-awq-w4a16         ag100_inbox_flag  0.00   31.2s\
\[83/300\] mango1.5-awq-w4a16         mxv2_039_code_output  1.00   22.7s\
\[84/300\] mango1.5-awq-w4a16         mxv2_160_longctx  1.00   26.7s\
\[85/300\] mango1.5-awq-w4a16         mxv2_183_longctx  1.00   12.6s\
\[86/300\] mango1.5-awq-w4a16         mx414_instruction  1.00   21.8s\
\[87/300\] mango1.5-awq-w4a16         mxv2_210_rag_grounded  1.00    9.5s\
\[88/300\] mango1.5-awq-w4a16         mxv2_256_thai     1.00   12.4s\
\[89/300\] mango1.5-awq-w4a16         mxv2_293_thai     1.00   21.4s\
\[90/300\] mango1.5-awq-w4a16         mxv2_169_longctx  1.00   12.4s\
\[91/300\] mango1.5-awq-w4a16         mxv2_200_longctx  1.00   24.6s\
\[92/300\] mango1.5-awq-w4a16         mxv2_232_rag_grounded  1.00   12.3s\
\[93/300\] mango1.5-awq-w4a16         mxv2_061_sql_result  1.00   28.1s\
\[94/300\] mango1.5-awq-w4a16         mxv2_180_longctx  1.00   23.4s\
\[95/300\] mango1.5-awq-w4a16         mxv2_077_sql_result  1.00   37.4s\
\[96/300\] mango1.5-awq-w4a16         mxv2_297_thai     1.00   23.9s\
\[97/300\] mango1.5-awq-w4a16         mx430_instruction  1.00   22.9s\
\[98/300\] mango1.5-awq-w4a16         mxv2_226_rag_grounded  1.00    9.9s\
\[99/300\] mango1.5-awq-w4a16         mx413_instruction  1.00   23.5s\
\[100/300\] mango1.5-awq-w4a16         mxv2_277_thai     1.00   10.2s\
\[101/300\] mango1.5-awq-w4a16         mxv2_238_rag_grounded  1.00   10.0s\
\[102/300\] mango1.5-awq-w4a16         mxv2_133_math     1.00   14.9s\
\[103/300\] mango1.5-awq-w4a16         mx443_instruction  0.00   35.2s\
\[104/300\] mango1.5-awq-w4a16         mx424_instruction  1.00   16.1s\
\[105/300\] mango1.5-awq-w4a16         mxv2_281_thai     1.00   24.1s\
\[106/300\] mango1.5-awq-w4a16         mxv2_164_longctx  1.00   13.6s

<span style="color: rgb(207, 232, 206);">130/300\] mango1.5-awq-w4a16         mxv2_125_math     1.00   10.0s\
\[131/300\] mango1.5-awq-w4a16         mxv2_492_complexity  1.00   14.9s\
\[132/300\] mango1.5-awq-w4a16         mx435_instruction  1.00   41.5s\
\[133/300\] mango1.5-awq-w4a16         mx417_instruction  1.00   14.9s\
\[134/300\] mango1.5-awq-w4a16         mxv2_253_thai     1.00   11.7s\
\[135/300\] mango1.5-awq-w4a16         mxv2_426_instruction  1.00   22.6s\
\[136/300\] mango1.5-awq-w4a16         mxv2_279_thai     1.00   17.9s\
\[137/300\] mango1.5-awq-w4a16         mxv2_432_instruction  1.00   18.8s\
\[138/300\] mango1.5-awq-w4a16         mxv2_246_rag_grounded  1.00    9.9s\
\[139/300\] mango1.5-awq-w4a16         mxv2_070_sql_result  1.00   31.9s\
\[140/300\] mango1.5-awq-w4a16         mxv2_044_code_output  1.00   27.8s\
\[141/300\] mango1.5-awq-w4a16         ag075_pages_agg   1.00   36.4s</span>

<span style="color: rgb(207, 232, 206);">130/300\] mango1.5-awq-w4a16         mxv2_125_math     1.00   10.0s\
\[131/300\] mango1.5-awq-w4a16         mxv2_492_complexity  1.00   14.9s\
\[132/300\] mango1.5-awq-w4a16         mx435_instruction  1.00   41.5s\
\[133/300\] mango1.5-awq-w4a16         mx417_instruction  1.00   14.9s\
\[134/300\] mango1.5-awq-w4a16         mxv2_253_thai     1.00   11.7s\
\[135/300\] mango1.5-awq-w4a16         mxv2_426_instruction  1.00   22.6s\
\[136/300\] mango1.5-awq-w4a16         mxv2_279_thai     1.00   17.9s\
\[137/300\] mango1.5-awq-w4a16         mxv2_432_instruction  1.00   18.8s\
\[138/300\] mango1.5-awq-w4a16         mxv2_246_rag_grounded  1.00    9.9s\
\[139/300\] mango1.5-awq-w4a16         mxv2_070_sql_result  1.00   31.9s\
\[140/300\] mango1.5-awq-w4a16         mxv2_044_code_output  1.00   27.8s\
\[141/300\] mango1.5-awq-w4a16         ag075_pages_agg   1.00   36.4s</span>

<span style="color: rgb(207, 232, 206);">\[189/300\] mango1.5-awq-w4a16         mx407_instruction  1.00   23.0s\
\[190/300\] mango1.5-awq-w4a16         mxv2_264_thai     1.00   18.1s\
\[191/300\] mango1.5-awq-w4a16         ag002_kv_winner   1.00   63.6s\
\[192/300\] mango1.5-awq-w4a16         mxv2_179_longctx  1.00   16.5s\
\[193/300\] mango1.5-awq-w4a16         mxv2_438_instruction  1.00   24.6s\
\[194/300\] mango1.5-awq-w4a16         ag087_inbox_flag  1.00   30.6s\
\[195/300\] mango1.5-awq-w4a16         mxv2_435_instruction  0.00   29.4s\
\[196/300\] mango1.5-awq-w4a16         mxv2_066_sql_result  1.00   42.8s\
\[197/300\] mango1.5-awq-w4a16         mx425_instruction  1.00   44.0s\
\[198/300\] mango1.5-awq-w4a16         ag020_orders_policy  1.00   58.2s\
\[199/300\] mango1.5-awq-w4a16         ag022_orders_policy  1.00   41.3s\
\[200/300\] mango1.5-awq-w4a16         ag070_calc_chain  0.00   42.7s\
\[201/300\] mango1.5-awq-w4a16         mxv2_424_instruction  1.00   25.9s\
\[202/300\] mango1.5-awq-w4a16         ag047_files_find_port  1.00   23.4s\
\[203/300\] mango1.5-awq-w4a16         ag090_inbox_flag  1.00   39.9s\
\[204/300\] mango1.5-awq-w4a16         mxv2_428_instruction  1.00   14.1s\
\[205/300\] mango1.5-awq-w4a16         ag038_orders_policy  1.00   46.9s\
\[206/300\] mango1.5-awq-w4a16         mxv2_016_code_output  1.00    7.0s\
\[207/300\] mango1.5-awq-w4a16         mxv2_269_thai     1.00    4.7s\
\[208/300\] mango1.5-awq-w4a16         mxv2_402_instruction  1.00   22.2s\
\[209/300\] mango1.5-awq-w4a16         ag099_inbox_flag  1.00   39.9s\
\[210/300\] mango1.5-awq-w4a16         ag063_calc_chain  1.00   25.7s\
\[211/300\] mango1.5-awq-w4a16         mx433_instruction  1.00   62.4s\
\[212/300\] mango1.5-awq-w4a16         mx423_instruction  1.00   23.2s\
\[213/300\] mango1.5-awq-w4a16         ag076_pages_agg   1.00   33.9s\
\[214/300\] mango1.5-awq-w4a16         ag037_orders_policy  1.00   43.0s\
\[215/300\] mango1.5-awq-w4a16         mxv2_412_instruction  1.00   21.6s\
\[216/300\] mango1.5-awq-w4a16         ag029_orders_policy  1.00   42.6s\
\[217/300\] mango1.5-awq-w4a16         ag096_inbox_flag  0.00   17.6s\
\[218/300\] mango1.5-awq-w4a16         ag041_files_find_port  1.00   33.3s</span>

\[217/300\] mango1.5-awq-w4a16         ag096_inbox_flag  0.00   17.6s\
\[218/300\] mango1.5-awq-w4a16         ag041_files_find_port  1.00   33.3s\
\[219/300\] mango1.5-awq-w4a16         mxv2_408_instruction  1.00   22.4s\
\[220/300\] mango1.5-awq-w4a16         mxv2_170_longctx  1.00   23.9s\
\[221/300\] mango1.5-awq-w4a16         mxv2_414_instruction  1.00   48.4s\
\[222/300\] mango1.5-awq-w4a16         mxv2_418_instruction  1.00   23.3s\
\[223/300\] mango1.5-awq-w4a16         ag060_calc_chain  1.00   29.4s\
\[224/300\] mango1.5-awq-w4a16         mxv2_030_code_output  1.00    4.1s\
\[225/300\] mango1.5-awq-w4a16         mxv2_231_rag_grounded  1.00    3.1s\
\[226/300\] mango1.5-awq-w4a16         mxv2_430_instruction  1.00   28.4s\
\[227/300\] mango1.5-awq-w4a16         mx437_instruction  1.00    9.6s\
\[228/300\] mango1.5-awq-w4a16         ag058_calc_chain  0.00   27.1s\
\[229/300\] mango1.5-awq-w4a16         ag008_kv_winner   1.00   45.8s\
\[230/300\] mango1.5-awq-w4a16         mx428_instruction  1.00   14.8s\
\[231/300\] mango1.5-awq-w4a16         mxv2_422_instruction  1.00    9.9s\
\[232/300\] mango1.5-awq-w4a16         ag036_orders_policy  1.00   33.0s\
\[233/300\] mango1.5-awq-w4a16         ag088_inbox_flag  1.00   28.6s\
\[234/300\] mango1.5-awq-w4a16         mxv2_404_instruction  1.00    7.1s\
\[235/300\] mango1.5-awq-w4a16         mxv2_051_sql_result  1.00   14.6s\
\[236/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    5.2s\
\[237/300\] mango1.5-awq-w4a16         mx164_longctx     0.00    5.1s\
\[238/300\] mango1.5-awq-w4a16         mx445_instruction  1.00   12.8s\
\[239/300\] mango1.5-awq-w4a16         ag028_orders_policy  1.00   54.5s\
\[240/300\] mango1.5-awq-w4a16         ag052_files_fix_conflict  0.00    7.6s\
\[241/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    7.3s\
\[242/300\] mango1.5-awq-w4a16         mxv2_449_instruction  1.00   43.3s\
\[243/300\] mango1.5-awq-w4a16         mxv2_478_complexity  1.00   33.0s\
\[244/300\] mango1.5-awq-w4a16         mx450_instruction  1.00   30.2s\
\[245/300\] mango1.5-awq-w4a16         mxv2_120_math     1.00    4.6s\
\[246/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   24.7s

\[236/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    5.2s\
\[237/300\] mango1.5-awq-w4a16         mx164_longctx     0.00    5.1s\
\[238/300\] mango1.5-awq-w4a16         mx445_instruction  1.00   12.8s\
\[239/300\] mango1.5-awq-w4a16         ag028_orders_policy  1.00   54.5s\
\[240/300\] mango1.5-awq-w4a16         ag052_files_fix_conflict  0.00    7.6s\
\[241/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    7.3s\
\[242/300\] mango1.5-awq-w4a16         mxv2_449_instruction  1.00   43.3s\
\[243/300\] mango1.5-awq-w4a16         mxv2_478_complexity  1.00   33.0s\
\[244/300\] mango1.5-awq-w4a16         mx450_instruction  1.00   30.2s\
\[245/300\] mango1.5-awq-w4a16         mxv2_120_math     1.00    4.6s\
\[246/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   24.7s\
\[247/300\] mango1.5-awq-w4a16         mxv2_262_thai     1.00    7.0s\
\[248/300\] mango1.5-awq-w4a16         mxv2_455_complexity  1.00   72.1s\
\[249/300\] mango1.5-awq-w4a16         mx404_instruction  0.00    5.8s\
\[250/300\] mango1.5-awq-w4a16         mx415_instruction  1.00   10.5s\
\[251/300\] mango1.5-awq-w4a16         mxv2_213_rag_grounded  1.00    1.2s\
\[252/300\] mango1.5-awq-w4a16         mxv2_268_thai     1.00    7.0s\
\[253/300\] mango1.5-awq-w4a16         mxv2_278_thai     1.00   90.0s\
\[254/300\] mango1.5-awq-w4a16         mx441_instruction  1.00    2.8s\
\[255/300\] mango1.5-awq-w4a16         mxv2_287_thai     1.00    2.7s\
\[256/300\] mango1.5-awq-w4a16         mxv2_225_rag_grounded  1.00    1.2s\
\[257/300\] mango1.5-awq-w4a16         mxv2_092_sql_result  1.00   63.5s\
\[258/300\] mango1.5-awq-w4a16         mxv2_004_code_output  1.00    3.4s\
\[259/300\] mango1.5-awq-w4a16         ag082_pages_agg   1.00   12.0s\
\[260/300\] mango1.5-awq-w4a16         ag023_orders_policy  1.00    8.9s\
\[261/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   32.3s\
\[262/300\] mango1.5-awq-w4a16         mxv2_234_rag_grounded  1.00    1.3s\
\[263/300\] mango1.5-awq-w4a16         mxv2_100_sql_result  1.00   16.2s\
\[264/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    4.0s\
\[265/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    3.2s

\[236/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    5.2s\
\[237/300\] mango1.5-awq-w4a16         mx164_longctx     0.00    5.1s\
\[238/300\] mango1.5-awq-w4a16         mx445_instruction  1.00   12.8s\
\[239/300\] mango1.5-awq-w4a16         ag028_orders_policy  1.00   54.5s\
\[240/300\] mango1.5-awq-w4a16         ag052_files_fix_conflict  0.00    7.6s\
\[241/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    7.3s\
\[242/300\] mango1.5-awq-w4a16         mxv2_449_instruction  1.00   43.3s\
\[243/300\] mango1.5-awq-w4a16         mxv2_478_complexity  1.00   33.0s\
\[244/300\] mango1.5-awq-w4a16         mx450_instruction  1.00   30.2s\
\[245/300\] mango1.5-awq-w4a16         mxv2_120_math     1.00    4.6s\
\[246/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   24.7s\
\[247/300\] mango1.5-awq-w4a16         mxv2_262_thai     1.00    7.0s\
\[248/300\] mango1.5-awq-w4a16         mxv2_455_complexity  1.00   72.1s\
\[249/300\] mango1.5-awq-w4a16         mx404_instruction  0.00    5.8s\
\[250/300\] mango1.5-awq-w4a16         mx415_instruction  1.00   10.5s\
\[251/300\] mango1.5-awq-w4a16         mxv2_213_rag_grounded  1.00    1.2s\
\[252/300\] mango1.5-awq-w4a16         mxv2_268_thai     1.00    7.0s\
\[253/300\] mango1.5-awq-w4a16         mxv2_278_thai     1.00   90.0s\
\[254/300\] mango1.5-awq-w4a16         mx441_instruction  1.00    2.8s\
\[255/300\] mango1.5-awq-w4a16         mxv2_287_thai     1.00    2.7s\
\[256/300\] mango1.5-awq-w4a16         mxv2_225_rag_grounded  1.00    1.2s\
\[257/300\] mango1.5-awq-w4a16         mxv2_092_sql_result  1.00   63.5s\
\[258/300\] mango1.5-awq-w4a16         mxv2_004_code_output  1.00    3.4s\
\[259/300\] mango1.5-awq-w4a16         ag082_pages_agg   1.00   12.0s\
\[260/300\] mango1.5-awq-w4a16         ag023_orders_policy  1.00    8.9s\
\[261/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   32.3s\
\[262/300\] mango1.5-awq-w4a16         mxv2_234_rag_grounded  1.00    1.3s\
\[263/300\] mango1.5-awq-w4a16         mxv2_100_sql_result  1.00   16.2s\
\[264/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    4.0s\
\[265/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    3.2s

<span style="color: rgb(207, 232, 206);">\[261/300\] mango1.5-awq-w4a16         mxv2_108_math     1.00   32.3s\
\[262/300\] mango1.5-awq-w4a16         mxv2_234_rag_grounded  1.00    1.3s\
\[263/300\] mango1.5-awq-w4a16         mxv2_100_sql_result  1.00   16.2s\
\[264/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    4.0s\
\[265/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    3.2s\
\[266/300\] mango1.5-awq-w4a16         ag021_orders_policy  1.00    8.5s\
\[267/300\] mango1.5-awq-w4a16         mxv2_240_rag_grounded  1.00    1.6s\
\[268/300\] mango1.5-awq-w4a16         mxv2_419_instruction  0.00    1.3s\
\[269/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    8.4s\
\[270/300\] mango1.5-awq-w4a16         mxv2_405_instruction  0.00  105.7s\
\[271/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    3.3s\
\[272/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    3.1s\
\[273/300\] mango1.5-awq-w4a16         mxv2_421_instruction  0.00   61.5s\
\[274/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    2.6s\
\[275/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00   13.0s\
\[276/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    4.7s\
\[277/300\] mango1.5-awq-w4a16         mx420_instruction  1.00    9.7s\
\[278/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    3.2s\
\[279/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    3.3s\
\[280/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    2.7s\
\[281/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    5.3s\
\[282/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00   12.2s\
\[283/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.5s\
\[284/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    3.2s\
\[285/300\] mango1.5-awq-w4a16         mxv2_252_thai     1.00   11.9s\
\[286/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   13.6s\
\[287/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00    9.9s\
\[288/300\] mango1.5-awq-w4a16         mxv2_131_math     1.00   84.9s\
\[289/300\] mango1.5-awq-w4a16         mxv2_284_thai     1.00   18.4s\
\[290/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   30.0s</span>

**▾ Hide log**

\[269/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    8.4s\
\[270/300\] mango1.5-awq-w4a16         mxv2_405_instruction  0.00  105.7s\
\[271/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    3.3s\
\[272/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    3.1s\
\[273/300\] mango1.5-awq-w4a16         mxv2_421_instruction  0.00   61.5s\
\[274/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    2.6s\
\[275/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00   13.0s\
\[276/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    4.7s\
\[277/300\] mango1.5-awq-w4a16         mx420_instruction  1.00    9.7s\
\[278/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    3.2s\
\[279/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    3.3s\
\[280/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    2.7s\
\[281/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    5.3s\
\[282/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00   12.2s\
\[283/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.5s\
\[284/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    3.2s\
\[285/300\] mango1.5-awq-w4a16         mxv2_252_thai     1.00   11.9s\
\[286/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   13.6s\
\[287/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00    9.9s\
\[288/300\] mango1.5-awq-w4a16         mxv2_131_math     1.00   84.9s\
\[289/300\] mango1.5-awq-w4a16         mxv2_284_thai     1.00   18.4s\
\[290/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   30.0s\
\[291/300\] mango1.5-awq-w4a16         mx198_longctx     1.00  142.9s\
\[292/300\] mango1.5-awq-w4a16         mxv2_149_math     0.00  160.3s\
\[293/300\] mango1.5-awq-w4a16         mxv2_119_math     0.00  161.6s\
\[294/300\] mango1.5-awq-w4a16         mxv2_190_longctx  1.00  161.6s\
\[295/300\] mango1.5-awq-w4a16         mxv2_442_instruction  0.00  152.8s\
\[296/300\] mango1.5-awq-w4a16         mxv2_134_math     0.00  151.5s\
\[297/300\] mango1.5-awq-w4a16         mxv2_126_math     1.00  147.9s\
\[298/300\] mango1.5-awq-w4a16         mx405_instruction  0.00  132.9s

<span style="color: rgb(207, 232, 206);">298/300\] mango1.5-awq-w4a16         mx405_instruction  0.00  132.9s\
\[299/300\] mango1.5-awq-w4a16         mxv2_429_instruction  1.00  132.1s\
\[300/300\] mango1.5-awq-w4a16         mx401_instruction  1.00   94.4s\
\
wrote /app/results/team-team17-final-20261024T135155-f1e948-r1.jsonl</span>
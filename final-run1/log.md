# run 20261024T134210: 300 calls | 1 models x 300 tasks x 1

| **#** | **Started** | **Model** | **Score S** | **A** | **R** | **sE** | **sT** | **sL** | **η vs base** | **J/request** | **p95 TTFT** | **p95 TPOT** | **SLO-met** | **Accuracy** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3 | 2026-10-24 13:40:31 | mango1.5-awq-w4a16 | **0.0** | 0.98 | 0.978 | 0.00 | 0.03 | 0.26 | 0.94× | 190 | 6.54s | 67 ms | 87/300 | 85.8% |

\[1/300\] mango1.5-awq-w4a16         mxv2_215_rag_grounded  1.00    3.5s

\[2/300\] mango1.5-awq-w4a16         mxv2_243_rag_grounded  1.00    1.0s

\[3/300\] mango1.5-awq-w4a16         mxv2_199_longctx  1.00    5.8s

\[4/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    2.8s

\[5/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.5s

\[6/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s

\[7/300\] mango1.5-awq-w4a16         mxv2_411_instruction  1.00   12.8s

\[8/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.4s

\[9/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.5s

\[10/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s

\[11/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    3.0s

\[12/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.9s

\[13/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.4s

\[14/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.8s

\[15/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.6s

\[16/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    1.1s

\[17/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    2.5s

\[18/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.7s

\[19/300\] mango1.5-awq-w4a16         ag061_calc_chain  1.00    5.2s

final-run1: cap 64

Copy rows from grader History. Blank cells are missing, not zero. Each track has its own baseline: Final η 0.00163 and 87.8%, Validation η 0.00154 and 87.2%. Only the Final counts.

| Track | Start (UTC+7) | Power | S | A | sE | sT | sL | η / track baseline | J/request | p95 TTFT | p95 TPOT | SLO-met | Accuracy | Prefix hits |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Validation (works-check) |  | card default (400 W) |  |  |  |  |  |  |  |  |  | /100 |  |  |
| **Final** |  | card default (400 W) |  |  |  |  |  |  |  |  |  | /300 |  |  |

\[4/300\] mango1.5-awq-w4a16         mxv2_198_longctx  1.00    2.8s\
\[5/300\] mango1.5-awq-w4a16         ag097_inbox_flag  0.00    6.5s\
\[6/300\] mango1.5-awq-w4a16         mxv2_144_math     1.00    5.7s\
\[7/300\] mango1.5-awq-w4a16         mxv2_411_instruction  1.00   12.8s\
\[8/300\] mango1.5-awq-w4a16         mxv2_489_complexity  1.00    1.4s\
\[9/300\] mango1.5-awq-w4a16         mx429_instruction  1.00    4.5s\
\[10/300\] mango1.5-awq-w4a16         mxv2_295_thai     1.00    2.8s\
\[11/300\] mango1.5-awq-w4a16         ag081_pages_agg   0.00    3.0s\
\[12/300\] mango1.5-awq-w4a16         mxv2_450_instruction  1.00    9.9s\
\[13/300\] mango1.5-awq-w4a16         mxv2_155_longctx  1.00    8.4s\
\[14/300\] mango1.5-awq-w4a16         mx193_longctx     1.00    2.8s\
\[15/300\] mango1.5-awq-w4a16         mxv2_018_code_output  1.00    2.6s\
\[16/300\] mango1.5-awq-w4a16         mxv2_242_rag_grounded  1.00    1.1s\
\[17/300\] mango1.5-awq-w4a16         mxv2_485_complexity  1.00    2.5s\
\[18/300\] mango1.5-awq-w4a16         mxv2_431_instruction  1.00    2.7s\
\[19/300\] mango1.5-awq-w4a16         ag061_calc_chain  1.00    5.2s\
\[20/300\] mango1.5-awq-w4a16         mxv2_111_math     1.00    5.2s\
\[21/300\] mango1.5-awq-w4a16         mxv2_221_rag_grounded  1.00    3.7s\
\[22/300\] mango1.5-awq-w4a16         ag018_kv_prefix_sum  0.00    5.6s\
\[23/300\] mango1.5-awq-w4a16         mxv2_209_rag_grounded  1.00    2.0s\
\[24/300\] mango1.5-awq-w4a16         mxv2_222_rag_grounded  1.00    3.6s\
\[25/300\] mango1.5-awq-w4a16         mxv2_245_rag_grounded  1.00    6.0s\
\[26/300\] mango1.5-awq-w4a16         ag079_pages_agg   0.00    8.6s\
\[27/300\] mango1.5-awq-w4a16         mxv2_207_rag_grounded  1.00    8.8s\
\[28/300\] mango1.5-awq-w4a16         mxv2_229_rag_grounded  1.00    5.2s\
\[29/300\] mango1.5-awq-w4a16         mxv2_045_code_output  1.00    8.1s\
\[30/300\] mango1.5-awq-w4a16         mx169_longctx     1.00    5.4s\
\[31/300\] mango1.5-awq-w4a16         mx444_instruction  1.00   21.2s\
\[32/300\] mango1.5-awq-w4a16         mxv2_023_code_output  1.00   10.3s\
\[33/300\] mango1.5-awq-w4a16         mxv2_227_rag_grounded  1.00    4.3s

\[112/300\] mango1.5-awq-w4a16         mx435_instruction  1.00   33.3s\
\[113/300\] mango1.5-awq-w4a16         ag067_calc_chain  1.00   34.4s\
\[114/300\] mango1.5-awq-w4a16         mxv2_014_code_output  1.00   16.3s\
\[115/300\] mango1.5-awq-w4a16         mxv2_444_instruction  1.00    8.9s\
\[116/300\] mango1.5-awq-w4a16         mx199_longctx     1.00   12.5s\
\[117/300\] mango1.5-awq-w4a16         mxv2_414_instruction  1.00   16.9s\
\[118/300\] mango1.5-awq-w4a16         mxv2_224_rag_grounded  1.00    7.6s\
\[119/300\] mango1.5-awq-w4a16         mxv2_230_rag_grounded  1.00    7.7s\
\[120/300\] mango1.5-awq-w4a16         mxv2_217_rag_grounded  1.00    8.7s\
\[121/300\] mango1.5-awq-w4a16         mxv2_249_rag_grounded  1.00    7.4s\
\[122/300\] mango1.5-awq-w4a16         mxv2_282_thai     1.00   16.1s\
\[123/300\] mango1.5-awq-w4a16         ag075_pages_agg   1.00   28.7s\
\[124/300\] mango1.5-awq-w4a16         mxv2_129_math     1.00   15.8s\
\[125/300\] mango1.5-awq-w4a16         mxv2_248_rag_grounded  1.00    7.2s\
\[126/300\] mango1.5-awq-w4a16         mx409_instruction  1.00   17.6s\
\[127/300\] mango1.5-awq-w4a16         mxv2_241_rag_grounded  1.00   11.7s\
\[128/300\] mango1.5-awq-w4a16         mxv2_218_rag_grounded  1.00    9.3s\
\[129/300\] mango1.5-awq-w4a16         mxv2_125_math     1.00    8.8s\
\[130/300\] mango1.5-awq-w4a16         mxv2_455_complexity  1.00   32.3s\
\[131/300\] mango1.5-awq-w4a16         mxv2_492_complexity  1.00   13.8s\
\[132/300\] mango1.5-awq-w4a16         mxv2_253_thai     1.00   10.3s\
\[133/300\] mango1.5-awq-w4a16         mx417_instruction  1.00   13.8s\
\[134/300\] mango1.5-awq-w4a16         mxv2_279_thai     1.00   16.1s\
\[135/300\] mango1.5-awq-w4a16         mx439_instruction  1.00   15.8s\
\[136/300\] mango1.5-awq-w4a16         mx402_instruction  1.00   13.8s\
\[137/300\] mango1.5-awq-w4a16         mxv2_432_instruction  1.00   17.7s\
\[138/300\] mango1.5-awq-w4a16         mxv2_185_longctx  0.00    9.8s\
\[139/300\] mango1.5-awq-w4a16         mxv2_426_instruction  1.00   22.6s\
\[140/300\] mango1.5-awq-w4a16         mxv2_246_rag_grounded  1.00    9.1s\
\[141/300\] mango1.5-awq-w4a16         mxv2_294_thai     1.00   30.6s

<span style="color: rgb(207, 232, 206);">\[134/300\] mango1.5-awq-w4a16         mxv2_279_thai     1.00   16.1s\
\[135/300\] mango1.5-awq-w4a16         mx439_instruction  1.00   15.8s\
\[136/300\] mango1.5-awq-w4a16         mx402_instruction  1.00   13.8s\
\[137/300\] mango1.5-awq-w4a16         mxv2_432_instruction  1.00   17.7s\
\[138/300\] mango1.5-awq-w4a16         mxv2_185_longctx  0.00    9.8s\
\[139/300\] mango1.5-awq-w4a16         mxv2_426_instruction  1.00   22.6s\
\[140/300\] mango1.5-awq-w4a16         mxv2_246_rag_grounded  1.00    9.1s\
\[141/300\] mango1.5-awq-w4a16         mxv2_294_thai     1.00   30.6s\
\[142/300\] mango1.5-awq-w4a16         mxv2_070_sql_result  1.00   32.5s\
\[143/300\] mango1.5-awq-w4a16         ag033_orders_policy  0.00   44.3s\
\[144/300\] mango1.5-awq-w4a16         mxv2_173_longctx  1.00   13.3s\
\[145/300\] mango1.5-awq-w4a16         mxv2_416_instruction  1.00   23.3s\
\[146/300\] mango1.5-awq-w4a16         mxv2_044_code_output  1.00   28.6s\
\[147/300\] mango1.5-awq-w4a16         mx432_instruction  1.00   18.6s\
\[148/300\] mango1.5-awq-w4a16         mxv2_239_rag_grounded  1.00    9.1s\
\[149/300\] mango1.5-awq-w4a16         ag010_kv_swap     1.00   27.6s\
\[150/300\] mango1.5-awq-w4a16         mxv2_042_code_output  1.00   14.5s\
\[151/300\] mango1.5-awq-w4a16         mxv2_195_longctx  1.00   34.2s\
\[152/300\] mango1.5-awq-w4a16         mxv2_267_thai     1.00    9.4s\
\[153/300\] mango1.5-awq-w4a16         mx424_instruction  1.00   28.6s\
\[154/300\] mango1.5-awq-w4a16         mxv2_283_thai     1.00   10.8s\
\[155/300\] mango1.5-awq-w4a16         mxv2_448_instruction  1.00   19.4s\
\[156/300\] mango1.5-awq-w4a16         mxv2_211_rag_grounded  1.00   11.8s\
\[157/300\] mango1.5-awq-w4a16         mxv2_233_rag_grounded  1.00   10.7s\
\[158/300\] mango1.5-awq-w4a16         mxv2_204_rag_grounded  1.00   10.6s\
\[159/300\] mango1.5-awq-w4a16         mxv2_247_rag_grounded  1.00   15.1s\
\[160/300\] mango1.5-awq-w4a16         mx173_longctx     1.00   14.4s\
\[161/300\] mango1.5-awq-w4a16         mx440_instruction  1.00   38.7s\
\[162/300\] mango1.5-awq-w4a16         mx448_instruction  1.00   12.2s\
\[163/300\] mango1.5-awq-w4a16         ag046_files_fix_conflict  0.00   22.2s</span>

**▾ Hide log**

\[218/300\] mango1.5-awq-w4a16         mx423_instruction  1.00   19.5s\
\[219/300\] mango1.5-awq-w4a16         mxv2_412_instruction  1.00   17.3s\
\[220/300\] mango1.5-awq-w4a16         ag041_files_find_port  1.00   28.7s\
\[221/300\] mango1.5-awq-w4a16         mxv2_443_instruction  0.00   34.8s\
\[222/300\] mango1.5-awq-w4a16         ag096_inbox_flag  0.00   13.4s\
\[223/300\] mango1.5-awq-w4a16         ag029_orders_policy  1.00   38.5s\
\[224/300\] mango1.5-awq-w4a16         mxv2_269_thai     1.00    2.5s\
\[225/300\] mango1.5-awq-w4a16         mxv2_408_instruction  1.00   18.8s\
\[226/300\] mango1.5-awq-w4a16         ag060_calc_chain  0.00   23.5s\
\[227/300\] mango1.5-awq-w4a16         mxv2_170_longctx  1.00   19.4s\
\[228/300\] mango1.5-awq-w4a16         ag058_calc_chain  0.00   19.8s\
\[229/300\] mango1.5-awq-w4a16         mx437_instruction  1.00    4.8s\
\[230/300\] mango1.5-awq-w4a16         ag008_kv_winner   1.00   38.8s\
\[231/300\] mango1.5-awq-w4a16         mxv2_418_instruction  1.00   20.9s\
\[232/300\] mango1.5-awq-w4a16         ag036_orders_policy  1.00   25.8s\
\[233/300\] mango1.5-awq-w4a16         mx428_instruction  1.00    8.0s\
\[234/300\] mango1.5-awq-w4a16         mxv2_030_code_output  1.00    1.9s\
\[235/300\] mango1.5-awq-w4a16         ag028_orders_policy  1.00   46.1s\
\[236/300\] mango1.5-awq-w4a16         mxv2_430_instruction  1.00   26.5s\
\[237/300\] mango1.5-awq-w4a16         mxv2_231_rag_grounded  1.00    1.5s\
\[238/300\] mango1.5-awq-w4a16         mxv2_422_instruction  1.00    5.7s\
\[239/300\] mango1.5-awq-w4a16         mxv2_254_thai     1.00   17.1s\
\[240/300\] mango1.5-awq-w4a16         mxv2_404_instruction  1.00    4.8s\
\[241/300\] mango1.5-awq-w4a16         mxv2_405_instruction  1.00   79.6s\
\[242/300\] mango1.5-awq-w4a16         ag052_files_fix_conflict  0.00    4.4s\
\[243/300\] mango1.5-awq-w4a16         mx445_instruction  1.00   10.5s\
\[244/300\] mango1.5-awq-w4a16         ag009_kv_prefix_sum  1.00    4.6s\
\[245/300\] mango1.5-awq-w4a16         ag048_files_fix_conflict  0.00    4.0s\
\[246/300\] mango1.5-awq-w4a16         mxv2_278_thai     1.00   80.8s\
\[247/300\] mango1.5-awq-w4a16         mxv2_478_complexity  1.00   31.0s

\[259/300\] mango1.5-awq-w4a16         mx441_instruction  1.00    2.5s\
\[260/300\] mango1.5-awq-w4a16         ag082_pages_agg   1.00    9.1s\
\[261/300\] mango1.5-awq-w4a16         mxv2_225_rag_grounded  1.00    0.9s\
\[262/300\] mango1.5-awq-w4a16         mxv2_004_code_output  1.00    2.5s\
\[263/300\] mango1.5-awq-w4a16         ag023_orders_policy  1.00    6.6s\
\[264/300\] mango1.5-awq-w4a16         mxv2_100_sql_result  1.00   11.6s\
\[265/300\] mango1.5-awq-w4a16         mx450_instruction  1.00   38.2s\
\[266/300\] mango1.5-awq-w4a16         mxv2_234_rag_grounded  1.00    0.9s\
\[267/300\] mango1.5-awq-w4a16         ag001_kv_swap     1.00    3.6s\
\[268/300\] mango1.5-awq-w4a16         ag021_orders_policy  1.00    6.2s\
\[269/300\] mango1.5-awq-w4a16         mx446_instruction  1.00    2.9s\
\[270/300\] mango1.5-awq-w4a16         mxv2_240_rag_grounded  1.00    0.9s\
\[271/300\] mango1.5-awq-w4a16         ag093_inbox_flag  1.00    6.3s\
\[272/300\] mango1.5-awq-w4a16         mxv2_419_instruction  0.00    1.0s\
\[273/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    2.7s\
\[274/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00    9.6s\
\[275/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    2.6s\
\[276/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00    4.4s\
\[277/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    1.9s\
\[278/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    3.7s\
\[279/300\] mango1.5-awq-w4a16         mxv2_252_thai     0.00    6.4s\
\[280/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    2.7s\
\[281/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    2.7s\
\[282/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    2.2s\
\[283/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    4.5s\
\[284/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.0s\
\[285/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    2.7s\
\[286/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   12.8s\
\[287/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   17.2s\
\[288/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00    9.6s

\[273/300\] mango1.5-awq-w4a16         ag072_pages_agg   0.00    2.7s\
\[274/300\] mango1.5-awq-w4a16         mxv2_292_thai     1.00    9.6s\
\[275/300\] mango1.5-awq-w4a16         mxv2_178_longctx  1.00    2.6s\
\[276/300\] mango1.5-awq-w4a16         mxv2_257_thai     1.00    4.4s\
\[277/300\] mango1.5-awq-w4a16         mx426_instruction  1.00    1.9s\
\[278/300\] mango1.5-awq-w4a16         mx434_instruction  0.00    3.7s\
\[279/300\] mango1.5-awq-w4a16         mxv2_252_thai     0.00    6.4s\
\[280/300\] mango1.5-awq-w4a16         mxv2_415_instruction  1.00    2.7s\
\[281/300\] mango1.5-awq-w4a16         mx447_instruction  1.00    2.7s\
\[282/300\] mango1.5-awq-w4a16         mx408_instruction  1.00    2.2s\
\[283/300\] mango1.5-awq-w4a16         mxv2_046_code_output  1.00    4.5s\
\[284/300\] mango1.5-awq-w4a16         mxv2_401_instruction  1.00    2.0s\
\[285/300\] mango1.5-awq-w4a16         mxv2_439_instruction  1.00    2.7s\
\[286/300\] mango1.5-awq-w4a16         mxv2_413_instruction  1.00   12.8s\
\[287/300\] mango1.5-awq-w4a16         mxv2_437_instruction  0.00   17.2s\
\[288/300\] mango1.5-awq-w4a16         mxv2_064_sql_result  1.00    9.6s\
\[289/300\] mango1.5-awq-w4a16         mx420_instruction  1.00   21.3s\
\[290/300\] mango1.5-awq-w4a16         mxv2_131_math     1.00   92.8s\
\[291/300\] mango1.5-awq-w4a16         mxv2_284_thai     0.00   17.2s\
\[292/300\] mango1.5-awq-w4a16         mxv2_149_math     0.00  144.2s\
\[293/300\] mango1.5-awq-w4a16         mxv2_119_math     0.00  142.5s\
\[294/300\] mango1.5-awq-w4a16         mxv2_442_instruction  0.00  134.1s\
\[295/300\] mango1.5-awq-w4a16         mxv2_134_math     1.00  132.6s\
\[296/300\] mango1.5-awq-w4a16         mxv2_276_thai     1.00  131.0s\
\[297/300\] mango1.5-awq-w4a16         mx405_instruction  0.00  114.8s\
\[298/300\] mango1.5-awq-w4a16         mxv2_421_instruction  0.00  106.6s\
\[299/300\] mango1.5-awq-w4a16         mxv2_051_sql_result  0.00   87.6s\
\[300/300\] mango1.5-awq-w4a16         mx164_longctx     1.00   83.2s\
\
wrote /app/results/team-team17-final-20261024T134031-8a258a-r1.jsonl
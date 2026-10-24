Baseline (untuned, default vLLM BF16): η\_base = 0.00154 SLO-met requests/J · K = 3× for full energy marks · reference macro-accuracy 87.2%

Practice track — Validation scores are indicative only and are not the graded result. Only the Final test counts.

|  | **Started** | **Model** | **Score S** | **A** | **R** | **sE** | **sT** | **sL** | **η vs base** | **J/request** | **p95 TTFT** | **p95 TPOT** | **SLO-met** | **Accuracy** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 5 | 2026-10-24 09:47:19 | mango1.5-awq-w4a16 | **32.8** | 1.00 | 0.997 | 0.30 | 0.32 | 0.45 | 1.38× | 235 | 3.12s | 55 ms | 50/100 | 86.9% |

\[42/100\] mango1.5-awq-w4a16 ag067_calc_chain 1.00 17.2s\
\[43/100\] mango1.5-awq-w4a16 mxv2_369_security 1.00 13.7s\
\[44/100\] mango1.5-awq-w4a16 mxv2_243_rag_grounded 1.00 2.8s\
\[45/100\] mango1.5-awq-w4a16 mxv2_376_security 1.00 8.4s\
\[46/100\] mango1.5-awq-w4a16 mxv2_356_security 1.00 11.6s\
\[47/100\] mango1.5-awq-w4a16 ag001_kv_swap 1.00 14.0s\
\[48/100\] mango1.5-awq-w4a16 mxv2_381_security 1.00 14.0s\
\[49/100\] mango1.5-awq-w4a16 mxv2_020_code_output 1.00 11.7s\
\[50/100\] mango1.5-awq-w4a16 ag057_calc_chain 1.00 17.5s\
\[51/100\] mango1.5-awq-w4a16 mxv2_370_security 1.00 13.1s\
\[52/100\] mango1.5-awq-w4a16 mxv2_416_instruction 1.00 14.1s\
\[53/100\] mango1.5-awq-w4a16 mxv2_468_complexity 1.00 15.8s\
\[54/100\] mango1.5-awq-w4a16 mxv2_397_security 1.00 11.7s\
\[55/100\] mango1.5-awq-w4a16 mxv2_374_security 1.00 9.8s\
\[56/100\] mango1.5-awq-w4a16 mxv2_362_security 1.00 12.6s\
\[57/100\] mango1.5-awq-w4a16 mxv2_028_code_output 1.00 15.2s\
\[58/100\] mango1.5-awq-w4a16 mxv2_394_security 0.00 13.5s\
\[59/100\] mango1.5-awq-w4a16 mxv2_439_instruction 1.00 9.4s\
\[60/100\] mango1.5-awq-w4a16 mxv2_425_instruction 1.00 16.7s\
\[61/100\] mango1.5-awq-w4a16 mxv2_293_thai 1.00 14.6s\
\[62/100\] mango1.5-awq-w4a16 ag041_files_find_port 1.00 17.5s\
\[63/100\] mango1.5-awq-w4a16 mxv2_353_security 1.00 7.0s\
\[64/100\] mango1.5-awq-w4a16 mxv2_354_security 1.00 9.6s\
\[65/100\] mango1.5-awq-w4a16 ag078_pages_agg 1.00 22.3s\
\[66/100\] mango1.5-awq-w4a16 mxv2_410_instruction 1.00 16.4s\
\[67/100\] mango1.5-awq-w4a16 ag092_inbox_flag 1.00 17.1s\
\[68/100\] mango1.5-awq-w4a16 mxv2_363_security 1.00 14.3s\
\[69/100\] mango1.5-awq-w4a16 mxv2_262_thai 1.00 22.9s\
\[70/100\] mango1.5-awq-w4a16 mxv2_107_math 1.00 8.9s\
\[71/100\] mango1.5-awq-w4a16 mxv2_285_thai 1.00 3.4s

\[69/100\] mango1.5-awq-w4a16 mxv2_262_thai 1.00 22.9s\
\[70/100\] mango1.5-awq-w4a16 mxv2_107_math 1.00 8.9s\
\[71/100\] mango1.5-awq-w4a16 mxv2_285_thai 1.00 3.4s\
\[72/100\] mango1.5-awq-w4a16 mxv2_179_longctx 1.00 5.7s\
\[73/100\] mango1.5-awq-w4a16 mxv2_443_instruction 0.00 29.4s\
\[74/100\] mango1.5-awq-w4a16 mxv2_198_longctx 1.00 4.6s\
\[75/100\] mango1.5-awq-w4a16 ag056_calc_chain 0.00 17.0s\
\[76/100\] mango1.5-awq-w4a16 mxv2_190_longctx 1.00 25.1s\
\[77/100\] mango1.5-awq-w4a16 mxv2_109_math 0.00 14.8s\
\[78/100\] mango1.5-awq-w4a16 ag073_pages_agg 0.00 3.5s\
\[79/100\] mango1.5-awq-w4a16 mxv2_051_sql_result 1.00 26.6s\
\[80/100\] mango1.5-awq-w4a16 mxv2_005_code_output 1.00 4.2s\
\[81/100\] mango1.5-awq-w4a16 ag018_kv_prefix_sum 0.00 6.8s\
\[82/100\] mango1.5-awq-w4a16 ag093_inbox_flag 1.00 17.8s\
\[83/100\] mango1.5-awq-w4a16 ag014_kv_winner 1.00 26.4s\
\[84/100\] mango1.5-awq-w4a16 ag025_orders_policy 1.00 22.3s\
\[85/100\] mango1.5-awq-w4a16 mxv2_366_security 1.00 7.6s\
\[86/100\] mango1.5-awq-w4a16 ag032_orders_policy 0.00 20.2s\
\[87/100\] mango1.5-awq-w4a16 mxv2_430_instruction 1.00 29.7s\
\[88/100\] mango1.5-awq-w4a16 mxv2_434_instruction 1.00 6.9s\
\[89/100\] mango1.5-awq-w4a16 ag027_orders_policy 1.00 10.9s\
\[90/100\] mango1.5-awq-w4a16 ag022_orders_policy 1.00 10.5s\
\[91/100\] mango1.5-awq-w4a16 mxv2_292_thai 1.00 21.1s\
\[92/100\] mango1.5-awq-w4a16 mxv2_099_sql_result 1.00 22.5s\
\[93/100\] mango1.5-awq-w4a16 mxv2_289_thai 1.00 6.9s\
\[94/100\] mango1.5-awq-w4a16 ag088_inbox_flag 1.00 8.2s\
\[95/100\] mango1.5-awq-w4a16 mxv2_095_sql_result 1.00 9.6s\
\[96/100\] mango1.5-awq-w4a16 mxv2_382_security 1.00 25.4s\
\[97/100\] mango1.5-awq-w4a16 ag083_pages_agg 0.00 24.0s\
\[98/100\] mango1.5-awq-w4a16 mxv2_284_thai 1.00 27.9s

<span style="color: rgb(207, 232, 206);">\[98/100\] mango1.5-awq-w4a16 mxv2_284_thai 1.00 27.9s\
\[99/100\] mango1.5-awq-w4a16 mxv2_134_math 1.00 61.6s\
\[100/100\] mango1.5-awq-w4a16 mxv2_124_math 0.00 70.0s\
\
wrote /app/results/team-team17-validation-20261024T094719-0c300c-r1.jsonl</span>

<table style="min-width: 350px;">
<colgroup><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"><col style="min-width: 25px;"></colgroup><tbody><tr><td colspan="1" rowspan="1"><p>2026-10-24 09:47:19</p></td><td colspan="1" rowspan="1"><p>mango1.5-awq-w4a16</p></td><td colspan="1" rowspan="1"><p><strong>32.8</strong></p></td><td colspan="1" rowspan="1"><p>1.00</p></td><td colspan="1" rowspan="1"><p>0.997</p></td><td colspan="1" rowspan="1"><p>0.30</p></td><td colspan="1" rowspan="1"><p>0.32</p></td><td colspan="1" rowspan="1"><p>0.45</p></td><td colspan="1" rowspan="1"><p>1.38×</p></td><td colspan="1" rowspan="1"><p>235</p></td><td colspan="1" rowspan="1"><p>3.12s</p></td><td colspan="1" rowspan="1"><p>55 ms</p></td><td colspan="1" rowspan="1"><p>50/100</p></td><td colspan="1" rowspan="1"><p>86.9%</p></td></tr></tbody>
</table>

## **History — validation**
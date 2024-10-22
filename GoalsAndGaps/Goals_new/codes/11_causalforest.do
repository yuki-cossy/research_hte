*************************************************************************************************
*				Title: causal_forest
*                   
*                                                         User: Michela Carlana
*                                                         Created: 15/01/2020
*                                                         Modified: 15/01/2020
*************************************************************************************************

insheet using "$definitivo/predictions_causalforest.csv", comma names clear

* Global
set scheme s1mono
global controls "female immigrato_prima_gen stdinvalsii stdinvalsii_2 late mom_working_class mom_high_class mom_home mom_unemp mom_miss dad_working_class dad_high_class dad_home dad_unemp dad_miss mom_educ_uni mom_educ_hs mom_educ_lhs mom_educ_mis dad_educ_uni dad_educ_hs dad_educ_lhs dad_educ_mis province_pd province_bs province_mi province_to province_ge std_cit_latin std_cit_afric std_cit_asia std_cit_easteur"

* Labels
lab var preds "Prediction High-Track CATE"
lab var motivation "Aspirations"
lab var barriers "Barriers"
lab var  stdmatiii "INVALSI Math 8"
lab var  stditaiii  "INVALSI Reading 8"
lab var consiglio_lictec2 "Teachers' Recommendation"
lab var lictec2 "High Track"
lab var female "Female"
lab var treat "EOP"
lab var immigrato_prima_gen "First Generation"
lab var stdinvalsii "INVALSI 6"
lab var stdinvalsii_2 "Sq. INVALSI 6"
lab var mom_working_class "Mum: working class"
lab var mom_high_class "Mum: whitecollar"
lab var mom_home "Mum: homemaker"
lab var mom_unemp "Mum: unemplyed"
lab var mom_miss "Mum: missing occupation"
lab var dad_working_class "Dad: working class"
lab var dad_high_class "Dad: whitecollar"
lab var dad_home "Dad: homemaker"
lab var dad_unemp "Dad: unemplyed"
lab var dad_miss "Dad: missing occupation"
lab var mom_educ_uni "Mum: University"
lab var mom_educ_hs "Mum: High-school"
lab var mom_educ_lhs "Mum: less than High-school"
lab var mom_educ_mis "Mum: missing education"
lab var dad_educ_uni "Dad: University"
lab var dad_educ_hs "Dad: High-school"
lab var dad_educ_lhs "Dad: less than High-school"
lab var dad_educ_mis "Dad: missing education"
lab var province_pd "Province: PD"
lab var province_bs "Province: BS"
lab var province_mi "Province: MI"
lab var province_to "Province: TO"
lab var province_ge "Province: GE"
lab var std_cit_latin "Latin America"
lab var std_cit_afric "Africa"
lab var std_cit_asia "Asia"
lab var std_cit_easteur "East Europe"
lab var late "Older age"
lab var perc_participation "Participation EOP"

*Replace NA with missing
foreach var in motivation barriers stdmatiii stditaiii {
replace `var'="." if `var'=="NA"
destring `var', replace
}
* Define the sample of high and low predicted treatment effects for high track choice
sort preds
gen order=_n
gen low_predicted_CATE_lictec=1 if order<609
replace low_predicted_CATE_lictec=0 if order>608 & preds!=.
drop order


*********************************************************************************
* Table C.1 
***************************************************************************************************

* 1) Balance Tables: two groups
rename preds preds_lictec2
gen stdinvalsiiii=(stditaiii+stdmatiii)/2

foreach var in  lictec2 {
gen ITT`var'_predicted=.
reg `var' treat $controls  if low_predicted_CATE_lictec==1
replace ITT`var'_predicted=_b[treat] if low_predicted_CATE_lictec==1

reg `var' treat $controls  if low_predicted_CATE_lictec==0
replace ITT`var'_predicted=_b[treat] if low_predicted_CATE_lictec==0
}

lab var ITTlictec2_predicted "ITT High Track"


foreach var in  perc_participation{
replace `var'="" if `var'=="NA"
destring `var', replace
}

balancetable low_predicted_CATE_lictec  ITTlictec2_predicted perc_participation $controls using $output/balancecausalforest.tex,   varlabels stddiff replace  booktabs  ctitles( "High Predicted TE" "Low Predicted TE" "Diff." "Norm. Diff.")


local output_mh "perc_participation female immigrato_prima_gen stdinvalsii stdinvalsii_2 late mom_working_class mom_high_class mom_home mom_unemp mom_miss dad_working_class dad_high_class dad_home dad_unemp dad_miss mom_educ_uni mom_educ_hs mom_educ_lhs mom_educ_mis dad_educ_uni dad_educ_hs dad_educ_lhs dad_educ_mis province_pd province_bs province_mi province_to province_ge std_cit_latin std_cit_afric std_cit_asia std_cit_easteur"

mhtexp `output_mh', treatment(low_predicted_CATE_lictec)  


*********************************************************************************
* Figure 6 
***************************************************************************************************

xtile deciles_invalsi=stdinvalsii, nq(10)
xtile quintile_perc_participation=perc_participation, nq(5)
lab var preds_lictec2 "Predictions High-Track"

label define gender_lbl 0 "Boys" 1 "Girls"
label values female gender_lbl

heatplot preds_lictec2 deciles_invalsi educmother, discrete(1) statistic(asis) by(female, note("")) cuts(0(0.02)0.1) ylabel(1(1)10) xlabel(1(1)4) aspectratio(1) xtitle("Education of Mother") ytitle("Deciles of Test Score 6") colors(magma, reverse gs) xlabel(1 "College" 2 "HS" 3 "<HS" 4 "Missing") legend(order(  6 ">0.08"  5 "[0.06;0.08]"  4 "[0.04;0.06]" 3 "[0.02;0.04]" 2 "[0.00;0.02]" 1 ""   ) subtitle("Predictions"))
graph export "$output/Figure_heatmap1.pdf", replace
graph export "$output_n/Figure_heatmap1_f.eps", replace

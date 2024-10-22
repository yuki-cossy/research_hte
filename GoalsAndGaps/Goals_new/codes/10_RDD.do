
**************************************************************************************************
*				Title: 10_RDD
*                       Output: 
*                                                         User: Michela Carlana
*                                                          Created: 5/01/2016
*                                                          Modified: 
*
*************************************************************************************************** 

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace


set scheme s1color
keep if invalsi_mean<=80 & invalsi_mean>=40
keep if treat==1

gen calp2=0
replace calp2=1 if invalsi_mean<=65.5 & invalsi_mean>=40


foreach var in participation_calpII	participation_calpIII	participation_orientII	participation_orientIII {
replace `var'=0 if `var'==.
replace `var'=. if lictec2==.
}
gen incontri=participation_calpII+participation_calpIII
gen incontri_orient= participation_orientII + participation_orientIII

*******************************************************************************
*Figure A.7 USE NEW COMMAND BY CATTANEO ET AL.
*******************************************************************************
*DCdensity invalsi_mean, breakpoint(65.5) generate(Xj Yj r0 fhat se_fhat)

rddensity invalsi_mean, c(65) plot_grid(es) plot_range(50 80)   nlocalmin(0) hist_range(50 80) hist_n(10) plot graph_opt(xtitle("INVALSI test score") ylabel(,nogrid) legend(off) xlabel(50(5)80) graphregion(color(white)) plotregion(color(white))) 
		
*******************************************************************************
* Figure 7
*******************************************************************************

lab var invalsi_mean "INVALSI 6"
lab var incontri ""
lab var lictec2 ""

* RDD: grafico
cmogram incontri invalsi_mean , cut(65.5) scatter line(65) qfitci title("No. of CALP meetings attended") 
graph copy one, replace
cmogram incontri_orient invalsi_mean , cut(65.5) scatter line(65) qfitci title("No. of career counseling meetings attended") 
graph copy two, replace
cmogram lictec2 invalsi_mean , cut(65.5) scatter line(65) qfitci title("Probability of choosing high-track") 
graph copy three, replace
cmogram fail invalsi_mean , cut(65.5) scatter line(65) qfitci title("Retained in grade 7 or 8") 
graph copy four, replace

graph combine one two three four, cols(2) scale(.7) ysize(5) xsize(5)
graph export "$output/figure_discontinuity_a.pdf", replace
graph save "$output/figure_discontinuity_a.gph", replace
graph export "$output_n/figure_discontinuity_a_f.eps", replace

******************************************************************************
* Table A.10
*******************************************************************************

lab var incontri "Meetings Tutoring"
lab var incontri_orient "Meetings Career Counseling"
lab var lictec2 "Choice of demanding track"
lab var fail "Grade Retention"
lab var motivation "Aspiration" 
lab var barriers "Barriers"
lab var invalsiIII "Test score grade 8"
lab var recc_lictec2 "Teachers' recommendation"

drop if lictec2==.
foreach var in incontri  {
rdrobust `var' invalsi_mean, c(65.5) p(2) h(30)
outreg2 using "$output/Table_RDD.xls", replace addstat(Conventional Std. Err., e(se_tau_cl), Conventional p-value, e(pv_cl), Robust p-value, e(pv_rb), Order Loc. Poly. (p), e(p), Order Bias (q), e(q), BW below cutoff , e(h_l), BW above cutoff , e(h_r)) 
* addtext(Robust`e(level) ́% CI, `e(ci rb) ́, Kernel Type, `e(kernel) ́, BW Type, `e(bwsel) ́, Observations, `e(N)) ́ 
}



foreach var in  incontri_orient lictec2 fail motivation barriers invalsiIII recc_lictec2 {
rdrobust `var' invalsi_mean, c(65.5) p(2) h(30)
outreg2 using "$output/Table_RDD.xls", append addstat(Conventional Std. Err., e(se_tau_cl), Conventional p-value, e(pv_cl), Robust p-value, e(pv_rb), Order Loc. Poly. (p), e(p), Order Bias (q), e(q), BW below cutoff , e(h_l), BW above cutoff , e(h_r)) 
*, addstat(Conventional Std. Err., e(se cl), Conventional p-value, e(pv cl), Robust p-value, e(pv rb), Order Loc. Poly. (p), e(p), Order Bias (q), e(q), BW Loc. Poly. (h), e(h bw), BW Bias (b), e(b bw)) addtext(Robust`e(level) ́% CI, `e(ci rb) ́, Kernel Type, `e(kernel) ́, BW Type, `e(bwsel) ́, Observations, `e(N)) ́ noobs nose noaster nonotes adec(3)
}



******************************************************************************
* Figure 4 
*******************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

preserve 
replace rank=int(rank)
gen one=1
keep if rank<=30
gen halfrank=rank/2
gen rank0=rank+0.5 if int(halfrank)!=halfrank
replace rank0=rank-0.5 if int(halfrank)==halfrank
gen lictec2_se=lictec2
collapse lictec2 (sum) one (sem) lictec2_se, by(rank0 treat_school female)
gen uplictec2=lictec2+1.65*lictec2_se
gen downlictec2=lictec2-1.65*lictec2_se
gen plotrank=rank0-0.2 if treat_school==1
replace plotrank=rank0+0.2 if treat_school==0

twoway (rcap uplictec2 downlictec2 plotrank if treat_school==1, color(black)) (scatter lictec2 plotrank if treat_school==1, mcolor(black)) ///
(lfit lictec2 rank0 [aw=one] if treat_school==1&rank<=10, lcolor(black)) (lfit lictec2 rank0 [aw=one] if treat_school==1&rank>=10, lcolor(black)) ///
(rcap uplictec2 downlictec2 plotrank if treat_school==0, color(gs10)) (scatter lictec2 plotrank if treat_school==0, mcolor(gs10)  msymbol(circle_hollow)) ///
(lfit lictec2 rank0 [aw=one] if treat_school==0&rank<=10, lpattern(dash) lcolor(gs10)) (lfit lictec2 rank0 [aw=one] if treat_school==0&rank>=10, lpattern(dash) lcolor(gs10))  if female==0, xlabel(1 5 10 15 20 25 30) xline(10.5, lcolor(black)) legend(order(2 "treated schools" 6 "control schools")) title("Males") graphregion(color(white))
graph copy males, replace

twoway (rcap uplictec2 downlictec2 plotrank if treat_school==1, color(black)) (scatter lictec2 plotrank if treat_school==1, mcolor(black)) ///
(lfit lictec2 rank0 [aw=one] if treat_school==1&rank<=10, lcolor(black)) (lfit lictec2 rank0 [aw=one] if treat_school==1&rank>=10, lcolor(black)) ///
(rcap uplictec2 downlictec2 plotrank if treat_school==0, color(gs10)) (scatter lictec2 plotrank if treat_school==0, mcolor(gs10) msymbol(circle_hollow)) ///
(lfit lictec2 rank0 [aw=one] if treat_school==0&rank<=10, lpattern(dash) lcolor(gs10)) (lfit lictec2 rank0 [aw=one] if treat_school==0&rank>=10, lpattern(dash) lcolor(gs10))  if female==1, xlabel(1 5 10 15 20 25 30) xline(10.5, lcolor(black)) legend(order(2 "treated schools" 6 "control schools")) title("Females") graphregion(color(white))
graph copy females, replace

graph combine males females, xsize(8) ysize(3) ycommon scale(1.3) graphregion(color(white))

graph export "$output_n/rdd_top10_f.eps", replace

restore

******************************************************************************
* Table A.4
*******************************************************************************
drop if invalsi_m==.
rename invalsi_mean invalsi
gen invalsi2=invalsi^2
*drop if invalsi_m==.
*encode MECCANO, g(schoolnum)
keep if missing(rank)==0
replace rank=int(rank)
gen rank2=rank^2
gen top10=rank<=10
gen top10xrank=top10*rank
gen top10xrank2=top10*rank2
gen treat_schoolxtop10=treat_school*top10
gen treat_schoolxrank=treat_school*rank
gen treat_schoolxrank2=treat_school*rank2
gen treat_schoolxrankxtop10=treat_school*rank*top10
gen treat_schoolxrank2xtop10=treat_school*rank2*top10


reg lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 if female==0&rank<=30, robust cluster(rank)
outreg2 using "$output/rdd_top10.xls", replace label dec(3) pdec(3) noast

areg lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 immigrato_prima_gen invalsi invalsi2 if female==0&rank<=30, abs(prov) robust cluster(rank)
outreg2 using "$output/rdd_top10.xls", append label dec(3) pdec(3) noast

reghdfe lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 immigrato_prima_gen invalsi invalsi2 if female==0&rank<=30, a(school_code)  cluster(school_code rank)
outreg2 using "$output/rdd_top10.xls", append label dec(3) pdec(3) noast

reg lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 if female==1&rank<=30, robust cluster(rank)
outreg2 using "$output/rdd_top10.xls", append label dec(3) pdec(3) noast

areg lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 immigrato_prima_gen invalsi invalsi2 if female==1&rank<=30, abs(prov)  robust cluster(rank)
outreg2 using "$output/rdd_top10.xls", append label dec(3) pdec(3) noast

reghdfe lictec2 treat_schoolxtop10 treat_school top10 rank top10xrank treat_schoolxrank treat_schoolxrankxtop10 immigrato_prima_gen invalsi invalsi2 if female==1&rank<=30, a(school_code)  cluster(school_code rank)
outreg2 using "$output/rdd_top10.xls", append label dec(3) pdec(3) noast


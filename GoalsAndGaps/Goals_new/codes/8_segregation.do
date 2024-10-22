*************************************************************************************************
*				Title: segregation
*                       Input: "$definitivo/all_students.dta"
*                   
*                                                         User: Michela Carlana
*                                                         Created: 5/1/16
*                                                         Modified: 
*************************************************************************************************
*************************************************************************************************
* Table A2
*************************************************************************************************
global control "immigrato_prima_gen stdinvalsiI stdinvalsiI_2 prov2 prov3 prov4 prov5"

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

keep if treat_school==0
drop if stdinvalsiI==.

foreach var in educmotherI educmotherII educmotherIII bluemother whitemother unempmother homemother  educfatherI educfatherII educfatherIII bluefather whitefather unempfather homefather{
gen `var'_3=`var' 
replace `var'_3=0 if `var'_3==.
}

gen educfather_missing=(educfatherI==.)
gen occmother_missing=(homemother==.)
gen occfather_missing=(homefather==.)
gen unemplyed_home_father_3=unempfather_3+homefather_3
gen unemplyed_home_mother_3=unempmother_3+homemother_3


foreach var in lictec2 {
reg `var' potential_program $control if female==0, robust cluster(school_code)
est store `var'_1
reg `var' potential_program educmotherI_3 educmotherII_3 educmother_missing educfatherI_3 educfatherII_3 educfather_missing $control if female==0, robust cluster(school_code)
est store `var'_2
reg `var' potential_program educmotherI_3 educmotherII_3 educmother_missing educfatherI_3 educfatherII_3 educfather_missing bluemother_3 unemplyed_home_mother_3 bluefather_3 unemplyed_home_father_3 occmother_missing occfather_missing $control if female==0, robust cluster(school_code)
est store `var'_3
reg `var' potential_program $control if female==1, robust cluster(school_code)
est store `var'_4
reg `var' potential_program educmotherI_3 educmotherII_3 educmother_missing educfatherI_3 educfatherII_3 educfather_missing $control if female==1, robust cluster(school_code)
est store `var'_5
reg `var' potential_program educmotherI_3 educmotherII_3 educmother_missing educfatherI_3 educfatherII_3 educfather_missing bluemother_3 unemplyed_home_mother_3 bluefather_3 unemplyed_home_father_3 occmother_missing occfather_missing $control if female==1, robust cluster(school_code)
est store `var'_6

}


*Table A.2
esttab  lictec2_1 lictec2_2 lictec2_3 lictec2_4 lictec2_5 lictec2_6  using "$output/TableA1.tex", /*
*/ label  title (Educational segregation of immigrant students \label{TableA1}) replace booktabs /*
*/ cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) /*
*/ nogaps legend stats(N r2, labels (`"Obs."' `"\(R^{2}\)"') fmt(0 3)) /*
*/ addnotes("Robust Standard Errors clustered at class level in parentheses. Observation only from control schools." "Controls include generation of immigration, province and squared test score.")

*************************************************************************************************
*************************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

global control "stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 " 

drop if female==.
drop if stdinvalsiI==.
count
gen invalsiI=(itano+matno)/2

*************************************************************************************************
* Figure 3 
*************************************************************************************************
set scheme  s2color 

preserve
twoway 	(kdensity invalsiI if potential_program==0, lcolor(black) lpattern(solid)) ///
		(kdensity invalsiI if potential_program==1, lcolor(black) lpattern(solid) lwidth(thick)) ///
		(kdensity invalsiI if program==1 & out==0, lcolor(black) lpattern(dash)), ///
		legend(order(1 "Natives" 2 " All immigrants" 3 "Treated and control students in our sample")) ///
        xtitle("") ytitle("") title("") scale(.7)  graphregion(color(white))
		
		
        *note("The mean of the test score is 58.6 for Italians, 46.5 for immigrants and 60.8 for students selected for the treatment.") 
		* title("Distribution test score grade 6")
graph save "$output/Figure3.gph",replace
graph export "$output/Figure3.pdf", replace
graph export "$output_n/distinvalsi6_f.eps", replace


restore


**********************************************************************
* Figure 1
**********************************************************************
keep if treat_school==0

set scheme s1mono
count 
 
xtile invalsi=stdinvalsiI, nq(5)

********************************* M *************************************
preserve
keep if female==0
gen obs=1
collapse (mean) lictec2 stdinvalsiI  (sd)sdlictec2=lictec2 (sum) obs, by(potential_program invalsi)
foreach var in lictec2 {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap uplictec2 downlictec2 invalsi if potential_program==0, lcolor(green)) (line lictec2 invalsi if potential_program==0, lcolor(green)) (scatter lictec2 invalsi if potential_program==0, mcolor(green)) ///
(rcap uplictec2 downlictec2 invalsi if potential_program==1, lcolor(red)) (line lictec2 invalsi if potential_program==1, lcolor(red)) (scatter lictec2 invalsi if potential_program==1, mcolor(red) msymbol(circle_hollow)), legend(order(3 "Natives" 6 "Immigrants"))  xlabel(1(1)5) title("Males")  xtitle("Test score, 6th grade, quintiles")
graph copy lictec2_m2, replace
restore

********************************* F *************************************
preserve
keep if female==1
gen obs=1
collapse (mean) lictec2 stdinvalsiI  (sd)sdlictec2=lictec2 (sum) obs, by(potential_program invalsi)
foreach var in lictec2 {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap uplictec2 downlictec2 invalsi if potential_program==0, lcolor(green)) (line lictec2 invalsi if potential_program==0, lcolor(green)) (scatter lictec2 invalsi if potential_program==0, mcolor(green)) ///
(rcap uplictec2 downlictec2 invalsi if potential_program==1, lcolor(red)) (line lictec2 invalsi if potential_program==1, lcolor(red)) (scatter lictec2 invalsi if potential_program==1, mcolor(red) msymbol(circle_hollow)), legend(order(3 "Natives" 6 "Immigrants"))  xlabel(1(1)5) title("Females")  xtitle("Test score, 6th grade, quintiles")
graph copy lictec2_f2, replace
restore

graph combine lictec2_m2 lictec2_f2, cols(2) scale(1.2) ysize(4) xsize(7) title("")
graph copy lictec2, replace
graph save "$output/Figure2.gph",replace
graph export "$output/Figure2.pdf", replace
graph export "$output_n/figure_educationalchoices_f.eps", replace


**********************************************************************
* Figure A.4
**********************************************************************


********************************* M *************************************
preserve
keep if female==0
gen obs=1
collapse (mean) recc_lictec2 stdinvalsiI  (sd)sdrecc_lictec2=recc_lictec2 (sum) obs, by(potential_program invalsi)
foreach var in recc_lictec2{
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap uprecc_lictec2 downrecc_lictec2 invalsi if potential_program==0, lcolor(green)) (line recc_lictec2 invalsi if potential_program==0, lcolor(green)) (scatter recc_lictec2 invalsi if potential_program==0, mcolor(green)) ///
(rcap uprecc_lictec2 downrecc_lictec2 invalsi if potential_program==1, lcolor(red)) (line recc_lictec2 invalsi if potential_program==1, lcolor(red)) (scatter recc_lictec2 invalsi if potential_program==1, mcolor(red) msymbol(circle_hollow)), yscale(range(0 1)) ylabel(0(0.2)1) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Males")  xtitle("Test score, 6th grade, quintiles")
graph copy recc_lictec2_m2, replace
restore

********************************* F *************************************
preserve
keep if female==1
gen obs=1
collapse (mean) recc_lictec2 stdinvalsiI  (sd)sdrecc_lictec2=recc_lictec2 (sum) obs, by(potential_program invalsi)
foreach var in recc_lictec2{
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap uprecc_lictec2 downrecc_lictec2 invalsi if potential_program==0, lcolor(green)) (line recc_lictec2 invalsi if potential_program==0, lcolor(green)) (scatter recc_lictec2 invalsi if potential_program==0, mcolor(green)) ///
(rcap uprecc_lictec2 downrecc_lictec2 invalsi if potential_program==1, lcolor(red)) (line recc_lictec2 invalsi if potential_program==1, lcolor(red)) (scatter recc_lictec2 invalsi if potential_program==1, mcolor(red) msymbol(circle_hollow)), yscale(range(0 1)) ylabel(0(0.2)1) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Females")  xtitle("Test score, 6th grade, quintiles")
graph copy recc_lictec2_f2, replace
restore

graph combine recc_lictec2_m2 recc_lictec2_f2, cols(2) scale(.7) ysize(4) xsize(7) title("Teachers' recommendation to Demanding High-School")
graph copy recc_lictec2, replace


**********************************************************************
gen fail_all=fail
*replace fail_all=1 if fail_1==1

foreach var2 in fail_all  {

********************************* M *************************************
preserve
keep if female==0
gen obs=1
collapse (mean) `var2' stdinvalsiI  (sd)sd`var2'=`var2' (sum) obs, by(potential_program invalsi)
foreach var in `var2' {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap up`var2' down`var2' invalsi if potential_program==0, lcolor(green)) (line `var2' invalsi if potential_program==0, lcolor(green)) (scatter `var2' invalsi if potential_program==0, mcolor(green)) ///
(rcap up`var2' down`var2' invalsi if potential_program==1, lcolor(red)) (line `var2' invalsi if potential_program==1, lcolor(red)) (scatter `var2' invalsi if potential_program==1, mcolor(red) ///
msymbol(circle_hollow)), yscale(range(0 0.3)) ylabel(0(0.1)0.3) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Males")  xtitle("Test score, 6th grade, quintiles")
graph copy `var2'_m2, replace
restore

********************************* F *************************************
preserve
keep if female==1
gen obs=1
collapse (mean) `var2' stdinvalsiI  (sd)sd`var2'=`var2' (sum) obs, by(potential_program invalsi)
foreach var in `var2' {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap up`var2' down`var2' invalsi if potential_program==0, lcolor(green)) (line `var2' invalsi if potential_program==0, lcolor(green)) (scatter `var2' invalsi if potential_program==0, mcolor(green)) ///
(rcap up`var2' down`var2' invalsi if potential_program==1, lcolor(red)) (line `var2' invalsi if potential_program==1, lcolor(red)) (scatter `var2' invalsi if potential_program==1, mcolor(red) ///
msymbol(circle_hollow)), yscale(range(0 0.3)) ylabel(0(0.1)0.3) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Females")  xtitle("Test score, 6th grade, quintiles")
graph copy `var2'_f2, replace
restore
}
***


foreach var2 in  invalsiIII {

********************************* M *************************************
preserve
keep if female==0
gen obs=1
collapse (mean) `var2' stdinvalsiI  (sd)sd`var2'=`var2' (sum) obs, by(potential_program invalsi)
foreach var in `var2' {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap up`var2' down`var2' invalsi if potential_program==0, lcolor(green)) (line `var2' invalsi if potential_program==0, lcolor(green)) (scatter `var2' invalsi if potential_program==0, mcolor(green)) ///
(rcap up`var2' down`var2' invalsi if potential_program==1, lcolor(red)) (line `var2' invalsi if potential_program==1, lcolor(red)) (scatter `var2' invalsi if potential_program==1, mcolor(red) ///
msymbol(circle_hollow)), yscale(range(40 80)) ylabel(40(10)80) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Males")  xtitle("Test score, 6th grade, quintiles")
graph copy `var2'_m2, replace
restore

********************************* F *************************************
preserve
keep if female==1
gen obs=1
collapse (mean) `var2' stdinvalsiI  (sd)sd`var2'=`var2' (sum) obs, by(potential_program invalsi)
foreach var in `var2' {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway (rcap up`var2' down`var2' invalsi if potential_program==0, lcolor(green)) (line `var2' invalsi if potential_program==0, lcolor(green)) (scatter `var2' invalsi if potential_program==0, mcolor(green)) ///
(rcap up`var2' down`var2' invalsi if potential_program==1, lcolor(red)) (line `var2' invalsi if potential_program==1, lcolor(red)) (scatter `var2' invalsi if potential_program==1, mcolor(red) ///
msymbol(circle_hollow)), yscale(range(40 80)) ylabel(40(10)80) legend(order(3 "Italians" 6 "Immigrants"))  xlabel(1(1)5) title("Females")  xtitle("Test score, 6th grade, quintiles")
graph copy `var2'_f2, replace
restore
}
***


graph combine fail_all_m2 fail_all_f2, cols(2) scale(.7) ysize(4) xsize(7) title("Retention rate in grade 7 or 8")
graph copy fail, replace

graph combine invalsiIII_m2 invalsiIII_f2, cols(2) scale(.7) ysize(4) xsize(7) title("INVALSI8")
graph copy invalsi, replace


graph combine fail recc_lictec2 invalsi, cols(1) scale(.7) ysize(4) xsize(3) title("")
graph save "$output/Figure_segregation_other.gph",replace
graph export "$output/Figure_segregation_other.pdf", replace

*****************************8
*Figure A.4
*************************************
graph export "$output_n/Figure_segregation_other_f.eps", replace


**********************************************************************
* Figure B1
**********************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace

keep if treat==1 
set scheme s1color

preserve
keep if female==0
hist perc_participation, frac bin(8) xlabel(0(0.25)1) lcolor(black) fcolor(ltblue) title("Males") xtitle("Percentage of meetings attended")ytitle("")
graph copy partec_m, replace

restore

preserve
keep if female==1
hist perc_participation,frac bin(8) xlabel(0(0.25)1)lcolor(black) fcolor(orange_red) title("Females") xtitle("Percentage of meetings attended") ytitle("")
graph copy partec_f, replace

restore

***********************************************
*Figure B1
**************************************************

graph combine partec_m partec_f, cols(2) scale(.7) ysize(4) xsize(7) title("Participation in the treatment")
graph save "$output/FigureB1.gph",replace
graph export "$output/FigureB1.pdf", replace
graph export "$output_n/compliance_f.eps", replace



use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

*keep if program==1 & lictec2!=.
count

set scheme s1color


drop if female==.
drop if stdinvalsiI==.
count

global control "stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 " 

**********************************************************************
* Figure A8
**********************************************************************
forvalues i=0(1)1{
preserve
keep if program==1 & out==0 & female==`i'

ksmirnov invalsiIII, by(treat) exact
*ksmirnov stditaIII, by(treat) exact
*ksmirnov stdmatIII, by(treat) exact
ksmirnov motivation, by(treat) exact
ksmirnov barriers, by(treat) exact
restore
}

forvalues i=1(1)1{
preserve
keep if  female==`i'

twoway (kdensity invalsiIII if treat==1 &program==1 & out==0 , lcolor(red) lwidth(thick) bwidth(4)) ///
		(kdensity invalsiIII if treat==0 &program==1 & out==0, lcolor(blue) bwidth(4)) ///
		(kdensity invalsiIII if comparable_italians==1,clpat(dash) lcolor(black) lpattern(dash) bwidth(4)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("INVALSI8, females") scale(.9) legend(rows(1))
graph copy invalsiIII_`i', replace

twoway (kdensity motivation if treat==1 &program==1 & out==0, lcolor(red) lwidth(thick) bwidth(0.25)) ///
		(kdensity motivation if treat==0 &program==1 & out==0, lcolor(blue) bwidth(0.25)) ///
		(kdensity motivation if comparable_italians==1,clpat(dash) lcolor(black) lpattern(dash) bwidth(0.25)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("Aspirations, females") scale(.9) legend(rows(1))
graph copy motivation_`i', replace

twoway (kdensity barriers if treat==1 &program==1 & out==0, lcolor(red) lwidth(thick) bwidth(0.25)) ///
		(kdensity barriers if treat==0 &program==1 & out==0, lcolor(blue) bwidth(0.25)) ///
		(kdensity barriers if comparable_italians==1,clpat(dash) lcolor(black) lpattern(dash) bwidth(0.25)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("Perception of barriers, females") scale(.9) legend(rows(1))
graph copy barriers_`i', replace
restore
}


forvalues i=0(1)0{
preserve
keep if  female==`i'

twoway (kdensity invalsiIII if treat==1 &program==1 & out==0 , lcolor(red) lwidth(thick) bwidth(4)) ///
		(kdensity invalsiIII if treat==0 &program==1 & out==0, lcolor(blue) bwidth(4)) ///
		(kdensity invalsiIII if comparable_italians==1,clpat(dash) lcolor(black)  lpattern(dash) bwidth(4)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("INVALSI8, males") scale(.9) legend(rows(1))
graph copy invalsiIII_`i', replace

twoway (kdensity motivation if treat==1 &program==1 & out==0, lcolor(red) lwidth(thick) bwidth(0.25)) ///
		(kdensity motivation if treat==0 &program==1 & out==0, lcolor(blue) bwidth(0.25)) ///
		(kdensity motivation if comparable_italians==1,clpat(dash) lcolor(black) lpattern(dash) bwidth(0.25)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("Aspirations, males") scale(.9) legend(rows(1))
graph copy motivation_`i', replace

twoway (kdensity barriers if treat==1 &program==1 & out==0, lcolor(red) lwidth(thick) bwidth(0.25)) ///
		(kdensity barriers if treat==0 &program==1 & out==0, lcolor(blue) bwidth(0.25)) ///
		(kdensity barriers if comparable_italians==1,clpat(dash) lcolor(black) lpattern(dash) bwidth(0.25)), ///
		legend(order(1 "Treat" 2 "Control" 3 "Italians"))  ///
        xtitle("") ytitle("") title("Perception of barriers, males") scale(.9) legend(rows(1))
graph copy barriers_`i', replace
restore
}



graph combine motivation_0 motivation_1 barriers_0 barriers_1 invalsiIII_0 invalsiIII_1, cols(2) scale(.7) ysize(4) xsize(4)
graph export "$output/figure_distributions.pdf", replace
graph export "$output_n/figure_distributions_f.eps", replace

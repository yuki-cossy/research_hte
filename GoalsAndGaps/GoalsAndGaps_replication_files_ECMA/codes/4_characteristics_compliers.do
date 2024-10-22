
************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace


xtile invalsi=stdinvalsiI, nq(3)
keep if female==0

reg bonus treat, robust cluster(school_code)
scalar coeff =_b[treat]

reg bonus treat if immigrato_prima_gen==1, robust cluster(school_code)
scalar coeff_first =_b[treat]

reg bonus treat if immigrato_prima_gen==0, robust cluster(school_code)
scalar coeff_second =_b[treat]

reg bonus treat if invalsi==1, robust cluster(school_code)
scalar coeff_invalsi1 =_b[treat]

reg bonus treat if invalsi==2, robust cluster(school_code)
scalar coeff_invalsi2 =_b[treat]

reg bonus treat if invalsi==3, robust cluster(school_code)
scalar coeff_invalsi3 =_b[treat]

reg bonus treat if educmother_high==1, robust cluster(school_code)
scalar coeff_highedumother =_b[treat]

reg bonus treat if educmother_high==0, robust cluster(school_code)
scalar coeff_lowedumother =_b[treat]

reg bonus treat if educmother_missing ==1, robust cluster(school_code)
scalar coeff_missedumother =_b[treat]

reg bonus treat if late==0, robust cluster(school_code)
scalar coeff_ok =_b[treat]

reg bonus treat if late==1, robust cluster(school_code)
scalar coeff_late =_b[treat]


foreach var in invalsi1 invalsi2 invalsi3 highedumother lowedumother missedumother first second ok late{
gen ratio_`var'= coeff_`var'/coeff
gen beta_`var'= coeff_`var'
}


gen order=_n

gen ratio=ratio_invalsi1 if order==3
replace ratio= ratio_invalsi2 if order==4
replace ratio= ratio_invalsi3 if order==5
replace ratio= ratio_first if order==6
replace ratio= ratio_second if order==7
replace ratio=ratio_highedumother if order==8
replace ratio= ratio_lowedumother if order==9
replace ratio= ratio_missedumother if order==10
replace ratio= ratio_ok if order==11
replace ratio= ratio_late if order==12

drop if _n>12
keep ratio* beta* order


*
keep order ratio


twoway 	(bar ratio order if order==3, color(orange) lcolor(black)) ///
		(bar ratio order if order==4, color(orange*0.7) lcolor(black)) ///
		(bar ratio order if order==5, color(orange*0.2) lcolor(black)), ///
        xlabel( 3 "Bottom" 4 "Middle" 5 "Top", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Tercile of INVALSI 6") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy i_m, replace

twoway 	(bar ratio order if order==6, color(red) lcolor(black)) ///
		(bar ratio order if order==7, color(red*0.4) lcolor(black)), ///
        xlabel( 6 "First" 7 "Second", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Generation of immigration") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy f, replace

twoway 	(bar ratio order if order==8, color(green) lcolor(black)) ///
		(bar ratio order if order==9, color(green*0.8) lcolor(black)) ///
		(bar ratio order if order==10, color(geen*0.4) lcolor(black)), ///
        xlabel( 8 "High" 9 "Low" 10 "Missing", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Education mother") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy h, replace

twoway 	(bar ratio order if order==11, color(blue*0.9) lcolor(black)) ///
		(bar ratio order if order==12, color(blue*0.3) lcolor(black)), ///
        xlabel( 11 "Not late" 12 "Late", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Age") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy l_m, replace

graph combine i_m f h l_m, cols(2)  ysize(7) xsize(8) title("Male")
graph copy male, replace
graph save "$output/Figure_compliers_m.gph",replace
graph export "$output/Figure_compliers_m.pdf",replace


************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace


xtile invalsi=stdinvalsiI, nq(3)
keep if female==1

reg bonus treat, robust cluster(school_code)
scalar coeff =_b[treat]

reg bonus treat if immigrato_prima_gen==1, robust cluster(school_code)
scalar coeff_first =_b[treat]

reg bonus treat if immigrato_prima_gen==0, robust cluster(school_code)
scalar coeff_second =_b[treat]

reg bonus treat if invalsi==1, robust cluster(school_code)
scalar coeff_invalsi1 =_b[treat]

reg bonus treat if invalsi==2, robust cluster(school_code)
scalar coeff_invalsi2 =_b[treat]

reg bonus treat if invalsi==3, robust cluster(school_code)
scalar coeff_invalsi3 =_b[treat]

reg bonus treat if educmother_high==1, robust cluster(school_code)
scalar coeff_highedumother =_b[treat]

reg bonus treat if educmother_high==0, robust cluster(school_code)
scalar coeff_lowedumother =_b[treat]

reg bonus treat if educmother_missing ==1, robust cluster(school_code)
scalar coeff_missedumother =_b[treat]

reg bonus treat if late==0, robust cluster(school_code)
scalar coeff_ok =_b[treat]

reg bonus treat if late==1, robust cluster(school_code)
scalar coeff_late =_b[treat]


foreach var in invalsi1 invalsi2 invalsi3 highedumother lowedumother missedumother first second ok late{
gen ratio_`var'= coeff_`var'/coeff
gen beta_`var'= coeff_`var'
}


gen order=_n

gen ratio=ratio_invalsi1 if order==3
replace ratio= ratio_invalsi2 if order==4
replace ratio= ratio_invalsi3 if order==5
replace ratio= ratio_first if order==6
replace ratio= ratio_second if order==7
replace ratio=ratio_highedumother if order==8
replace ratio= ratio_lowedumother if order==9
replace ratio= ratio_missedumother if order==10
replace ratio= ratio_ok if order==11
replace ratio= ratio_late if order==12

drop if _n>12
keep ratio* beta* order


*
keep order ratio


twoway 	(bar ratio order if order==3, color(orange) lcolor(black)) ///
		(bar ratio order if order==4, color(orange*0.7) lcolor(black)) ///
		(bar ratio order if order==5, color(orange*0.2) lcolor(black)), ///
        xlabel( 3 "Bottom" 4 "Middle" 5 "Top", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Tercile of INVALSI 6") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy i_f, replace

twoway 	(bar ratio order if order==6, color(red) lcolor(black)) ///
		(bar ratio order if order==7, color(red*0.4) lcolor(black)), ///
        xlabel( 6 "First" 7 "Second", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Generation of immigration") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy f, replace

twoway 	(bar ratio order if order==8, color(green) lcolor(black)) ///
		(bar ratio order if order==9, color(green*0.8) lcolor(black)) ///
		(bar ratio order if order==10, color(geen*0.4) lcolor(black)), ///
        xlabel( 8 "High" 9 "Low" 10 "Missing", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Education mother") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy h, replace

twoway 	(bar ratio order if order==11, color(blue*0.9) lcolor(black)) ///
		(bar ratio order if order==12, color(blue*0.3) lcolor(black)), ///
        xlabel( 11 "Not late" 12 "Late", noticks) ytitle("Relative likelihood")	 ///
        xtitle("") title("Age") legend(off) yscale(range(0.8 1.2)) ylabel(0.8(0.1)1.2)
graph copy l_f, replace

graph combine i_f f h l_f, cols(2)  ysize(7) xsize(8) title("Female")
graph copy fem, replace
graph save "$output/Figure_compliers_f.gph",replace
graph export "$output/Figure_compliers_f.pdf",replace

graph combine male fem , cols(1)  ysize(6) xsize(4)title("Compliers characteristics ratios" "(attending more than 75% of meeting)")
graph copy a2, replace
graph save "$output/Figure_compliers.gph",replace
graph export "$output/Figure_compliers.pdf",replace
graph export "$output_n/Figure_compliers_f.eps",replace


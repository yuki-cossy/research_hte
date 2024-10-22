*************************************************************************************************
*				Title: spillover_effects
*                       Input: "$definitivo/all_students.dta"
*                   
*                                                         User: Michela Carlana
*                                                         Created: 26/10/2014
*                                                         Modified: 15/01/2020
*************************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear
global school "class_size perc_imm school_size" 
*************************************************************************************************
* Table 7
*************************************************************************************************

keep if program_c==1 //We keep only classes with either one treated or one control student 
drop if program==1 // We drop students who where either treated or control

sum stdinvalsiIII if potential_program==0
sum stdinvalsiIII if potential_program==0 & female==0
sum stdinvalsiIII if potential_program==0 & female==1
sum stdinvalsiIII if potential_program==1
sum stdinvalsiIII if potential_program==1 & female==0
sum stdinvalsiIII if potential_program==1 & female==1

foreach output in  lictec2 fail stdinvalsiIII recc_lictec2 {
reg `output' treat_c $control $school if potential_program==1, robust cluster(school_code)
est store `output'_imm

reg `output' treat_c $control $school if potential_program==1  & female==0, robust cluster(school_code)
est store `output'_imm_m

reg `output' treat_c $control $school if potential_program==1  & female==1, robust cluster(school_code)
est store `output'_imm_f

reg `output' treat_c $control $school if potential_program==0, robust cluster(school_code)
est store `output'_ita

reg `output' treat_c $control $school if potential_program==0  & female==0, robust cluster(school_code)
est store `output'_ita_m

reg `output' treat_c $control $school if potential_program==0  & female==1, robust cluster(school_code)
est store `output'_ita_f

esttab `output'_ita `output'_ita_m `output'_ita_f `output'_imm `output'_imm_m `output'_imm_f using "$output/Table_spillover_`output'.tex", /*
*/ label title (Estimation \label{peer_`output'}) replace booktabs /*
*/ nonotes mgroups("Italian" "Immigrants" , pattern(1 0 0 1 0 0) prefix(\multicolumn{3}{c}{) suffix(}) span e(\cmidrule(lr){2-4}\cmidrule(lr){5-7})) /*
*/ mtitles("All" "Males" "Female" "All" "Males" "Female") /*
*/ indicate(Controls = $control $school) /*
*/ cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) /*
*/ nogaps legend stats(N r2, labels (`"Obs."' `"\(R^{2}\)"') fmt(0 3)) /*
*/ addnotes("Robust Standard Errors clustered at school level in parentheses." "Controls include generation of immigration, province and squared test score, class size, school size," "percentage of immigrants in the class.")

}

***************************************************************************************************
* FIGURE A.5
*************************************************************************************************** 

preserve
keep if stdmatIII!=. 
set scheme s1mono
count
gen obs=1
collapse (mean) stdmatIII (sd) sdstdmatIII=stdmatIII (sum) obs, by(choice_track)

foreach var in  stdmatIII {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))

*

twoway 	(bar `var' choice_track if choice_track==1, color(dknavy) lcolor(black)) ///
		(bar `var' choice_track  if choice_track==2, color(red*0.8) lcolor(black)) ///
		(bar `var' choice_track  if choice_track==3, color(red*0.4) lcolor(black)) ///
		(bar `var' choice_track  if choice_track==4, color(orange*0.8) lcolor(black)) ///
		(bar `var' choice_track  if choice_track==5, color(orange*0.4) lcolor(black)) ///
		(bar `var' choice_track  if choice_track==6, color(green*0.8) lcolor(black)) ///
      	(rcap up`var' down`var' choice_track), ///
        xlabel( 1 "Scientific&Classic" 2 "Academic Linguistic" 3 "Other Academic" 4 "Technical Economic" 5 "Technical Technological" 6 "Vocational", noticks angle(45)) ///
        xtitle("")  legend(off) 
		*yscale(range(50 80)) ylabel(50(10)80)

graph save "$output/Figure_choice_test.gph",replace
graph export "$output/Figure_choice_test.pdf", replace

graph export "$output_n/Figure_choice_test_f.eps", replace

}

restore


/***************************************************************************************************
* Answer referee
*************************************************************************************************** 
preserve
keep if treat_c==1
hist n_treat_c, discrete lcolor(black) color(orange*0.7)  xtitle("") title("Number of treated students") ytitle("") xsc(r(1 7)) ylabel(0(0.1)0.4)
graph export  "$output/num_treated.pdf", replace
restore

gen two_program_c=(n_program_c>1)
gen two_treat_c=two_program_c*treat_c
lab var treat_c "EOP Class"
lab var two_treat_c  "EOP Class*Two or More Program Students"
lab var two_program_c "Two or More Program Students"
keep if program_c==1 //We keep only classes with either one treated or one control student 
drop if program==1 // We drop students who where either treated or control

foreach output in  lictec2 fail stdinvalsiIII recc_lictec2 {
reg `output' treat_c two_treat_c  two_program_c  $control $school if potential_program==1, robust cluster(school_code)
est store `output'_imm

reg `output' treat_c two_treat_c  two_program_c  $control $school if potential_program==1  & female==0, robust cluster(school_code)
est store `output'_imm_m

reg `output' treat_c two_treat_c  two_program_c   $control $school if potential_program==1  & female==1, robust cluster(school_code)
est store `output'_imm_f

reg `output' treat_c two_treat_c  two_program_c   $control $school if potential_program==0, robust cluster(school_code)
est store `output'_ita

reg `output' treat_c two_treat_c  two_program_c   $control $school if potential_program==0  & female==0, robust cluster(school_code)
est store `output'_ita_m

reg `output' treat_c two_treat_c  two_program_c   $control $school if potential_program==0  & female==1, robust cluster(school_code)
est store `output'_ita_f

esttab `output'_ita `output'_ita_m `output'_ita_f `output'_imm `output'_imm_m `output'_imm_f using "$output/Table_spillover_`output'_numtreated.tex", /*
*/ label title (Estimation \label{peer_`output'}) replace booktabs /*
*/ nonotes mgroups("Italian" "Immigrants" , pattern(1 0 0 1 0 0) prefix(\multicolumn{3}{c}{) suffix(}) span e(\cmidrule(lr){2-4}\cmidrule(lr){5-7})) /*
*/ mtitles("All" "Males" "Female" "All" "Males" "Female") /*
*/ indicate(Controls = $control $school) /*
*/ cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) /*
*/ nogaps legend stats(N r2, labels (`"Obs."' `"\(R^{2}\)"') fmt(0 3)) /*
*/ addnotes("Robust Standard Errors clustered at school level in parentheses." "Controls include generation of immigration, province and squared test score, class size, school size," "percentage of immigrants in the class.")

}


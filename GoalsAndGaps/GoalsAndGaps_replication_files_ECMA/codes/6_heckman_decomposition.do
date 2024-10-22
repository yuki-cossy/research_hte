**************************************************************************************************
*				Title: channels
*                       Input: "$definitivo/students_treated_control.dta"
*                       Output: 
*                                                         User: Michela Carlana
*                                                         Created: 26/10/2014
*                                                         Modified: 29/06/2015
* Description:
* A) correlations
* B) CHANNELS - Mediaiton Analysis
* C1) VARIANCE DECOMPOSITION: stdmotivation stdbarriers stdinvalsiIII recc_lictec2
* C2) VARIANCE DECOMPOSITION: stdmotivation stdbarriers stdinvalsiIII
* C3) VARIANCE DECOMPOSITION: stdmotivation stdbarriers
*************************************************************************************************** 
clear all
drop _all

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace
keep if program==1 & lictec2!=.
count

drop stdinvalsiIII
egen stdinvalsiIII=std(invalsiIII)
keep if program==1 & out==0

*** Define global
global controliv "stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 " 

global mediators "stdmotivation stdbarriers stdinvalsiIII recc_lictec2" 
global mediators2 "stdmotivation stdbarriers itaIII matIII recc_lictec2" 
global mediators3 "stdmotivation stdbarriers stdinvalsiIII" 
global mediators4 "stdmotivation stdbarriers itaIII matIII" 
global mediators5 "stdmotivation stdbarriers"

global mediators_treat "stdmotivation_treat stdbarriers_treat stdinvalsiIII_treat recc_lictec2_treat" 
global mediators2_treat "stdmotivation_treat stdbarriers_treat itaIII_treat matIII_treat recc_lictec2_treat" 
global mediators3_treat "stdmotivation_treat stdbarriers_treat stdinvalsiIII_treat" 
global mediators4_treat "stdmotivation_treat stdbarriers_treat itaIII_treat matIII_treat" 
global mediators5_treat "stdmotivation_treat stdbarriers_treat"

global controls "stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov1 prov3 prov4 prov5" 
global controls_treat "stdinvalsiI_treat stdinvalsiI_2_treat immigrato_prima_gen_treat prov1_treat prov2_treat prov3_treat prov4_treat prov5_treat" 

** Treatment effect
reg lictec2 treat $controls if female==0, robust cluster(school_code)

*** Define sample for variance decomposition

gen valid=1 if lictec2!=.
foreach var in $mediators $controls {
replace valid=. if `var'==.
}

keep if female==0
keep if valid==1

*** Define interaction variables with treatment
foreach var in $mediators $controls itaIII matIII prov2{
gen `var'_treat = `var' * treat
}

*************************************************************************************************** 
* A) correlations
***************************************************************************************************
preserve
*polychoric stdmotivation stdbarriers stdinvalsiIII recc_lictec2, pw sig star(.05)
pwcorr stdmotivation stdbarriers stdinvalsiIII recc_lictec2, star(.05)
restore

reg lictec2 $mediators5 $controliv, robust cluster(school_code)
est store one
reg lictec2 $controliv $mediators3, robust cluster(school_code)
est store two
reg lictec2 $controliv $mediators, robust cluster(school_code)
est store three

esttab one two three using "$output/Table5.tex", /*
*/ label title (Estimation \label{Table6a}) replace booktabs /*
*/ indicate(Controls = prov* stdinvalsiI stdinvalsiI_2 immigrato_prima_gen) /*
*/ cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) /*
*/ nogaps legend stats(N r2, labels (`"Obs."' `"\(R^{2}\)"') fmt(0 3)) /*
*/ addnotes("Robust Standard Errors clustered at school level in parentheses." "Controls include generation of immigration, province and squared test score.")

*************************************************************************************************** 
* B) TEST OF THE ASSUMPTION: BETA0=BETA1, DELTA0=DELTA1
* TABLE A.XIII
***************************************************************************************************
reg lictec2 $mediators5 $mediators5_treat $controls $controls_treat, robust cluster(school_code)
foreach var in $mediators5_treat  $controls_treat {
test `var' = 0
}
test (stdmotivation_treat=0)(stdbarriers_treat=0)
test (stdinvalsiI_treat=0)(stdinvalsiI_2_treat=0)(immigrato_prima_gen_treat=0)(prov1_treat=0)(prov2_treat=0)(prov3_treat=0)(prov4_treat=0)(prov5_treat=0)


reg lictec2 $mediators3 $mediators3_treat $controls $controls_treat, robust cluster(school_code)

foreach var in $mediators3_treat  $controls_treat {
test `var' = 0
}

test (stdmotivation_treat=0)(stdbarriers_treat=0)(stdinvalsiIII_treat=0)
test (stdinvalsiI_treat=0)(stdinvalsiI_2_treat=0)(immigrato_prima_gen_treat=0)(prov1_treat=0)(prov2_treat=0)(prov3_treat=0)(prov4_treat=0)(prov5_treat=0)

reg lictec2 $mediators $mediators_treat $controls $controls_treat, robust cluster(school_code)

foreach var in $mediators_treat  $controls_treat {
test `var' = 0
}

test (stdmotivation_treat=0)(stdbarriers_treat=0)(stdinvalsiIII_treat=0)(recc_lictec2=0)
test (stdinvalsiI_treat=0)(stdinvalsiI_2_treat=0)(immigrato_prima_gen_treat=0)(prov1_treat=0)(prov2_treat=0)(prov3_treat=0)(prov4_treat=0)(prov5_treat=0)

*************************************************************************************************** 
* C1) VARIANCE DECOMPOSITION: stdmotivation stdbarriers stdinvalsiIII recc_lictec2
***************************************************************************************************

*** Difference in the mean of mediators

foreach var in $mediators {
	forval treat=0/1{
            quietly sum `var' if treat==`treat'
            scalar mean_`var'_`treat'=r(mean)
         }
         scalar mean_`var'=mean_`var'_1-mean_`var'_0
	}
      
*** Total unexplained effect
reg lictec2 $mediators if treat==0, robust cluster(school_code)
	scalar constante_0 = _b[_cons]
	scalar sdcons0 =_se[_cons]
	
reg lictec2 $mediators if treat==1, robust cluster(school_code)
	scalar constante_1 = _b[_cons]
	scalar sdcons1 =_se[_cons]

	scalar total_unexplained_effect= round(constante_1-constante_0,.0001)
	scalar sd_total_unexplained_effect=sqrt(sdcons0^2+sdcons1^2)
	scalar t_unexplained_effect =abs(total_unexplained_effect/sd_total_unexplained_effect)
	scalar p_value_unexplained= round(ttail(294, t_unexplained_effect),.0001)*2
	
** Explained effect
reg lictec2 $mediators $controls $mediators_treat $controls_treat, robust cluster(school_code)

	mat A = e(b)
	mat V_ols = e(V)
	scalar num_obs = e(N)
	
foreach var in  $mediators {
	scalar coeff_`var' =_b[`var']
	scalar effect_`var' =round(coeff_`var'*mean_`var',.0001)
	scalar sd`var' =_se[`var']
	scalar t_`var' =abs(coeff_`var'/sd`var')
	scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2
}
	
	scalar total_explained_effect= effect_stdmotivation+ effect_stdbarriers+ effect_stdinvalsiIII+ effect_recc_lictec2
	scalar se_total_explained_effect=((mean_stdmotivation)^2 *V_ols[1,1]+ (mean_stdbarriers)^2*V_ols[2,2]+(mean_stdinvalsiIII)^2*V_ols[3,3] +(mean_recc_lictec2)^2*V_ols[4,4])^(1/2)
	scalar t_explained =round(total_explained_effect/se_total_explained_effect,.0001)
	scalar p_value_explained= round(ttail(num_obs-1, t_explained),.0001)*2

	scalar list

matrix decomposition_males=[effect_stdmotivation,p_value_stdmotivation\effect_stdbarriers,p_value_stdbarriers\effect_stdinvalsiIII,p_value_stdinvalsiIII\effect_recc_lictec2,p_value_recc_lictec2\ total_explained_effect, p_value_explained\ total_unexplained_effect, p_value_unexplained]
matrix list decomposition_males
 
*** Define program for bootstraped standard errors
program regclus, rclass

reg lictec2 $mediators treat $controls $mediators_treat $controls_treat, robust cluster(school_code)
	foreach var in  $mediators {
		scalar coeff_`var' =_b[`var']
		}
		
bootstrap "regress lictec2 $mediators treat $controls $mediators_treat $controls_treat" "_b", reps(1000) cluster(school_code)

matrix A=e(se)
foreach var in  $mediators {
	scalar bs_sd`var' =_se[b_`var']
	scalar t_`var' =abs(coeff_`var'/bs_sd`var')
	return scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2

}

end
*** Simulation
preserve
simulate "regclus"  p_value_stdmotivation =r(p_value_stdmotivation) p_value_stdbarriers =r(p_value_stdbarriers)  p_value_stdinvalsiIII =r(p_value_stdinvalsiIII) p_value_recc_lictec2 =r(p_value_recc_lictec2), reps(1000)
summarize, separator(0)
save "$output/bootstrap_pvalue_C1", replace
restore

*************************************************************************************************** 
* C2) VARIANCE DECOMPOSITION: stdmotivation stdbarriers stdinvalsiIII 
***************************************************************************************************

*** Difference in the mean of mediators

foreach var in $mediators3 {
	forval treat=0/1{
            quietly sum `var' if treat==`treat'
            scalar mean_`var'_`treat'=r(mean)
         }
         scalar mean_`var'=mean_`var'_1-mean_`var'_0
	}
      
*** Total unexplained effect
reg lictec2 $mediators3 if treat==0, robust cluster(school_code)
	scalar constante_0 = _b[_cons]
	scalar sdcons0 =_se[_cons]
	
reg lictec2 $mediators3 if treat==1, robust cluster(school_code)
	scalar constante_1 = _b[_cons]
	scalar sdcons1 =_se[_cons]

	scalar total_unexplained_effect= round(constante_1-constante_0,.0001)
	scalar sd_total_unexplained_effect=sqrt(sdcons0^2+sdcons1^2)
	scalar t_unexplained_effect =abs(total_unexplained_effect/sd_total_unexplained_effect)
	scalar p_value_unexplained= round(ttail(294, t_unexplained_effect),.0001)*2
	
** Explained effect

reg lictec2 $mediators3 treat $controls $mediators3_treat $controls_treat, robust cluster(school_code)

	mat A = e(b)
	mat V_ols = e(V)
	scalar num_obs = e(N)
	
foreach var in  $mediators3 {
	scalar coeff_`var' =_b[`var']
	scalar effect_`var' =round(coeff_`var'*mean_`var',.0001)
	scalar sd`var' =_se[`var']
	scalar t_`var' =abs(coeff_`var'/sd`var')
	scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2
}
	
	scalar total_explained_effect= effect_stdmotivation+ effect_stdbarriers+ effect_stdinvalsiIII
	scalar se_total_explained_effect=((mean_stdmotivation)^2 *V_ols[1,1]+ (mean_stdbarriers)^2*V_ols[2,2]+(mean_stdinvalsiIII)^2*V_ols[3,3])^(1/2)
	scalar t_explained =round(total_explained_effect/se_total_explained_effect,.0001)
	scalar p_value_explained= round(ttail(num_obs-1, t_explained),.0001)*2

	scalar list

matrix decomposition_males3=[effect_stdmotivation,p_value_stdmotivation\effect_stdbarriers,p_value_stdbarriers\effect_stdinvalsiIII,p_value_stdinvalsiIII\ total_explained_effect, p_value_explained\ total_unexplained_effect, p_value_unexplained]
matrix list decomposition_males3

*** Define program for bootstraped standard errors
program regclus2, rclass

reg lictec2 $mediators3 treat $controls $mediators3_treat $controls_treat, robust cluster(school_code)
	foreach var in  $mediators3 {
		scalar coeff_`var' =_b[`var']
		}
		
bootstrap "regress lictec2 $mediators3 treat $controls $mediators3_treat $controls_treat" "_b", reps(1000) cluster(school_code)

matrix A=e(se)
foreach var in  $mediators3 {
	scalar bs_sd`var' =_se[b_`var']
	scalar t_`var' =abs(coeff_`var'/bs_sd`var')
	return scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2

}

end
 

*** Simulation
preserve
simulate "regclus2"  p_value_stdmotivation =r(p_value_stdmotivation) p_value_stdbarriers =r(p_value_stdbarriers)  p_value_stdinvalsiIII =r(p_value_stdinvalsiIII), reps(1000)
summarize, separator(0)
save "$output/bootstrap_pvalue_C3", replace
restore
*************************************************************************************************** 
* C3) VARIANCE DECOMPOSITION: stdmotivation stdbarriers 
***************************************************************************************************

*** Difference in the mean of mediators

foreach var in $mediators5 {
	forval treat=0/1{
            quietly sum `var' if treat==`treat'
            scalar mean_`var'_`treat'=r(mean)
         }
         scalar mean_`var'=mean_`var'_1-mean_`var'_0
	}
      
*** Total unexplained effect
reg lictec2 $mediators5 if treat==0, robust cluster(school_code)
	scalar constante_0 = _b[_cons]
	scalar sdcons0 =_se[_cons]
	
reg lictec2 $mediators5 if treat==1, robust cluster(school_code)
	scalar constante_1 = _b[_cons]
	scalar sdcons1 =_se[_cons]

	scalar total_unexplained_effect= round(constante_1-constante_0,.0001)
	scalar sd_total_unexplained_effect=sqrt(sdcons0^2+sdcons1^2)
	scalar t_unexplained_effect =abs(total_unexplained_effect/sd_total_unexplained_effect)
	scalar p_value_unexplained= round(ttail(294, t_unexplained_effect),.0001)*2
	
** Explained effect

reg lictec2 $mediators5 treat $controls $mediators5_treat $controls_treat, robust cluster(school_code)

	mat A = e(b)
	mat V_ols = e(V)
	scalar num_obs = e(N)
	
foreach var in  $mediators5 {
	scalar coeff_`var' =_b[`var']
	scalar effect_`var' =round(coeff_`var'*mean_`var',.0001)
	scalar sd`var' =_se[`var']
	scalar t_`var' =abs(coeff_`var'/sd`var')
	scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2
}
	
	scalar total_explained_effect= effect_stdmotivation+ effect_stdbarriers
	scalar se_total_explained_effect=((mean_stdmotivation)^2 *V_ols[1,1]+ (mean_stdbarriers)^2*V_ols[2,2])^(1/2)
	scalar t_explained =total_explained_effect/se_total_explained_effect
	scalar p_value_explained= round(ttail(num_obs-1, t_explained),.0001)*2

	scalar list

matrix decomposition_males5=[effect_stdmotivation,p_value_stdmotivation\effect_stdbarriers,p_value_stdbarriers\ total_explained_effect, p_value_explained\ total_unexplained_effect, p_value_unexplained]

*** Define program for bootstraped standard errors
program regclus3, rclass

reg lictec2 $mediators5 treat $controls $mediators5_treat $controls_treat, robust cluster(school_code)
	foreach var in  $mediators5 {
		scalar coeff_`var' =_b[`var']
		}
		
bootstrap "regress lictec2 $mediators3 treat $controls $mediators3_treat $controls_treat" "_b", reps(1000) cluster(school_code)

matrix A=e(se)
foreach var in  $mediators5 {
	scalar bs_sd`var' =_se[b_`var']
	scalar t_`var' =abs(coeff_`var'/bs_sd`var')
	return scalar p_value_`var'= round(ttail(num_obs-1, t_`var'),.0001)*2

}

end
 

*** Simulation
preserve
simulate "regclus3"  p_value_stdmotivation =r(p_value_stdmotivation) p_value_stdbarriers =r(p_value_stdbarriers), reps(1000)
summarize, separator(0)
save "$output/bootstrap_pvalue_C5", replace
restore


matrix list decomposition_males5
matrix list decomposition_males3
matrix list decomposition_males


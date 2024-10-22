**************************************************************************************************
*				Title: itt
*                       Input: "$definitivo/students_treated_control.dta"
*                       Output: 
*                                                         User: Michela Carlana
*                                                         Created: 1/12/2015
*                                                         Modified: 
* Description:
* Multiple hypotesis test using program by Tommaso Coen
*************************************************************************************************** 

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

keep if out==0
rename f1_obiettivi_studio f1
rename l2_lavoro_intellettuale l2_int
rename f2_universita f2_uni
rename f4_disponibilita_economiche f4_eco
rename f4_idee_della_famiglia f4_fam
rename f4_pregiudizi_non_italiano f4_preg
rename f4_progetti_familiari f4_good
rename f4_non_sentirsi_all_altezza f4_prog

foreach var in f1 f2_uni l2_int l2_dirigente f4_eco f4_fam f4_preg f4_prog f4_good  {
replace `var'=. if `var'==9
}
sum f1 f2_uni l2_int l2_dirigente f4_eco f4_fam f4_preg f4_prog f4_good 


rename treat treatment

keep female school_code treatment stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 f1 f2_uni l2_int l2_dirigente f4_eco f4_fam f4_preg f4_prog f4_good 
gen round=1
gen nstudent=_n

	xtset nstudent round

save "$trash/multiple_hypotesis_test.dta",replace
*************************************************************************************************** 

run "$codes/_programs_multiple_testing.do"
*************************************************************************************************** 

*************************************************************************************************** 
* Analysis
#delimit ;

global groups
	A
	B;

global dep_vars_A

f1 
f2_uni 
l2_int 
l2_dirigente ;

global dep_vars_B
f4_eco 
f4_fam 
f4_preg
f4_prog 
f4_good;

global controls
	stdinvalsiI stdinvalsiI_2
	immigrato_prima_gen 
	female
	prov2 prov3 prov4 prov5 ;

global num_rep = 1000;

#delimit cr


foreach group of global groups {

	use "$trash/multiple_hypotesis_test.dta", clear
	
	fwer , dep_vars(${dep_vars_`group'})	///
			controls(${controls}) ///
			cluster(school_code) ///
			fisher	///
			num_rep($num_rep)

	save "$output/TableA11_pvals_FWER_`group'", replace

}

erase "$trash/multiple_hypotesis_test.dta"

use "$output/TableA11_pvals_FWER_A",clear
append using "$output/TableA11_pvals_FWER_B"
save "$output/TableA11", replace

erase "$output/TableA11_pvals_FWER_A.dta"
erase "$output/TableA11_pvals_FWER_B.dta"

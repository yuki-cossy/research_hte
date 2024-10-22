**************************************************************************************************
*				Title: 1_program_evaluation
*                       Output: 
*                                                         User: Michela Carlana
*                                                          Created: 5/01/2016
*                                                          Modified: 
*
*************************************************************************************************** 

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace
keep if program==1 & lictec2!=.
count

*********************************************************************************
* Globals
***************************************************************************************************
global control "immigrato_prima_gen stdinvalsiI stdinvalsiI_2 prov2 prov3 prov4 prov5"
global inter3 "treat treat_f female stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 " 

*********************************************************************************
* Table 1 and A7
***************************************************************************************************
gen edu_father_missing=(educfatherII==.)
gen occ_father_missing=(bluefather==.)
gen occ_mother_missing=(bluemother==.)

foreach var in educmotherI educmotherII educmotherIII educfatherI educfatherII educfatherIII bluefather homefather unempfather whitefather whitemother unempmother homemother bluemother{
replace `var'=0 if `var'==.
}

sum female invalsi_mean  immigrato_prima_gen late prov1 prov2 prov3 prov4 prov5 educmotherI educmotherII educmotherIII educmother_missing bluemother whitemother unempmother homemother occ_mother_missing educfatherI educfatherII educfatherIII edu_father_missing bluefather whitefather unempfather homefather occ_father_missing Romania  Albania Marocco Filippine Peru Cina Ecuador

reg female treat, robust cluster(school_code)
outreg2 using "$output/Table1_orig.xls", replace ctitle(female) label keep(treat) addtext(Controls, No) dec(3) pdec(3)

foreach var in  invalsi_mean  immigrato_prima_gen late prov1 prov2 prov3 prov4 prov5 educmotherI educmotherII educmotherIII educmother_missing bluemother whitemother unempmother homemother occ_mother_missing educfatherI educfatherII educfatherIII edu_father_missing bluefather whitefather unempfather homefather occ_father_missing Romania  Albania Marocco Filippine Peru Cina Ecuador{
reg `var' treat, robust cluster(school_code)
outreg2 using "$output/Table1_orig.xls", append ctitle(`var') label keep(treat) addtext(Controls, No) dec(3) pdec(3)
}

*********************************************************************************
* Table 2 and 3
***************************************************************************************************
foreach var in lictec2 fail{
reg `var' treat , robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", replace ctitle(All) label keep(treat) addtext(Controls, No) dec(3) pdec(3)
reg `var' treat $control, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(All) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg `var' treat if female==0, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Male) label keep(treat) addtext(Controls, No) dec(3) pdec(3)
reg `var' treat $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Male) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg `var' treat if female==1, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Female) label keep(treat) addtext(Controls, No) dec(3) pdec(3)
reg `var' treat $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Female) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg `var' treat female treat_f, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Female) label keep(treat treat_f) addtext(Controls, No) dec(3) pdec(3)
reg `var' treat female treat_f $control, robust cluster(school_code)
outreg2 using "$output/Table_`var'.xls", append ctitle(Female) label keep(treat treat_f) addtext(Controls, Yes) dec(3) pdec(3)
}

*********************************************************************************
* Table B1
***************************************************************************************************
*Panel A

ivreg lictec2 (meeting =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", replace ctitle(All) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (meeting =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", append ctitle(Males) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (meeting =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", append ctitle(Female) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (meeting =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", append ctitle(All) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (meeting =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", append ctitle(Males) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (meeting =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_A.xls", append ctitle(Female) label keep(meeting) addtext(Controls, Yes) dec(3) pdec(3)

*Panel B

ivreg lictec2 (bonus75 =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", replace ctitle(All) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (bonus75 =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", append ctitle(Males) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (bonus75 =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", append ctitle(Female) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (bonus75 =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", append ctitle(All) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (bonus75 =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", append ctitle(Males) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (bonus75 =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_B.xls", append ctitle(Female) label keep(bonus75) addtext(Controls, Yes) dec(3) pdec(3)


*Panel C

ivreg lictec2 (perc_participation =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", replace ctitle(All) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (perc_participation =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", append ctitle(Males) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)
ivreg lictec2 (perc_participation =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", append ctitle(Female) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (perc_participation =treat) $control, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", append ctitle(All) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (perc_participation =treat) $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", append ctitle(Males) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)
ivreg fail (perc_participation =treat) $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table_late_C.xls", append ctitle(Female) label keep(perc_participation) addtext(Controls, Yes) dec(3) pdec(3)

*********************************************************************************
* Table 4
***************************************************************************************************

reg stdmotivation treat $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table5a.xls", replace ctitle(Aspirations) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg stdmotivation treat $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table5a.xls", append ctitle(Aspirations) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)
reg stdbarriers treat $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table5a.xls", append ctitle(Barriers) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)
reg stdbarriers treat $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table5a.xls", append ctitle(Barriers) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)

reg stdinvalsiIII treat $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table5b.xls", replace ctitle(Std Test grade6) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)
reg stdinvalsiIII treat $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table5b.xls", append ctitle(Std Test grade6) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)
reg recc_lictec2 treat $control if female==0, robust cluster(school_code)
outreg2 using "$output/Table5b.xls", append ctitle(Teachers' Recc.) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)
reg recc_lictec2 treat $control if female==1, robust cluster(school_code)
outreg2 using "$output/Table5b.xls", append ctitle(Teachers' Recc.) label keep(treat ) addtext(Controls, Yes) dec(3) pdec(3)


*********************************************************************************
* Table 6
***************************************************************************************************

reg pass_14_15 treat $control, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", replace ctitle(Direct admission) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg pass_14_15 treat $inter3, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle(Direct admission) label keep(treat treat_f) addtext(Controls, Yes) dec(3) pdec(3)
reg retake1415 treat $control, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle(Std Retakes) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg retake1415 treat $inter3, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle(Std Retakes) label keep(treat treat_f) addtext(Controls, Yes) dec(3) pdec(3)

reg dropout treat $control, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle(Dropout) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg dropout treat $inter3, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle() label keep(treat treat_f) addtext(Controls, Yes) dec(3) pdec(3)
reg change_school treat $control, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle(Change school) label keep(treat) addtext(Controls, Yes) dec(3) pdec(3)
reg change_school treat $inter3, robust cluster(school_code)
outreg2 using "$output/Table_longterm_A.xls", append ctitle() label keep(treat treat_f) addtext(Controls, Yes) dec(3) pdec(3)

*********************************************************************************
* Table A4
***************************************************************************************************


reg lictec2 quest_control_school if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", replace ctitle(Demanding High-School) label keep(quest_control_school) dec(3) pdec(3)
reg lictec2 quest_control_school quest_control_school_fem female if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", append label keep(quest_control_school quest_control_school_fem female) dec(3) pdec(3)

reg fail quest_control_school if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", append ctitle(Grade Retention) label keep(quest_control_school) dec(3) pdec(3)
reg fail quest_control_school quest_control_school_fem female if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", append  label keep(quest_control_school quest_control_school_fem female) dec(3) pdec(3)

reg stdinvalsiIII quest_control_school if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", append ctitle(Std Test Score grade 8) label keep(quest_control_school) dec(3) pdec(3)
reg stdinvalsiIII quest_control_school quest_control_school_fem female if treat_school==0, robust cluster(school_code)
outreg2 using "$output/Robustness_quest_control_school.xls", append  label keep(quest_control_school quest_control_school_fem female) dec(3) pdec(3)

*********************************************************************************
* Table A.VII (ordered probit)
***************************************************************************************************
tab choice_track3 if treat==0
bys female: tab choice_track3 if treat==0
** Mprobit 

oprobit choice_track3 treat , vce(cluster school_code) 
est sto a

forval i = 1/3 {
est res a
margins, dydx(treat) pr(out(`i')) post
est sto a`i'
}

** Mprobit 
oprobit choice_track3 treat $control ,  vce(cluster school_code) 
est sto a

forval i = 1/3 {
est res a
margins, dydx(treat) pr(out(`i')) post
est sto ac`i'
}


** Mprobit MALES
oprobit choice_track3 treat if female==0, vce(cluster school_code) 
est sto m

forval i = 1/3 {
est res m
margins, dydx(treat) pr(out(`i')) post
est sto m`i'
}

** Mprobit MALES
oprobit choice_track3 treat $control if female==0,  vce(cluster school_code) 
est sto m

forval i = 1/3 {
est res m
margins, dydx(treat) pr(out(`i')) post
est sto mc`i'
}

** Mprobit FEMALES
oprobit choice_track3 treat if female==1, vce(cluster school_code) 
est sto m

forval i = 1/3 {
est res m
margins, dydx(treat) pr(out(`i')) post
est sto f`i'
}

** Mprobit FEMALES
oprobit choice_track3 treat $control if female==1,  vce(cluster school_code) 
est sto m

forval i = 1/3 {
est res m
margins, dydx(treat) pr(out(`i')) post
est sto fc`i'
}

esttab a1 ac1 m1 mc1 f1 fc1 using $output/Table_probit_1.tex, replace cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01)
esttab a2 ac2  m2 mc2 f2 fc2 using $output/Table_probit_2.tex, replace cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01)
esttab a3 ac3 m3 mc3 f3 fc3 using $output/Table_probit_3.tex, replace cells(b(star label(Coef.) fmt(3)) se(label(SE) par fmt(3))) star(* 0.10 ** 0.05 *** 0.01)




*********************************************************************************
* Table A.5 
***************************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace

*global measures2 f1 f2_uni l2_int l2_dirigente f4_eco f4_fam f4_preg f4_prog f4_good
global measures2a f1 f2_uni l2_int l2_dirigente 
global measures2b f4_eco f4_fam f4_preg f4_prog f4_good 

*********************************************************************************
* Rename some variables

rename f1_obiettivi_studio f1
*rename l2_lavoro_int l2_int
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

*********************************************************************************
* EFA
*********************************************************************************


*Exploratory
global measures $measures2a $measures2b 
factor $measures, ml factor(7)
rotate, oblique quartimin normalize

*********************************************************************************
* CONFA
*********************************************************************************

confa (confa_aspiration: $measures2a) (confa_barriers: $measures2b) , from(iv) vce(sat) nolog

***************************************************************************************************
* Answer referee
*************************************************************************************************** 
use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace
keep if program==1 & lictec2!=.
gen school=school_code
replace school=. if treat==0
egen school2=group(school)
tab school2
replace school2=0 if school2==.
count

reg lictec2 treat i.school2 $control female, robust cluster(school_code)

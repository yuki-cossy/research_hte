**************************************************************************************************
*				Title: 
*                       Input: "$definitivo/students_treated_control.dta"
*                       Output: 
*                                                         User: Michela Carlana
*                                                         Created: 1/12/2015
*                                                         Modified: 
* Description:
* Multiple hypotesis test using program by Tommaso Coen
*************************************************************************************************** 

clear 
set more off

*************************************************************************************************** 
run "$codes/_Gelbach_decomposition.do"
*************************************************************************************************** 

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace


*use "$definitivo/all_students.dta",clear
*egen stdinvalsiIII=std(invalsiIII)
keep if program==1
keep if female==0 & out==0
keep if invalsiIII!=. & recc_lictec2!=.

*b1x2 lictec2, x1all(treat) x2all(stdmotivation stdbarriers) x1only(treat) x2delta(stdmotivation=stdmotivation: stdbarriers= stdbarriers)
b1x2 lictec2, x1all(treat stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5) x2all(stdmotivation stdbarriers) x1only(treat) x2delta(stdmotivation=stdmotivation: stdbarriers= stdbarriers)

*b1x2 lictec2, x1all(treat) x2all(stdmotivation stdbarriers stdinvalsiIII) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: invalsi= stdinvalsiIII)
b1x2 lictec2, x1all(treat stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5) x2all(stdmotivation stdbarriers stdinvalsiIII) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: invalsi= stdinvalsiIII)

*b1x2 lictec2, x1all(treat) x2all(stdmotivation stdbarriers stdinvalsiIII recc_lictec2) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: invalsi= stdinvalsiIII: consiglio= recc_lictec2)
b1x2 lictec2, x1all(treat stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5) x2all(stdmotivation stdbarriers stdinvalsiIII recc_lictec2) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: invalsi= stdinvalsiIII: consiglio= recc_lictec2)

*b1x2 lictec2, x1all(treat) x2all(stdmotivation stdbarriers stditaIII stdmatIII) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: ita= stditaIII: mat= stdmatIII)
*b1x2 lictec2, x1all(treat stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5) x2all(stdmotivation stdbarriers stditaIII stdmatIII) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: ita= stditaIII: mat= stdmatIII)

*b1x2 lictec2, x1all(treat) x2all(stdmotivation stdbarriers stditaIII stdmatIII recc_lictec2) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: ita= stditaIII: mat= stdmatIII: consiglio= recc_lictec2)
*b1x2 lictec2, x1all(treat stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5) x2all(stdmotivation stdbarriers stditaIII stdmatIII recc_lictec2) x1only(treat) x2delta(motivation=stdmotivation: barriers= stdbarriers: ita= stditaIII: mat= stdmatIII: consiglio= recc_lictec2)


exit

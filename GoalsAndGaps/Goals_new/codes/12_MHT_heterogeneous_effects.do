**************************************************************************************************
*				Title: summary_statistics
*                       Input:  "$definitivo/students_treated_control.dta"
*                       Output: 
*                                                         User: Michela Carlana
*                                                          Created: 5/01/2016
*                                                          Modified: 
*
*************************************************************************************************** 

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace
keep if program==1 & lictec2!=.
count
***************************************************************************************************

foreach var in stdinvalsiI stdinvalsiI_2 immigrato_prima_gen prov2 prov3 prov4 prov5 {
gen `var'_f=female*`var'
}

foreach var in stdinvalsiI stdinvalsiI_2 {
gen `var'_treat=treat*`var'
}
***************************************************************************************************
*MHT: gender lictec2
local output_mh "lictec2" 
local subgroups_mh "female"

egen group_id =group(`subgroups_mh')
mhtexp `output_mh', treatment(treat) subgroup(group_id) 
drop group_id

***************************************************************************************************
*MHT: gender all channels
*gen stdinvalsiIII=(stdmatIII+stditaIII)/2

local output_mh "stdinvalsiIII recc_lictec2 stdmotivation stdbarriers" 
local subgroups_mh "female"

egen group_id =group(`subgroups_mh')
mhtexp `output_mh', treatment(treat) subgroup(group_id) 
tab group_id female
drop group_id
***************************************************************************************************


***************************************************************************************************
* Table A.9
***************************************************************************************************

***************************************************************************************************
* Panel A
***************************************************************************************************
*MHT: GENDER EDUCATION
sum educmother_high_2 educmother_missing female

local output_mh "lictec2" 
local subgroups_mh "educmother_high_2 educmother_missing female"

egen group_id =group(`subgroups_mh')
mhtexp `output_mh', treatment(treat) subgroup(group_id) 
bys group_id: sum educmother_high_2 educmother_missing female
drop group_id
ss

***************************************************************************************************
* Panel B
***************************************************************************************************
*MHT: GENDER INVALSI
xtile invalsi=invalsi_mean, nq(3)
gen top_invalsi=(invalsi==3)
gen bottom_invalsi=(invalsi==1)
local output_mh "lictec2" 
local subgroups_mh "bottom_invalsi top_invalsi female"

egen group_id =group(`subgroups_mh')
mhtexp `output_mh', treatment(treat) subgroup(group_id) 
bys group_id: sum bottom_invalsi top_invalsi female
drop group_id


***************************************************************************************************
* Panel C
***************************************************************************************************

*MHT: GENDER EU
local output_mh "lictec2" 
local subgroups_mh "eu_member female"

egen group_id =group(`subgroups_mh')
mhtexp `output_mh', treatment(treat) subgroup(group_id) 
bys group_id: sum eu_member female
drop group_id

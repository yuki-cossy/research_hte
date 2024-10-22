**************************************************************************************************
*				Title: 12_descript_background_istatsurvey
*                       Output: 
*                                                         User: Michela Carlana
*                                                          Created: 5/01/2016
*                                                          Modified: 
*
*************************************************************************************************** 

*************************************************************************************************** 
* TABLE A.1
*************************************************************************************************** 

use "$definitivo/istat_survey_13_short.dta", replace

drop if v0_3_mfr==.

gen female=v0_5==2

gen track2=1 if v0_3_mfr>=1&v0_3_mfr<=5
mvencode track2, mv(2)


gen neet=(v4_1==7&v4_2!=1)

gen regret=v1_10==2

gen loweducfather=(v6_5==1|v6_5==2)
gen loweducmother=(v6_10==1|v6_10==2)

gen university=v3_3==1 // ever enrolled
gen univdropout=0 if v3_3==1
replace univdropout=1 if v3_3==1&v3_7==2&v3_8==2 // dropout rate if enrolled


tab track2 [aw=coeff] if cittad==1
tabstat university univdropout neet regret [aw=coeff] if cittad==1, by(track2) stats(mean sem)
tab track2 [aw=coeff] if cittad==1&female==0
tabstat university univdropout neet regret [aw=coeff] if cittad==1&female==0, by(track2) stats(mean sem)
tab track2 [aw=coeff] if cittad==1&female==1
tabstat university univdropout neet regret [aw=coeff] if cittad==1&female==1, by(track2) stats(mean sem)


tab track2 [aw=coeff] if cittad==2
tabstat university univdropout neet regret [aw=coeff] if cittad==2, by(track2) stats(mean sem)
tab track2 [aw=coeff] if cittad==2&female==0
tabstat university univdropout neet regret [aw=coeff] if cittad==2&female==0, by(track2) stats(mean sem)
tab track2 [aw=coeff] if cittad==2&female==1
tabstat university univdropout neet regret [aw=coeff] if cittad==2&female==1, by(track2) stats(mean sem)

*************************************************************************************************** 
* FIGURE A.3 
*************************************************************************************************** 
//graph 1 by livello istruzione
use "$definitivo/graph1_stranieri.dta",clear
twoway (line Primaria year, lwidth(thick)) (line SecondariaIgrado year, lwidth(thick)) (line SecondariaIIgrado year, lwidth(thick)), ytitle("percentuale") title("Alunni con cittadinanza non italiana per livello scolastico (pecentuali)", size(medium))  ///
xlabel(1 "01/02" 2 "02/03" 3 "03/04" 4 "04/05" 5 "05/06" 6 "06/07" 7 "07/08" 8 "08/09" 9 "09/10" 10 "10/11" 11 "11/12" 12 "12/13" 13 "13/14", angle(-45)) saving(stranieri_livello, replace)	

preserve
drop if year < 7
twoway (connected  Primaria year, msymbol(circle)) (connected  SecondariaIgrado year, msymbol(diamond)) (connected  SecondariaIIgrado year, msymbol(triangle)), ytitle("") title("by schooling level", size(medium))  xlabel(7(2)14 7 "2007/08"  9 "2009/10"  11 "2011/12"  13 "2013/14" )  legend(order(1 "Primary School" 2 "Middle School" 3 "High School")) name(graph1, replace) xtitle("") graphregion(color(white)) ylab(0(2)12)

graph save graph1, replace
restore

//graph 2: stranieri by tipo liceo
clear
 import excel "$definitivo/descriptive_trend.xlsx", sheet("tracks") firstrow
 drop in 9/16
 drop in 9/11
  drop LiceoClassico LiceoScientifico LiceoLinguistico exIstMagistrale


gen year=_n
order year, first

drop if year>=9
label define year 1 "07/08" 2 "08/09" 3 "09/10" 4 "10/11" 5 "11/12" 6 "12/13" 7 "13/14" ///
8 "14/15"
label value year year

twoway  (line Academic year, lwidth(thick))(line Technical year, lwidth(thick)) (line Vocational year, lwidth(thick)), ///
xlabel(1 "07/08" 2 "08/09" 3 "09/10" 4 "10/11" 5 "11/12" 6 "12/13" 7 "13/14", angle(-45)) ytitle("Percentuale") title("Alunni stranieri per tipologia di scuola secondaria (percentuale)", size(medium)) 
graph save stranieri_liceo, replace  


twoway  (connected Academic year,  msymbol(circle))(connected Technical year,  msymbol(diamond)) (connected Vocational year,  msymbol(triangle)), xlabel(1(2)7 1 "2007/08"  3 "2009/10"  5 "2011/12"  7 "2013/14") ytitle("") title("by high school track", size(medium)) legend(order(1 "Academic" 2 "Technical" 3 "Vocational")) name(graph2, replace) xtitle("") graphregion(color(white)) ylab(0(2)12)

graph save graph2, replace

graph combine graph1 graph2, graphregion(margin(l=0 r=0)) iscale(0.7) graphregion(color(white))
 
graph export "$output_n/immigrants_in_education_f.eps", replace

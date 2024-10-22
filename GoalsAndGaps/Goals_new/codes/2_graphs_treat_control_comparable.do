*************************************************************************************************
*				Title: graphs_treat_control_comparable.do
*                       Input: "$definitivo/all_students.dta"
*                   
*                                                         User: Michela Carlana
*                                                         Created: 14/09/2015
*                                                         Modified: 
* Description:
*************************************************************************************************

use "$definitivo/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta",clear

*set scheme s2gcolor
set scheme s1mono

gen group=2 if treat==1 & out==0
replace group=1 if treat==0 & program==1 & out==0
replace group=3 if comparable_italians==1
tab group 
keep if group!=.


*************************************************************************************************
* FIGURE 5
*************************************************************************************************


*************************************************************************************************
* MALE
*************************************************************************************************

preserve
keep if female==0
count
gen obs=1
collapse (mean) lictec2 fail  (sd) sdlictec2=lictec2 sdfail=fail (sum) obs, by(group)
foreach var in lictec2 fail  {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

bys group: sum lictec2


twoway 	(bar lictec2 group if group==1, color(dknavy) lcolor(black)) ///
		(bar lictec2 group if group==2, color(red*0.9) lcolor(black)) ///
		(bar lictec2 group if group==3, color(white) lcolor(black)) ///
      	(rcap uplictec2 downlictec2 group), ///
        xlabel( 1 "Control" 2 "Treated" 3 "Natives", noticks) ///
        xtitle("") title("Males") legend(off) yscale(range(0.6 0.9)) ylabel(0.6(0.05)0.9)
graph copy lictec2_mm, replace

twoway 	(bar fail group if group==1, color(dknavy) lcolor(black)) ///
		(bar fail group if group==2, color(red*0.9) lcolor(black)) ///
		(bar fail group if group==3, color(white) lcolor(black)) ///
      	(rcap upfail downfail group), ///
        xlabel( 1 "Control" 2 "Treated" 3 "Natives", noticks) ///
        xtitle("") title("Males") legend(off) yscale(range(0 0.12)) ylabel(0(0.02)0.12)
graph copy fail_mm, replace

restore

*************************************************************************************************
* FEMALE
*************************************************************************************************

preserve
keep if female==1
count
gen obs=1
collapse (mean) lictec2 fail  (sd) sdlictec2=lictec2 sdfail=fail (sum) obs, by(group)
foreach var in lictec2 fail  {
generate up$_var = $_var + invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
generate down$_var = $_var - invttail(obs-1,0.05)*(sd$_var / sqrt(obs))
}

twoway 	(bar lictec2 group if group==1, color(dknavy) lcolor(black)) ///
		(bar lictec2 group if group==2, color(red*0.9) lcolor(black)) ///
		(bar lictec2 group if group==3, color(white) lcolor(black)) ///
      	(rcap uplictec2 downlictec2 group), ///
        xlabel( 1 "Control" 2 "Treated" 3 "Natives", noticks) ///
        xtitle("") title("Females") legend(off) yscale(range(0.6 0.9)) ylabel(0.6(0.05)0.9)
graph copy lictec2_ff, replace

twoway 	(bar fail group if group==1, color(dknavy) lcolor(black)) ///
		(bar fail group if group==2, color(red*0.9) lcolor(black)) ///
		(bar fail group if group==3, color(white) lcolor(black)) ///
      	(rcap upfail downfail group), ///
        xlabel( 1 "Control" 2 "Treated" 3 "Natives", noticks) ///
        xtitle("") title("Females") legend(off) yscale(range(0 0.12)) ylabel(0(0.02)0.12)
graph copy fail_ff, replace
restore

graph combine lictec2_mm lictec2_ff, cols(2)  ysize(4) xsize(7) title("Panel A: Probability of choosing the high track")
graph copy lictec2, replace
graph save "$output/Figure2.gph",replace

graph combine fail_mm fail_ff, cols(2)  ysize(4) xsize(7) title("Panel B: Retention rate in grade 7 or 8")
graph copy fail, replace
graph save "$output/FigureA1.gph",replace
graph save "$output/FigureA1.gph",replace

*************
*Figure 5

graph combine lictec2 fail , cols(1)  ysize(4) xsize(5) 
graph save "$output/figure_treatmenteffects.gph",replace
graph export "$output/figure_treatmenteffects.pdf", replace
graph export "$output_n/figure_treatmenteffects_f.eps", replace 

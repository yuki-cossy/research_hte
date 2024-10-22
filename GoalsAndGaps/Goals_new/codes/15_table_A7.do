*********************************************************************************
* Table A.7 
***************************************************************************************************

use "$definitivo/main datasets/dataset_CarlanaLaFerrara_Pinotti_ECMA2020.dta", replace

keep if program==1

gen sample_without_data=0

* Add the hypotetical obs for students who were not match with our data
set obs 1411
replace treat=1 if treat==.
gen ord=_n
replace school_code=21 if ord==1382
replace school_code=22 if ord==1383
replace school_code=22 if ord==1384
replace school_code=74 if ord==1385
replace school_code=78 if ord==1386
replace school_code=97 if ord==1387
replace school_code=133 if ord==1388
replace school_code=129 if ord==1389
replace school_code=129 if ord==1390
replace school_code=129 if ord==1391
replace school_code=144 if ord>1391 & ord<1402
replace school_code=145 if ord>1401 & ord<1412
drop ord

set obs 1451
replace sample_without_data=1 if sample_without_data==.
replace program=1 if program==.
replace treat=0 if treat==.

gen ord=_n
replace school_code=5 if ord==1412
replace school_code=116 if ord==1413
replace school_code=16 if ord>1413 & ord<1420
replace school_code=36 if ord>1419 & ord<1424
replace school_code=44 if ord>1423 & ord<1427
replace school_code=46 if ord>1426 & ord<1431
replace school_code=53 if ord>1430 & ord<1434
replace school_code=63 if ord>1433 & ord<1438
replace school_code=138 if ord>1437 & ord<1444
replace school_code=142 if ord>1443 & ord<1451
replace school_code=44 if ord==1451


*Create Table A.7
	cap file close sumstat
	file open sumstat using "$output/Table_A7.tex", write replace

	file write sumstat "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}  \begin{tabular}{@{\extracolsep{4pt}}p{7cm}*{6}{>{\centering\arraybackslash}m{2cm}}@{}}   \toprule" _n      // table header
	file write sumstat	"  & Control & Treatment & Difference & P-value & Std diff. \\  " _n
	
	file write sumstat "\midrule " _n 
	
	count if treat!=.  
	local total: di %7.0fc `r(N)'

	count if treat==1 
	local treat: di %7.0fc `r(N)'

	count if treat==0 
	local control: di %7.0fc `r(N)'

	foreach var in sample_without_data {
	
	local varlab: variable label `var'   
		
		sum `var' 
		local totalmean: di %7.3f `r(mean)'	
		local totalsd: di %7.3f `r(sd)'
		
		
		sum `var' if treat==1 
		local treatmean: di %7.3f `r(mean)'	
		local treatsd: di %7.3f `r(sd)'
		
		sum `var' if treat==0 
		local controlmean: di %7.3f `r(mean)'	
		local controlsd: di %7.3f `r(sd)'
		
		gen difference = (`treatmean'-`controlmean')
		sum difference
		local difference: di %7.3f `r(mean)'

		gen stand_diff = (`treatmean'-`controlmean')/ `totalsd'
		sum stand_diff
		local diff: di %7.3f `r(mean)'
		
		*ttest `var', by(treat) 
		*local pvalue: di %7.3f `r(p)' 
		reg `var' treat, cluster(school_code) robust

		
		
		foreach x in treatsd controlsd diff {   // to remove leading blank spaces from numbers, and round the number to 3 decimal spaces
				local `x'=trim(string(``x'',"%7.3f"))
			}
	
		
	    file write sumstat "Initial sample &`treat' & `control'&   & & \\    \addlinespace[3pt]   " _n 
		file write sumstat "Fraction missing match MIUR-INVALSI & `treatmean' &  `controlmean' & `difference'  & [0.70] & `diff'     \\     " _n  
		
		drop stand_diff difference diff
		}

drop if sample_without_data==1
	
	count if treat!=.  
	local total: di %7.0fc `r(N)'

	count if treat==1 
	local treat: di %7.0fc `r(N)'

	count if treat==0 
	local control: di %7.0fc `r(N)'

	foreach var in out_sample {
	
	local varlab: variable label `var'   
		
		sum `var' 
		local totalmean: di %7.3f `r(mean)'	
		local totalsd: di %7.3f `r(sd)'
		
		
		sum `var' if treat==1 
		local treatmean: di %7.3f `r(mean)'	
		local treatsd: di %7.3f `r(sd)'
		
		sum `var' if treat==0 
		local controlmean: di %7.3f `r(mean)'	
		local controlsd: di %7.3f `r(sd)'
		
		gen difference = (`treatmean'-`controlmean')
		sum difference
		local difference: di %7.3f `r(mean)'

		gen stand_diff = (`treatmean'-`controlmean')/ `totalsd'
		sum stand_diff
		local diff: di %7.3f `r(mean)'
		
		reg `var' treat, cluster(school_code) robust

		*ttest `var', by(treat) 
		*local pvalue: di %7.3f `r(p)' 
		
		
		foreach x in treatsd controlsd diff difference {   // to remove leading blank spaces from numbers, and round the number to 3 decimal spaces
				local `x'=trim(string(``x'',"%7.3f"))
			}
	
		
	    file write sumstat "Number of students with available MIUR-INVALSI  &`treat' & `control'&   & & \\    \addlinespace[3pt]   " _n 
		file write sumstat "Fraction Dropped between INVALSI6 and start of EOP & `treatmean' &  `controlmean' & `difference'  & [0.49] & `diff'     \\     " _n  
		
		drop stand_diff
		}
	
		count if treat!=.  
	local total: di %7.0fc `r(N)'

	count if treat==1 &  program==1 & out_sample==0
	local treat: di %7.0fc `r(N)'

	count if treat==0 &  program==1 & out_sample==0
	local control: di %7.0fc `r(N)'


	file write sumstat "Final sample &`treat' & `control'&   & & \\    \addlinespace[3pt]   " _n 

	file write sumstat "\hline \hline" _n           // table footer
	file write sumstat "\end{tabular}" _n
	file close sumstat

/*********************************
	FOR FWER COMPUTATIONS
*********************************/
/*------------------------------------------------------------------------------
program: 		fwer
				
description:
------------------------------------------------------------------------------*/

cap program drop fwer
program define fwer
syntax 	[if],					///
		dep_vars(varlist) 		///
		controls(varlist) 		///
		[						///
		cluster(varname)	 	///
		fisher					/// compute also Fisher exact p (approx by simulation)
		num_rep(integer 100000)	///
		]

	quietly {

		tempfile p_values base_data
		local cluster cluster(`cluster')

	**	REAL DATA
	*************
	/* 	calculate the real p-values
		(and save them in a table in the form of a temporary file) */
		save `base_data'
		
		preserve
			cap xtset

			gen variable = ""
			gen coeff    = .
			gen p_values = .
			
			local line = 0
			foreach var of varlist `dep_vars' {
				local ++line
				local extra : 	char `var'[extra_controls]

				_pval_table_get `controls' `extra' `if', `cluster' addcoeff d(`var') t(treatment) p(p_values) line(`line') // hardcoded vars: "coeff" "variable"
			}
			_pval_table_save `p_values', replace
		restore
		*

	** 	SIMULATED DATA
	******************
		tempvar 	treat_r 	/// synthetic treatment (independent on anything by construction)
					p_values_r	/// p-values on synthetic data
					p_min 		/// p-values_r sorted to match the ranking of real ones  
					p_fewer   	//  empirical p-values

		gen S = 0 // variable that will be used to get FWER corrected p-values
		if `: word count `fisher'' {
			gen S2 = 0 // variable used to get approx of Fisher exact p-values, **not** FWER corrected
		}
		*
		gen variable = "" // gen variable used to merge with the dataset of real p-values
		
		forvalues i=1(1)`num_rep'{ // here starts the simulation
			
		/* 	simulate the data under the null of no treatment effect */
			perm_rand treatment, gen(`treat_r')
			
		/* 	calculate p-values on synthetic data */
			cap xtset
			gen `p_values_r' = .
			
			local line = 0
			foreach var of varlist `dep_vars' {
				local ++line
				local extra : 	char `var'[extra_controls]

 				_pval_table_get `controls' `extra' `if', `cluster' d(`var') t(`treat_r') p(`p_values_r') line(`line') // hardcoded vars: "coeff" "variable" "se"
			}
			*
		/* 	match real and simulated p-values according to their rank */
			drop if `p_values_r' == . // drop obs out of the table (note, this time does not drop vars out of the table!)
			
			merge 1:1 variable using "`p_values'", update replace assert(match match_conflict)
			drop _merge
			
			if `: word count `fisher'' {
				replace S2 = S2 + 1 if `p_values_r' < p_values // this will be **not** FWER corrected, since perm_ascend has not been called yet
			}
			
		/* 	keep track of # times the simulated p-values are smaller than the corresponding observed ones */			
			sort rank
			step_down `p_values_r', n(`: word count `dep_vars'') gen(`p_min')
			
			replace S = S + 1 if `p_min' < p_values
			
			merge 1:1 nstudent round using "`base_data'" // get the dataset ready for a new simulation
			drop 	_merge 			///
					`treat_r'		///
					`p_values_r' 	///
					`p_min'
			
		} // end of the simulation
		*
	/*	get the simulated Fisher exact p-values, **not** FWER corrected */
		if `: word count `fisher'' {
			gen p_Fisher  = S2/`num_rep'
			local p_Fisher "p_Fisher"
		}
	/* 	compute empirical p-values */
		gen `p_fewer' = S/`num_rep'
		
	/* 	get the FWER adjusted p-values, matching according to rank again */
		perm_ascend `p_fewer', gen(p_FWER) rank(rank)

		keep 	if variable != ""
		keep 	variable   coeff   p_values   `p_Fisher'   p_FWER
		order 	variable   coeff   p_values   `p_Fisher'   p_FWER
	}
	*
end

/*********************************
	FOR FDR COMPUTATIONS
*********************************/
/*------------------------------------------------------------------------------
program: 		fdr
				
description:
------------------------------------------------------------------------------*/

cap program drop fdr
program define fdr
syntax 	[if],					///
		dep_vars(varlist) 		///
		controls(varlist) 

	quietly {
		
		/* 	calculate the real p-values and sort the depvars s.t. p1<p2<...<pM */

		cap xtset

		gen variable = ""
		gen coeff    = .
		gen p_values = .
		
		local line = 0
		foreach var of varlist `dep_vars' {
			local ++line
			local extra : 	char `var'[extra_controls]

			_pval_table_get `controls' `extra' `if', addcoeff d(`var') t(treatment) p(p_values) line(`line') // hardcoded vars: "coeff" "variable"
		}
		
		keep variable p_values coeff // drops vars outside of the table
		drop if p_values==. // drops obs outside of the table

		* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

		sort p_values
		gen int rank = _n

		* Collect the total number of p-values tested

		quietly sum p_values
		local totalpvals = r(N)

		* Set the initial counter to 1 

		local qval = 1

		* Generate the variable that will contain the BH (1995) q-values

		gen p_FDR = 1

		* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

		while `qval' > 0 {
			* Generate value qr/M
			quietly gen fdr_temp = `qval'*rank/`totalpvals'
			* Generate binary variable checking condition p(r) <= qr/M
			quietly gen reject_temp = (fdr_temp>=p_values) if fdr_temp!=.
			* Generate variable containing p-value ranks for all p-values that meet above condition
			quietly gen reject_rank = reject_temp*rank
			* Record the rank of the largest p-value that meets above condition
			quietly egen total_rejected = max(reject_rank)
			* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
			replace p_FDR = `qval' if rank <= total_rejected & rank~=.
			* Reduce q by 0.001 and repeat loop
			quietly drop fdr_temp reject_temp reject_rank total_rejected
			local qval = `qval' - .001
		}
		drop rank
	}

end

/*------------------------------------------------------------------------------
program: 		fdr_sharp
				
description:
------------------------------------------------------------------------------*/

cap program drop fdr_sharp
program define fdr_sharp
syntax 	[if],					///
		dep_vars(varlist) 		///
		controls(varlist) 

	quietly {
		
		/* 	calculate the real p-values and sort the depvars s.t. p1<p2<...<pM */

		cap xtset

		gen variable = ""
		gen coeff    = .
		gen p_values = .
		
		local line = 0
		foreach var of varlist `dep_vars' {
			local ++line
			local extra : 	char `var'[extra_controls]

			_pval_table_get `controls' `extra' `if', addcoeff d(`var') t(treatment) p(p_values) line(`line') // hardcoded vars: "coeff" "variable"
		}
		
		keep variable p_values coeff // drops vars outside of the table
		drop if p_values==. // drops obs outside of the table

		* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

		sort p_values
		gen int rank = _n

		* Collect the total number of p-values tested

		quietly sum p_values
		local totalpvals = r(N)

		* Set the initial counter to 1 

		local qval = 1

		* Generate the variable that will contain the BH (1995) q-values

		gen p_sharpFDR = 1

		* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

		while `qval' > 0 {

			* First Stage
			* Generate the adjusted first stage q level we are testing: q' = q/1+q
			local qval_adj = `qval'/(1+`qval')
			* Generate value q'*r/M
			gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
			* Generate binary variable checking condition p(r) <= q'*r/M
			gen reject_temp1 = (fdr_temp1>=p_values) if p_values~=.
			* Generate variable containing p-value ranks for all p-values that meet above condition
			gen reject_rank1 = reject_temp1*rank
			* Record the rank of the largest p-value that meets above condition
			egen total_rejected1 = max(reject_rank1)

			* Second Stage
			* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
			local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
			* Generate value q_2st*r/M
			gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
			* Generate binary variable checking condition p(r) <= q_2st*r/M
			gen reject_temp2 = (fdr_temp2>=p_values) if p_values~=.
			* Generate variable containing p-value ranks for all p-values that meet above condition
			gen reject_rank2 = reject_temp2*rank
			* Record the rank of the largest p-value that meets above condition
			egen total_rejected2 = max(reject_rank2)

			* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
			replace p_sharpFDR = `qval' if rank <= total_rejected2 & rank~=.
			* Reduce q by 0.001 and repeat loop
			drop fdr_temp* reject_temp* reject_rank* total_rejected*
			local qval = `qval' - .001

		}
		drop rank
	}

end

/*********************************
	FOR MEAN EFFECTS COMPUTATIONS
*********************************/

/*------------------------------------------------------------------------------
program: 		KLK_2007
				
description:
------------------------------------------------------------------------------*/

cap program drop KLK_2007 // stands for Kling, Liebman & Katz (2007)
program define KLK_2007
syntax varlist, GENerate(name) TREATvar(varname)
	
	local newvar 	`generate'
	local t			`treatvar'
	
	local std_vars ""
	foreach var of varlist `varlist' {
		tempvar std_`var' mean_std_`var'_t
		
		qui sum `var' if `t'==0 																		// to have control mean and sd in memory						
		qui gen 	`std_`var''			=	(`var'-`r(mean)')/`r(sd)' 									// standardizes the variable																								
		qui egen 	`mean_std_`var'_t'	=	mean( `std_`var'') 			if `t'==1 						// get mean of the standardized var for treated																								
		qui replace `std_`var''			=	`mean_std_`var'_t'  		if `t'==1 & `std_`var''==. 		// impute missing vals for treated at that mean																												
		qui replace `std_`var''			=	0 							if `t'==0 & `std_`var''==. 		// impute missing vals for untreated at zero (that is untreated mean!)																												
		
		local std_vars 	"`std_vars' `std_`var''"														// local containing names of standardized vars
	}
	egen 	`newvar' = rowmean(`std_vars') 																// group summary index: simple mean over standardized vars

end

/*------------------------------------------------------------------------------
program: 		Anderson_2008
				
description:
------------------------------------------------------------------------------*/
cap program drop Anderson_2008
program define Anderson_2008
syntax varlist, GENerate(name) TREATvar(varname)

	cap mata: mata drop X 
	cap mata: mata drop N 
	cap mata: mata drop M 
	cap mata: mata drop Y 
	cap mata: mata drop R 
	cap mata: mata drop W 
	cap mata: mata drop norm_const 
	cap mata: mata drop get 

	local newvar 	`generate'
	local t			`treatvar'
	
	local std_vars ""
	foreach var of varlist `varlist' {
		tempvar std_`var' mean_std_`var'_t
		
		qui sum `var' if `t'==0 																		// to have control mean and sd in memory						
		qui gen 	`std_`var''			=	(`var'-`r(mean)')/`r(sd)' 									// standardizes the variable																								
		qui egen 	`mean_std_`var'_t'	=	mean( `std_`var'') 			if `t'==1 						// get mean of the standardized var for treated																								
		qui replace `std_`var''			=	`mean_std_`var'_t'  		if `t'==1 & `std_`var''==. 		// impute missing vals for treated at that mean																												
		qui replace `std_`var''			=	0 							if `t'==0 & `std_`var''==. 		// impute missing vals for untreated at zero (that is untreated mean!)																												
		
		local std_vars 	"`std_vars' `std_`var''"														// local containing names of standardized vars
	}
		
	* 2. Construct matrix and component weights using controls only
		putmata X =(`std_vars') if `t'==0										/* 	X = matrix of standardized vars */
		putmata N =(`std_vars')													/*  this is just to get the correct N once in mata */
		mata: N = rows(N)
		
		mata: M = J(rows(X),1,1)*mean(X)										/*	matrix of column means of X */
		mata: Y = X-M															/* 	matrix of vars demeaned */
		mata: R = invsym((Y'Y)/rows(Y))											/* 	inverted covariance matrix */
		mata: W = J(N,1,1)*colsum(R)											/* 	weights (used colsum(R) instead of rowsum(R)) */
		mata: norm_const = rowsum(W)											/* 	normalizing constant, is the sum of all weights */	
		mata: get = norm_const, W
		
		foreach x of varlist `std_vars' {
			local w_list 	"`w_list' w_`x'"									/* local containing list of weights vars */
		}
		
		getmata (norm_const `w_list') = get, force
		
	* 3. Apply weights and construct index
		gen `newvar'  =  0 													/* 	inizializza la variabile che conterrà i valori dell'indice */
		foreach x of varlist `std_vars' {									/* 	loop su tutte le variabili dell'indice */					
			replace `newvar' = `newvar' + `x'*(w_`x')						/* 	il valore dell'indice è costruito iterativamente come somma delle
																				variabili standardizzate moltiplicate per i rispettivi pesi */
		}
		qui replace `newvar' = `newvar'/norm_const							/* 	finite le iterazioni (sommato su tutte le variabili), il valore ottenuto
																				è normalizzato dividendo per la somma dei pesi */
		drop norm_const `w_list'																					

end

/*------------------------------------------------------------------------------
program: 		_pval_table_get

notes:			- for internal use. 
				- prefix "_" indicates that it affects the dataset one is using 
				  when it is invoked.
				
description:	
				
					it runs a regression of the 
					dependent variable specified in depvar() on a treatment variable
					specified in treatvar() and other control variables specified in
					varlist (default regression type is linear, ologit is used if the 
					dependent variable specifies so in a characteristic named reg_type 
					associated with it).
					It uses the results from this regression to fill the values 
					in the line indicated in option line() of variables "variable", 
					"var_label", "coeff", "se", "`p_var'", which have to be created 
					before calling the program.
					
------------------------------------------------------------------------------*/

cap program drop _pval_table_get
program _pval_table_get // hardcoded vars: "coeff" "variable"
syntax varlist (ts fv) [if], 				///
				Depvar(varname) 	///
				Treatvar(varname)	///
				P_var(varname)		///
				line(integer) 		///
				[					///
				cluster(varname) 	///
				addcoeff 			///
				]

	local reg_type:	char `depvar'[reg_type]
	local controls `varlist'

	quietly {
		xtset /* checks data are panel and sorts by panelvar timevar */
		
		replace variable = "`depvar'" in `line'

		tempname p
		
		* go for the requested regression type if a particular form is specified
		if "`reg_type'" != "" {
			`reg_type' `depvar' `treatvar' `controls' `if', robust cluster(`cluster')
		}
		* otherwise use linear regression
		else {
			reg `depvar' `treatvar' `controls' `if', robust cluster(`cluster')
		}
		if `: word count `addcoeff'' {
			replace coeff = _b[`treatvar'] 	in `line'
		}

		if "`reg_type'" == "ologit" {
			gen `p' = (2 *(1 - normal(abs(_b[`treatvar']/_se[`treatvar']))))
		}
		else {
			gen `p' = (2 * ttail(e(df_r), abs(_b[`treatvar']/_se[`treatvar'])))
		}
		replace `p_var' = `p' in `line'
		cap drop `p' `se'
		
	}
	*
end

/*------------------------------------------------------------------------------
program: 		_pval_table_save

notes:			- for internal use. 
				- prefix "_" indicates that it affects the dataset one is using 
				  when it is invoked.
				
description:
------------------------------------------------------------------------------*/

cap program drop _pval_table_save
program _pval_table_save 	/* 	run right after the loop in which _pvar_table_get is used
								hardcoded vars: "coeff" "p_values" "variable"
								hardcoded newvars "rank" */
syntax anything , [replace]
	local name `anything'

	keep variable p_values coeff // drops vars outside of the table
	drop if p_values==. // drops obs outside of the table

	sort p_values
	gen rank = _n
	
	save "`name'", `replace'

end

/*------------------------------------------------------------------------------
program: 		perm_rand

notes:			- for internal use. 
				
description:
------------------------------------------------------------------------------*/

cap program drop perm_rand
program perm_rand, sortpreserve
syntax varname [, gen(name) replace]

	if "`gen'"=="" & "`replace'"=="" {
		di as error `"either option "gen(newvarname)" or "replace" must be specified."'
		exit 197	
	}
	*
	local x `varlist'
	local new `gen'

	quietly {
		tempname n r w y
		
		gen `n' = _n
		gen double `r' = uniform()
		gen double `w' = uniform()
		
		sort `r' `w'
		gen `y' = `x'[`n']
		
		if "`gen'"!="" {
			rename `y' `gen'
		}
		else if "`replace'" == "replace" {
			order `y', after(`x')
			drop `x'
			rename `y' `x'
		}
	}
	*
end

/*------------------------------------------------------------------------------
program: 		perm_ascend

notes:			- for internal use. 
				
description:
------------------------------------------------------------------------------*/

cap program drop perm_ascend
program perm_ascend, sortpreserve
syntax varname [, gen(name) replace rank(varname)]
	
	if "`gen'"=="" & "`replace'"=="" {
		di as error `"either option "gen(newvarname)" or "replace" must be specified."'
		exit 197	
	}
	*
	local x `varlist'
	local new `gen'

	quietly {
		tempname n y
		
		if "`rank'"!="" {
			cap sort `rank' // in case vars are not already sorted and opt rank() is specified
		}
		gen `n' = _n
		sort `x'
		gen `y' = `x'[`n']
		
		if "`gen'"!="" {
			rename `y' `gen'
		}
		else if "`replace'" == "replace" {
			order `y', after(`x')
			drop `x'
			rename `y' `x'
		}
	}
	*
end

/*------------------------------------------------------------------------------
program: 		step_down

notes:			- for internal use. 
				
description:
------------------------------------------------------------------------------*/

cap program drop step_down
program define 	 step_down
syntax varname, n(integer) gen(name)
	
	tempvar x
	
	local countdown = `n'
	quietly gen `gen' = `varlist'
	while `countdown' >= 1 {
		quietly replace `gen' = min(`gen',`gen'[_n+1]) in `countdown'
		local --countdown
	}
	*
end

exit

*==================================================================================
*==================================================================================

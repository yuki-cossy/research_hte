
// first version: May 2014
// this version: June 2020

// WORKSHOP

clear all
macro drop _all
set more off
set mem 1000m
set seed 27062007
set matsize 11000

// defines the reference folder

global root "C:/Users/isd349/Dropbox/cariplo/Econometrica/material_for_publication/submit/replication_files_ECMA"

*global root "/Users/michela/Dropbox/cariplo/Econometrica/material_for_publication/submit/replication_files_ECMA"


global codes   "$root/codes"
global output  "$root/output"
global output_n  "$root/output/new_figures"
global definitivo   "$root/dataset"
global trash   "$root/trash"

cd "$codes"


*******************************************************************************
*Global for this paper
*******************************************************************************

global control "immigrato_prima_gen stdinvalsiI stdinvalsiI_2 prov2 prov3 prov4 prov5"
global school "class_size perc_imm school_size" 


// This is the sequence of do files to reproduce the final paper results:

*Figure A.2: we use restricted data for that and we can't share them. 

*******************************************************************************
*A) Main analysis
*******************************************************************************

do "$codes/1_program_evaluation.do" //Tables 1, 2, 3, A8, B1, 4, 6, A5,  A9, A6

do "$codes/2_graphs_treat_control_comparable.do" // Figure 5

do "$codes/3_multiple_hypotesis_test.do" //Table A.12

do "$codes/4_characteristics_compliers.do" //Figure A.6

do "$codes/5_distribution_outcomes.do" //Figure A.8 

do "$codes/6_heckman_decomposition.do" //Table 5, Table A.13

do "$codes/7_decomposition_Gelbach.do" //Table A.14

do "$codes/8_segregation.do" // Figure A.4, Figure B.1, Table A.2, Figure 1, and Figure 3 

do "$codes/9_spillover_effects.do" // Table 7 and Figure A.5

do "$codes/10_RDD.do" // Figure A.7 , Figure 7, Tables A.11 // Figure 4 and Table A.4

do "$codes/11_causalforest.do" // Table C.1, Figure 6 

do "$codes/12_MHT_heterogeneous_effects.do" // Table A.10 
*******************************************************************************
*B) Other datasets
******************************************************************************

do "$codes/13_descript_background_istatsurvey" //Table A.1, Figure A.3

do "$codes/14_table_a3" // Table A.3

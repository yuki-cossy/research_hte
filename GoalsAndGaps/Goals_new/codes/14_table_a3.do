

use "$definitivo/tablea3_data.dta", clear

**** SHOW THAT MISSINGNESS CORRELATES WITH LOW-SES ****
preserve
gen occmother_missing=bluemother==.
gen occfather_missing=bluefather==.
collapse poptot educmother_missing educfather_missing occmother_missing occfather_missing unemplrate emplrate unemplrate_m emplrate_m (max) prov2 prov3 prov4 prov5, by(area)

reg educmother_missing emplrate prov2 prov3 prov4 prov5 [aw=poptot], robust 
outreg2 using "$output/educmissingarea_PAOLO.xls", replace label keep(emplrate) dec(3) pdec(3) noast

reg educmother_missing unemplrate prov2 prov3 prov4 prov5 [aw=poptot], robust 
outreg2 using "$output/educmissingarea_PAOLO.xls", append label keep(unemplrate) dec(3) pdec(3) noast


reg educfather_missing emplrate prov2 prov3 prov4 prov5 [aw=poptot], robust 
outreg2 using "$output/educmissingarea_PAOLO.xls", append label keep(emplrate) dec(3) pdec(3) noast

reg educfather_missing unemplrate prov2 prov3 prov4 prov5 [aw=poptot], robust 
outreg2 using "$output/educmissingarea_PAOLO.xls", append label keep(unemplrate) dec(3) pdec(3) noast
restore



reg educmother_missing emplrate prov2 prov3 prov4 prov5, robust cluster(area) 
outreg2 using "$output/educmissingindiv_PAOLO.xls", replace label keep(emplrate) dec(3) pdec(3) noast

reg educmother_missing unemplrate prov2 prov3 prov4 prov5, robust cluster(area) 
outreg2 using "$output/educmissingindiv_PAOLO.xls", append label keep(unemplrate) dec(3) pdec(3) noast

reg educfather_missing emplrate prov2 prov3 prov4 prov5, robust cluster(area) 
outreg2 using "$output/educmissingindiv_PAOLO.xls", append label keep(emplrate) dec(3) pdec(3) noast

reg educfather_missing unemplrate prov2 prov3 prov4 prov5, robust cluster(area) 
outreg2 using "$output/educmissingindiv_PAOLO.xls", append label keep(unemplrate) dec(3) pdec(3) noast





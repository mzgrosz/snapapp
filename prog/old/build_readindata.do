local n=4

*andrew work
if `n' == 1 {
	global data "H:\ssdi" 
	global logs "H:\ssdi\logfiles" 
	global graphs "H:\ssdi\graphs" 
}

*andrew home
if `n' == 3 { 
	global dir "C:\Users\Andrew Foote.AFOOTE\Google Drive\SSDIapps" 
	gl data "${dir}\data"
	gl logs "${dir}\logs"
	gl graphs "${dir}\graphs"
	gl out "${dir}\output"
} 


* michel
if `n' == 4 {
	gl dir = "/home/users/mgrosz.AD3/snapapp"
	gl data "${dir}/data"
	gl logs "${dir}/logs"
	gl out "${dir}/output"
}	





insheet using $data/snap_policy.csv, clear
save $data/snap_policy, replace




use "$data/county_snap_interim.dta", clear
set more off 

foreach var in pop numpov prgnum prgben prg_pop prg_pov amb_par { 

preserve 
keep fips `var'*

forvalues i = 0/9 {
	cap rename `var'0`i' `var'`i'
}

reshape long `var', i(fips) j(year) 
replace year = 1900+year if year >60 
replace year = 2000 + year if year <20 

sort fips year 
tempfile `var'
save ``var'', replace

restore

} 

use `pop', clear 

foreach var in numpov prgnum prgben prg_pop prg_pov amb_par { 

merge fips year using ``var''
tab _merge 

drop _merge
sort fips year

}

keep if year >= 1990

save "$data/county_snap_longfile.dta", replace

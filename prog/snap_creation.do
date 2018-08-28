use "$datadir/county_snap_interim.dta", clear
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

save "$datadir/county_snap_longfile.dta", replace

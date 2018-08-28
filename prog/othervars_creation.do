use "$ssdidatadir/dataprepped_v6.dta", clear
set more off
keep fips year lau_* total_* access_1 access_2

sort fips year 

tab year 

tabstat access_2, by(year)

tempfile othervars
save `othervars'


use "$datadir/snap_policy.dta", clear

drop state_pc statename yearmonth 

gen internet_app = (oapp == 1) 
	replace internet_app = 0.5 if oapp == 2

bys state_fips year: egen internet_app_annual = mean(internet_app) 
		/*averaging share of year that has internet access */

keep if month == 1 /* what is policy on January 1? */

sort state_fips year 

tempfile policy 
save `policy', replace


use "$datadir/county_snap_longfile.dta", clear

sort fips year 
merge fips year using `othervars'

tab year _merge
drop _merge

gen state_fips = floor(fips/1000)

sort state_fips year 
merge state_fips year using `policy'

tab year _merge 

drop if year >= 2012

save "$datadir/snap_paper_merged.dta", replace

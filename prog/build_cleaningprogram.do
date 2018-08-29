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


cd $dir
cd ../ssdinet/data
use "dataprepped_v6.dta", clear
set more off
keep fips year lau_* total_* access_1 access_2

sort fips year 

tab year 

tabstat access_2, by(year)

tempfile othervars
save `othervars'


use "$data/snap_policy.dta", clear
tostring yearmonth, replace
	gen year=substr(yearmonth,1,4)
	gen month=substr(yearmonth,5,2)
	destring year, replace
	destring month, replace
drop state_pc statename yearmonth 

gen internet_app = (oapp == 1) 
	replace internet_app = 0.5 if oapp == 2

bys state_fips year: egen internet_app_annual = mean(internet_app) 
		/*averaging share of year that has internet access */

keep if month == 1 /* what is policy on January 1? */

sort state_fips year 

tempfile policy 
save `policy', replace


use "$data/county_snap_longfile.dta", clear

sort fips year 
merge fips year using `othervars'

tab year _merge
drop _merge

gen state_fips = floor(fips/1000)

sort state_fips year 
merge state_fips year using `policy'

tab year _merge 

drop if year >= 2012


*Policy variables
gen onlineapp_post=internet_app_annual>0 & internet_app_annual!=.
	gen trashy=year if onlineapp_post==1
		replace trashy=9999 if onlineapp_post!=1
		bysort fips: egen onlineapp_minyear=min(trashy)
		replace onlineapp_minyear=. if onlineapp_miny>3000
		drop trashy
gen onlineapp_ever=onlineapp_minyear>0 & onlineapp_minyear!=.
forvalues y=1/20{
	gen onapp_pr`y'=(year-onlineapp_minyear)==-`y' & onlineapp_ever==1
	}
forvalues y=1/9{
	gen onapp_po`y'=(year-onlineapp_minyear)==`y' & onlineapp_ever==1
	}




save "$data/snap_paper_merged.dta", replace

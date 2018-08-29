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



set more off 
clear all
set maxvar 30000
set matsize 5000 
use "$datadir/snap_paper_merged.dta", clear 

/******************************************************
Creating variables that we need
*******************************************************/
#delimit 
qui tab fips, gen(cty)	
local numcty=r(r) 

qui tab year, gen(yy)


drop lau_urate
gen lau_urate = lau_unemp*100 / lau_LF

forvalues i = 1/`numcty' {
	gen ctytrend`i' = (cty`i'==1)*(year-2000) 
}


/*********************************************************
Create the policy interaction
**********************************************************/

gen app_x_internet = internet_app*access_2

sum app_x_internet

tabstat app_x_internet, by(year)
keep if year <= 2008



foreach pop in 	18_29 30_44 45_54 55p { 
	gen share_`pop' = total_age_`pop'_pop/total_pop  
			}


*areg prgnum app_x_internet yy* internet_app access_2 total_pop,absorb(fips) cluster(state_fips)

gen log_prgnum = log(prgnum) 

/********************************
Controls
*********************************/
local controls "lau_LF total_male_black_pctpop total_female_black_pctpop
				share_18_29 share_30_44 share_45_54 share_55p"


/*****************************
Main Regression
*****************************/

areg log_prgnum app_x_internet yy* internet_app access_2 [weight=total_pop],absorb(fips) cluster(state_fips)

areg log_prgnum app_x_internet yy* internet_app access_2  `controls' [weight=total_pop],absorb(fips) cluster(state_fips)

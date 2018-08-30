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

*************************************************************************************************************
local figbacks "plotregion(fcolor(white)) graphregion(fcolor(white) lwidth(large)) bgcolor(white)"
set scheme s1color
local theusual "replace noconstant nomtitles nonotes noobs nogaps noline nonumbers compress label "

set more off 
clear all
set maxvar 30000
set matsize 5000 
use "$data/snap_paper_merged.dta", clear 

/******************************************************
Creating variables that we need
*******************************************************/
qui tab fips, gen(cty)	
local numcty=r(r) 


drop lau_urate
gen lau_urate = lau_unemp*100 / lau_LF

forvalues i = 1/`numcty' {
	gen ctytrend`i' = (cty`i'==1)*(year-2000) 
}
forvalues i=1/56{
	gen statetr`i'=(state_==`i')*(year-2000)
}

gen ln_prgnum_pu=ln(prgnum)
gen ln_prgnum_in0=ln_prgnum
	replace ln_prgnum_in0=0 if ln_prgnum_pu==.

	
*******************************************************************
*Regressions	
********************************************************************
gen sample_all=1
gen sample_adopters=onlineapp_ever

foreach g in pu in0{
foreach h in all adop{
eststo t_`g'_`h'1: reg ln_prgnum_`g' onlineapp_post  [weight=total_pop] if year>1996 & sample_`h'==1, cluster(fips)
eststo t_`g'_`h'2: reg ln_prgnum_`g' onlineapp_post i.year [weight=total_pop] if year>1996 & sample_`h'==1, cluster(fips)
eststo t_`g'_`h'3: areg ln_prgnum_`g' onlineapp_post i.year [weight=total_pop] if year>1996 & sample_`h'==1, cluster(fips) absorb(state_)
eststo t_`g'_`h'4: areg ln_prgnum_`g' onlineapp_post statetr* i.year [weight=total_pop] if year>1996 & sample_`h'==1, cluster(fips) absorb(state_)

esttab t* using "$out/ddreg_`g'_`h'.tex", `theusual' se prehead(" ") prefoot(" ") posthead(" ") postfoot(" ") stat(N r2) keep(onlineapp_post)
eststo clear
}
}





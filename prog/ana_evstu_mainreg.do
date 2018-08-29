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

gen ln_prgnum=ln(prgnum)
/*********************************************************
Create the policy interaction
**********************************************************/
gen ysince=year-onlineapp_min
*choose number of pre- and post-years
local pre=5
local post=3
*create the "loaded" variables for that range
cap drop load_* sample
gen load_pre=ysince<-`pre'
gen load_pos=ysince>`post'
gen sample=1
	replace sample=0 if onlineapp_min>(2011-`post')
	
	
	
	*no trends
	areg ln_prgnum  onapp_pr1-onapp_pr`pre' onapp_po1-onapp_po`post' load_pos load_pre [weight=total_pop] if sample==1 & year>1996, cluster(fips) absorb(fips)
		mat a=0,0,0
		forvalues y=1/`pre'{
			mat z=-`y',_b[onapp_pr`y'], _se[onapp_pr`y']
			mat a=a\z
			}
		forvalues y=1/`post'{
			mat z=`y',_b[onapp_po`y'], _se[onapp_po`y']
			mat a=a\z
			}
		mat a_notr_`pre'_`post'=a
	*state trends
	areg ln_prgnum statetr* onapp_pr1-onapp_pr`pre' onapp_po1-onapp_po`post' load_pos load_pre [weight=total_pop] if sample==1 & year>1996, cluster(fips) absorb(fips)
		mat a=0,0,0
		forvalues y=1/`pre'{
			mat z=-`y',_b[onapp_pr`y'], _se[onapp_pr`y']
			mat a=a\z
			}
		forvalues y=1/`post'{
			mat z=`y',_b[onapp_po`y'], _se[onapp_po`y']
			mat a=a\z
			}
		mat a_sttr_`pre'_`post'=a

	*county trends
	areg ln_prgnum ctytr* onapp_pr1-onapp_pr`pre' onapp_po1-onapp_po`post' load_pos load_pre [weight=total_pop] if sample==1 & year>1996, cluster(fips) absorb(fips)
		mat a=0,0,0
		forvalues y=1/`pre'{
			mat z=-`y',_b[onapp_pr`y'], _se[onapp_pr`y']
			mat a=a\z
			}
		forvalues y=1/`post'{
			mat z=`y',_b[onapp_po`y'], _se[onapp_po`y']
			mat a=a\z
			}
		mat a_cttr_`pre'_`post'=a
		
		
*SPIT OUT GRAPHS
		foreach g in notr sttr cttr{
		preserve
		clear
		svmat a_`g'_`pre'_`post', n(col)
			rename (c1 c2 c3) (y b se)
			gen u=b+1.96*se
			gen l=b-1.96*se
			sort y
			scatter b u l y, connect(l l l) msymbol(o none none) yline(0) mcolor(gray) lcolor(gray gray gray) xlabel(-`pre'(1)`post') xscale(r(-`pre'(1)`post')) lpattern(solid dash dash) `figbacks' legend(off) ytitle("ln(SNAP Beneficiaries)") xtitle("Years Since Online Application")
				graph export "$out/evstu_`g'_`pre'_`post'.eps", replace
				restore
				}
		
		

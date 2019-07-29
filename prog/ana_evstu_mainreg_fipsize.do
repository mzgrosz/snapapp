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
	gl dir = "H:\snapapp"
	gl data "${dir}\data"
	gl logs "${dir}\logs"
	gl out "${dir}\output"
	gl out "C:\Users\mgrosz\Documents\GitHub\snapapp\output\tabfig"

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

drop lau_urate
gen lau_urate = lau_unemp*100 / lau_LF


*outcomes
	global outlist snap_p_tot snap_h_tot snap_t bea_snap
	foreach out in $outlist{
		gen ln_`out'=ln(`out')
		}
		
*Identify quartiles of population in first year.
xtile zz =total_pop if onlineapp_ever==1 & year==1997, nq(4)
	bysort fips: egen qua=mean(zz)

/*********************************************************
Create the policy interaction
**********************************************************/
gen ysince=year-onlineapp_min
*choose number of pre- and post-years
local pre=5
local post=3
*create the "loaded" variables for that range
cap drop sample
gen sample=1
	replace sample=0 if onlineapp_min>(2011-`post')
gen onapp_loadpo=0
	local ppo=`post'+1
	forvalues g=`ppo'/9{
		di `g'
		replace onapp_loadpo=1 if onapp_po`g'==1
		}
gen onapp_loadpre=0
	local ppr=`pre'+1
	forvalues g=`ppr'/20{
		replace onapp_loadpr=1 if onapp_pr`g'==1
		}	
qui tab year, gen(yearfe)
*****************
*Regressions
*****************
gen one=1
xtset fips year
preserve
foreach qua in 1 2 3 4{	

	keep if qua==`qua'
	qui tab fips, gen(cty)	
	local numcty=r(r) 
	forvalues i = 1/`numcty' {
		gen ctytrend`i' = (cty`i'==1)*(year-2000) 
		}
	forvalues i=1/56{
		gen statetr`i'=(state_==`i')*(year-2000)
		}	
	xtset fips year
foreach weight in one total_pop{
foreach out in $outlist{
	*year+county FE+county trend
	areg ln_`out' i.year ctytr* onapp_l* onapp_pr1-onapp_pr`pre' onapp_po1-onapp_po`post' l.bea_ui   [weight=`weight'] if onlineapp_ever==1 & year>1996, cluster(fips) absorb(fips)
	mat a=0,0,0
		forvalues y=1/`pre'{
			mat z=-`y',_b[onapp_pr`y'], _se[onapp_pr`y']
			mat a=a\z
			}
		forvalues y=1/`post'{
			mat z=`y',_b[onapp_po`y'], _se[onapp_po`y']
			mat a=a\z
			}
		mat a`qua'`weight'`out'yrcfcttr`pre'`post'=a
		}
		}

****************************************************************************************		
*SPIT OUT GRAPHS
foreach weight in one total_pop{
foreach out in $outlist{
		foreach g in  yrcfcttr {
		clear
		svmat a`qua'`weight'`out'`g'`pre'`post', n(col)
			rename (c1 c2 c3) (y b se)
			gen u=b+1.96*se
			gen l=b-1.96*se
			sort y
			serrbar b se y,  xlabel(-`pre'(1)`post') xscale(r(-`pre'(1)`post')) yline(0,lcolor(black)) lpattern(solid dash dash) `figbacks' legend(off) ytitle("ln(`out')") xtitle("Years Since Online Application")
				graph export "$out/evstu_size`qua'_`out'_`weight'_`g'_`pre'_`post'.eps", replace
				}
				}
				}
		restore, preserve
		}

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


local figbacks "plotregion(fcolor(white)) graphregion(fcolor(white) lwidth(large)) bgcolor(white)"
set scheme s1color
local theusual "replace noconstant nomtitles nonotes noobs nogaps noline nonumbers compress label "


*Graph of online and benefits over time
use "$data/snap_paper_merged.dta", clear
keep if year>1996
gen prgnum_mil=prgnum/1000000
collapse(sum)onlineapp_post prgnum_, by(year)
twoway(scatter online year, c(l) yaxis(2))||(scatter pr year, c(1) yaxis(1)), `figbacks' ytitle("SNAP Beneficiaries (millions)", axis(1)) ytitle("Counties with Online Application", axis(2)) legend(order(2 "SNAP Benecifiaries" 1 "Counties with Online Application"))
	graph export $out/rolloutgraph.eps, replace
	
	
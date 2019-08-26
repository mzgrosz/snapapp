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
	gl out "C:\Users\mgrosz\Documents\GitHub\snapapp\output\tabfig"
}	

local figbacks "plotregion(fcolor(white)) graphregion(fcolor(white) lwidth(large)) bgcolor(white)"
set scheme s1color
local theusual "replace noconstant nomtitles nonotes noobs nogaps noline nonumbers compress label "


*Graph of online and benefits over time
use "$data/snap_paper_merged.dta", clear
keep if year>1989 & year<2017
	replace snap_h_tot=snap_h_tot/100000

bys year: egen snap_cty_online = mean(onlineapp_post)  

collapse(sum) onlineapp_post snap_h_tot bea_snap (first) snap_cty_online, by(year)

twoway(scatter online year, c(l) yaxis(2) msymbol(O))||(scatter snap_h_tot  year, msymbol(Oh) c(1) yaxis(1)), `figbacks' ytitle("SNAP Households (100,000) ", axis(1)) ytitle("Counties with Online Application", axis(2)) legend(order(2 "SNAP Households" 1 "Counties with Online Application"))

graph export $out\rolloutgraph.eps, replace

twoway(scatter snap_cty_online year, c(l) yaxis(2) msymbol(O))||(scatter snap_h_tot  year, msymbol(Oh) c(1) yaxis(1)), `figbacks' ytitle("SNAP Households (100,000) ", axis(1)) ytitle(" Share Counties with Online Application", axis(2)) legend(order(2 "SNAP Households" 1 " Share of Counties with Online Application"))

graph export $out\rolloutgraph_share.eps, replace
	
	
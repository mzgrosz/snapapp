/******************************************
Data creation
*******************************************/
#delimit ; 
set more off ;
include "./config.do" ;


local snapfiles: dir "$rawdat/rawsnap" files "*.xls", respectcase ;
local x=0 ;  
foreach file in `snapfiles' { ; 
	local x = `x' + 1  ;

	import excel "$rawdat/rawsnap/`file'", clear ; 
	gen year = substr("`file'",-8,4) ;
	gen month_str = upper(substr("`file'",1,3)); 
	
	gen fips = substr(A,1,5) ; 
	qui destring B, gen(snap_persons_pa) force ;
	qui destring D, gen(snap_persons_nonpa) force; 
	qui destring H, gen(snap_hh_pa) force ;
	qui destring J, gen(snap_hh_nonpa) force; 
	qui destring N, gen(snap_total_issuance) force ; 
	
	keep fips year month_str snap_* ; 
	drop if real(fips) == . ; 
	list in 1/20 ; 
	tempfile file`x' ;
	save `file`x'', replace; 
	
} ; 
use `file1', clear ; 
forvalues i = 2/`x' { ;
	append using `file`i'' ; 
} ;
gen month = 12 if month_str == "JAN" ;
	replace month = 6 if month_str == "JUL" ;
	drop month_str ; 
	
foreach var in snap_persons_nonpa snap_persons_pa snap_hh_pa snap_hh_nonpa snap_total_issuance { ; 
	replace `var' = 0 if `var' == .  ; 
} ; 

collapse (max) snap_*, by(fips year month);
destring year, replace force ; 
	replace year = year - 1 if month == 12 ; /* reports dated "Jan 1990" are from Dec 1989, etc */
order fips year month ; 
sort fips year month ; 

reshape wide snap_*, i(fips year) j(month) ;

tempfile snap_counts; 
save `snap_counts', replace; 

import delimited "$rawdat/Laus_County.txt", delimiter(tab) clear  ; 

gen fips = substr(series_id,6,5);
gen series = substr(series_id,20,1) ;
destring series, replace force;

drop footnote_codes series_id ;

reshape wide value, i(fips year period) j(series);

rename value4 unemp ; 
rename value5 emp  ;
rename value6 labor_force ; 

gen urate = unemp*100/labor_force ;


collapse (mean) urate = value , by (fips year) ;

tempfile urates ;
save `urates', replace; 

/* save data here */

use "$rawdat/usrace19ages.dta", clear ; 

bys county year: egen total_pop = sum(pop) ;
bys county year: egen total_pop_white = sum(pop*(race==1)) ;
bys county year: egen total_pop_black = sum(pop*(race==2)) ;
bys county year: egen total_pop_male = sum(pop*(sex==1)) ;

bys county year: egen total_pop_0_9 = sum(pop*(age>=0 & age<=2));
bys county year: egen total_pop_10_19 = sum(pop*(age>=3 & age<=4));
bys county year: egen total_pop_20_29 = sum(pop*(age>=5 & age<=6));
bys county year: egen total_pop_30_39 = sum(pop*(age>=7 & age<=8));
bys county year: egen total_pop_40_49 = sum(pop*(age>=9 & age<=10)) ;
bys county year: egen total_pop_50_59 = sum(pop*(age>=11 & age<=12)) ; 
bys county year: egen total_pop_60p = sum(pop*(age>=13)) ;

collapse (first) total_po*, by(county year) ;
rename county fips ; 
/* save data here */
tempfile population ;
save `population', replace; 

use "$rawdat/snap_policy.dta", clear ; 
	
keep state_fips year month oapp ; 

gen internet_app = (oapp > 0 ) ;
	replace internet_app = 0.5 if oapp==2 ; 

collapse (mean) internet_app, by(state_fips year) ; 

tempfile policy ; 
save `policy', replace ; 

/************************************************
Now we are going to merge these data together
*************************************************/

use `population', clear ; 

sort fips year ; 

merge fips year using `snap_counts', _merge(_mergesnap) ;

sort fips year ; 
merge fips year using `urates',  _merge(_mergeurates) ;

gen state_fips = real(substr(fips,1,2)) ;

sort state_fips year ; 

merge state_fips year using `policy', _merge(_mergepolicy) ;

save $rawdat/data_step2.dta, replace; 

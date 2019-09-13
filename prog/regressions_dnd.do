#delimit ; 
clear all;
set more off ;
set maxvar 30000;
set matsize 5000 ;
include "./config.do" ; 

use $rawdat/data_step2.dta, clear ; 

/****************************************
First, setup of control variables
*****************************************/

qui tab fips, gen(cty)	;
local numcty=r(r); 

qui tab year, gen(yy);


forvalues i = 1/`numcty' {;
	gen ctytrend`i' = (cty`i'==1)*(year-2000) ;
};

/**********************************************/

foreach pop in 	0_9 10_19 20_29 30_39 40_49 50_59 60p { ;
	gen share_`pop' = total_pop_`pop'/total_pop ; 
};

gen share_black = total_pop_black/total_pop ;
gen share_male = total_pop_male/total_pop ;


local controls "share_black share_male urate
		share_0_9 share_10_19 share_20_29 share_30_39 share_40_49 share_50_59";

/************************
Tagging relevant sample
*************************/

bys fips: egen onlineapp_ever = max((internet_app>0 & internet_app!=.)) ; 
tab onlineapp_ever ;
/*********************************************
Second, setup of outcome variables 
*****************************************/
gen sample_all = 1 ; 
gen sample_adopters = onlineapp_ever ; 

foreach var of varlist snap* { ; 
	gen log_`var' = log(`var') ;
};

foreach h in all adopters { ; 
	foreach var of varlist snap*12 { ; 
		areg log_`var' internet_app `controls' i.year 
			 if year> 1996 & sample_`h'== 1, 
			cluster(state_fips) absorb(fips); 	
	} ; 
} ; 

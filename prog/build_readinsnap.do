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
}	

*steph local;
if `n' == 5 {
	gl dir = "/Users/srennane/Documents/SSDI_internet"
	gl data "${dir}/data"
	gl logs "${dir}/logs"
	gl graphs "${dir}/graphs"
	gl out "${dir}/output"
	gl zip "${dir}/zipshd"
}








*********************************************************************************
*READ IN FNS DATA
********************************************************************************
cd "$data"
cd "SNAP-FNS388A"

clear
forvalues y=1989/2018{
	import excel "JAN `y'.xls", clear
		keep A B D F H J L N
			foreach g in B D F H J L N{
				destring `g', replace force
				}
			drop if B==. 
			
			rename (B D F H J L N) (snap_p_pub snap_p_npub snap_p_tot snap_h_pub snap_h_npub snap_h_tot snap_t)
			gen year=`y'
			tempfile jan`y'
			save `jan`y'', replace
			}
forvalues y=1989/2017{
	import excel "JUL `y'.xls", clear
		keep A B D F H J L N
			foreach g in B D F H J L N{
				destring `g', replace force
				}
			drop if B==. 
			gen year=`y'+0.5
			rename (B D F H J L N) (snap_p_pub snap_p_npub snap_p_tot snap_h_pub snap_h_npub snap_h_tot snap_t)			
			tempfile jul`y'
			save `jul`y'', replace
			}


*Append years together

clear
forvalues y=1989/2018{
	append using `jan`y''
	}
forvalues y=1989/2017{
	append using `jul`y''									
	}
	
	tab year
	tabstat snap*, by(year)
	
	

*Clean County


gen fips=substr(A,1,5)
	destring fips, replace force
gen state=substr(A,1,2)	
gen type=substr(A,7,1)	
	drop if type=="u"
	tab type

/*Recode independent cities based on http://arf.hrsa.gov/indep.htm*/
replace fips=	24007	if fips==	24510	/*Baltimore City*/	
replace fips=	29191	if fips==	29510	/*St. Louis City*/	
replace fips=	32025	if fips==	32510	/*Carson City*/	
replace fips=	15009	if fips==	15005	/*Kalawao County*/
*VA	
replace fips=	51019	if fips==	51515	/*Bedford City*/	
replace fips=	51119	if fips==	51520	/*Bristol City*/	
replace fips=	51163	if fips==	51530	/*Buena Vista City*/	
replace fips=	51003	if fips==	51540	/*Charlottesville City*/	
replace fips=	51005	if fips==	51560	/*Clifton Forge City*/	
replace fips=	51041	if fips==	51570	/*Colonial Heights City*/	
replace fips=	51005	if fips==	51580	/*Covington City*/	
replace fips=	51143	if fips==	51590	/*Danville City*/	
replace fips=	51081	if fips==	51595	/*Emporia City*/	
replace fips=	51059	if fips==	51600	/*Fairfax City*/	
replace fips=	51059	if fips==	51610	/*Falls Church City*/	
replace fips=	51175	if fips==	51620	/*Franklin City*/	
replace fips=	51177	if fips==	51630	/*Fredericksburg City*/	
replace fips=	51077	if fips==	51640	/*Galax City*/	
replace fips=	51165	if fips==	51660	/*Harrisonburg City*/	
replace fips=	51149	if fips==	51670	/*Hopewell City*/	
replace fips=	51163	if fips==	51678	/*Lexington City*/	
replace fips=	51031	if fips==	51680	/*Lynchburg City*/	
replace fips=	51153	if fips==	51683	/*Manassas City*/	
replace fips=	51153	if fips==	51685	/*Manassas Park City*/	
replace fips=	51089	if fips==	51690	/*Martinsville City*/	
replace fips=	51129	if fips==	51710	/*Norfolk City*/	
replace fips=	51195	if fips==	51720	/*Norton City*/	
replace fips=	51053	if fips==	51730	/*Petersburg City*/	
replace fips=	51199	if fips==	51735	/*Poquoson City*/	
replace fips=	51129	if fips==	51740	/*Portsmouth City*/	
replace fips=	51121	if fips==	51750	/*Radford City*/	
replace fips=	51087	if fips==	51760	/*Richmond City*/	
replace fips=	51161	if fips==	51770	/*Roanoke City*/	
replace fips=	51161	if fips==	51775	/*Salem City*/	
replace fips=	51083	if fips==	51780	/*South Boston City*/	
replace fips=	51015	if fips==	51790	/*Staunton City*/	
replace fips=	51123	if fips==	51800	/*Suffolk City*/	
replace fips=	51015	if fips==	51820	/*Waynesboro City*/	
replace fips=	51095	if fips==	51830	/*Williamsburg City*/	
replace fips=	51069	if fips==	51840	/*Winchester City*/	
						
replace fips=4012 if fips==4029			/*	La Paz County AZ    */
replace fips=8001 if fips==8127         /*Adams County CO       */
replace fips=8005 if fips==8129         /*Arapaho County CO     */
replace fips=8019 if fips==8133         /*Clear Creek County CO */
replace fips=8047 if fips==8137         /*Gilpin County CO      */
replace fips=8049 if fips==8135         /*Grande County CO      */
replace fips=8057 if fips==8139         /*Jackson County CO     */
replace fips=13101 if fips==13100       /*Echols Georgia        */
replace fips=13193 if fips==17012       /*Macon IL              */
replace fips=24005 if fips==24007       /*Baltimore City MD     */
replace fips=27095 if fips==27175       /*Millie Lacs MN        */
replace fips=29186 if fips==29193       /*Ste. Genevieve MO     */
replace fips=29189 if fips==29191       /*St Louis, MO          */
replace fips=32510 if fips==32025       /*Carson County NV      */
replace fips=51800 if fips==51123       /*Suffolk VA            */
	
save $data/fnsdata_clean, replace


*********************************************************************
*READ IN BEA DATA
*********************************************************************
insheet using $data/CA35_1969_2016__ALL_AREAS.csv, clear
forvalues y=8/55{
	local i=`y'+1961
	rename v`y' v`i'
	destring v`i', replace force
	}
	
keep if inlist(linecode,2100, 2210, 2310, 2320, 2330, 2340, 2400)==1	
tempfile doop
save `doop'
forvalues y=1969/2016{
	use `doop', clear
	keep geofips line v`y'
	reshape wide v, i(geofips) j(linecode)
		renpfix v`y' v
		rename (v2100 v2210 v2310 v2320 v2330 v2340 v2400) (bea_retdis bea_medicare bea_ssi bea_eitc bea_snap bea_othinc bea_ui)
		gen year=`y'
		tempfile t`y'
		save `t`y''
		}
clear

forvalues y=1969/2016{
	append using `t`y''
	}

rename geo fips
	drop if substr(fips,5,1)=="0"
	destring fips, replace
/*Recode independent cities based on http://arf.hrsa.gov/indep.htm*/
replace fips=	24007	if fips==	24510	/*Baltimore City*/	
replace fips=	29191	if fips==	29510	/*St. Louis City*/	
replace fips=	32025	if fips==	32510	/*Carson City*/	
replace fips=	15009	if fips==	15005	/*Kalawao County*/
*VA	
replace fips=	51019	if fips==	51515	/*Bedford City*/	
replace fips=	51119	if fips==	51520	/*Bristol City*/	
replace fips=	51163	if fips==	51530	/*Buena Vista City*/	
replace fips=	51003	if fips==	51540	/*Charlottesville City*/	
replace fips=	51005	if fips==	51560	/*Clifton Forge City*/	
replace fips=	51041	if fips==	51570	/*Colonial Heights City*/	
replace fips=	51005	if fips==	51580	/*Covington City*/	
replace fips=	51143	if fips==	51590	/*Danville City*/	
replace fips=	51081	if fips==	51595	/*Emporia City*/	
replace fips=	51059	if fips==	51600	/*Fairfax City*/	
replace fips=	51059	if fips==	51610	/*Falls Church City*/	
replace fips=	51175	if fips==	51620	/*Franklin City*/	
replace fips=	51177	if fips==	51630	/*Fredericksburg City*/	
replace fips=	51077	if fips==	51640	/*Galax City*/	
replace fips=	51165	if fips==	51660	/*Harrisonburg City*/	
replace fips=	51149	if fips==	51670	/*Hopewell City*/	
replace fips=	51163	if fips==	51678	/*Lexington City*/	
replace fips=	51031	if fips==	51680	/*Lynchburg City*/	
replace fips=	51153	if fips==	51683	/*Manassas City*/	
replace fips=	51153	if fips==	51685	/*Manassas Park City*/	
replace fips=	51089	if fips==	51690	/*Martinsville City*/	
replace fips=	51129	if fips==	51710	/*Norfolk City*/	
replace fips=	51195	if fips==	51720	/*Norton City*/	
replace fips=	51053	if fips==	51730	/*Petersburg City*/	
replace fips=	51199	if fips==	51735	/*Poquoson City*/	
replace fips=	51129	if fips==	51740	/*Portsmouth City*/	
replace fips=	51121	if fips==	51750	/*Radford City*/	
replace fips=	51087	if fips==	51760	/*Richmond City*/	
replace fips=	51161	if fips==	51770	/*Roanoke City*/	
replace fips=	51161	if fips==	51775	/*Salem City*/	
replace fips=	51083	if fips==	51780	/*South Boston City*/	
replace fips=	51015	if fips==	51790	/*Staunton City*/	
replace fips=	51123	if fips==	51800	/*Suffolk City*/	
replace fips=	51015	if fips==	51820	/*Waynesboro City*/	
replace fips=	51095	if fips==	51830	/*Williamsburg City*/	
replace fips=	51069	if fips==	51840	/*Winchester City*/	
						
replace fips=4012 if fips==4029			/*	La Paz County AZ    */
replace fips=8001 if fips==8127         /*Adams County CO       */
replace fips=8005 if fips==8129         /*Arapaho County CO     */
replace fips=8019 if fips==8133         /*Clear Creek County CO */
replace fips=8047 if fips==8137         /*Gilpin County CO      */
replace fips=8049 if fips==8135         /*Grande County CO      */
replace fips=8057 if fips==8139         /*Jackson County CO     */
replace fips=13101 if fips==13100       /*Echols Georgia        */
replace fips=13193 if fips==17012       /*Macon IL              */
replace fips=24005 if fips==24007       /*Baltimore City MD     */
replace fips=27095 if fips==27175       /*Millie Lacs MN        */
replace fips=29186 if fips==29193       /*Ste. Genevieve MO     */
replace fips=29189 if fips==29191       /*St Louis, MO          */
replace fips=32510 if fips==32025       /*Carson County NV      */
replace fips=51800 if fips==51123       /*Suffolk VA            */
	save $data/beadata_clean, replace
	
******************************************************************************
*MERGE TOGETHER
******************************************************************************	
	use $data/fnsdata_clean, clear
		*collapse to the fips level
			collapse(sum) snap*, by(fips type year)
		*collapse to the year level (mean)	
			replace year=floor(year)
			collapse(mean) snap*, by(fips year)

	*merge
	merge 1:1 fips year using $data/beadata_clean, gen(_merge)

	*create state
	tostring fips, gen(state)
		replace state="0"+state if length(state)<5
		replace state=substr(state,1,2)


	save $data/snappdata_clean, replace
	
	
	
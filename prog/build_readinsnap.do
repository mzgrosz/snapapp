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

*steph local;
if `n' == 5 {
	gl dir = "/Users/srennane/Documents/SSDI_internet"
	gl data "${dir}/data"
	gl logs "${dir}/logs"
	gl graphs "${dir}/graphs"
	gl out "${dir}/output"
	gl zip "${dir}/zipshd"
}

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

******************************************
*Append years together
********************************************			
clear
forvalues y=1989/2018{
	append using `jan`y''
	}
forvalues y=1989/2017{
	append using `jul`y''									
	}
	
	tab year
	tabstat snap*, by(year)
	
	
*********************************************
*Clean County
*********************************************	

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
	
















	save $data/snappdata_clean, replace
	
	
	
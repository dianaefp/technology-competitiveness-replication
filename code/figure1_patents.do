*************************************************/*

		Figure 1: Projected Patents per Capita
	**-------------------------------------------**

Data files:
	"$data\data_CHN-USA_patents1980-2021.dta"
	"$data\data_CHN-USA_pop1960-2050.dta"
	
***************************************************/


use "$data\data_CHN-USA_patents1990-2024.dta", clear

merge 1:1 id country year using "$data\data_CHN-USA_pop1960-2050.dta"
drop _merge
rename projection projected_pop


/* Uncomment if Needed
* Preeliminary Graph: Trends in Patents Applications by Residents
twoway ///
	(connected patents_res year if country=="USA" & inrange(year,1985,2021), color($myBlue) msize(vsmall)) ///
	(connected patents_res year if country=="China" & inrange(year,1985,2021), color($myRed) msize(vsmall)), ///
	yscale(range() titlegap(*0.5) lw(*0.5)) ///
	ylabel(0(300000)1500000, glcolor(gs6) glw(*0.2) glpat(l) format(%12.0fc) labsize(*0.95)) ///
	xscale(range(1984.5 2021.5) lw(*0.2)) ///
	xlabel(1985(1)2021, nogrid format(%6.0f) labsize(*0.8) angle(90) tlw(*0.45) tlc(gs4)) ///
	xtitle("Year", size(*0.85)) ///
	ytitle("Patent Applications", size(*1)) ///	
	legend(order(1 "USA" 2 "China") ///
	position(12) cols(2) colgap(*8)  ///
	symx(*1) keygap(*.85) region(lcolor(none) color(none) margin(l=0 r+4 t=0)) nobox size(*1.2)) ///
	title("") 	 ///	
	plotregion(lcolor(white) margin(t=1 r=0 l=0 b=0)) ///
	graphregion(color(white) ilcolor(white) margin(l-2 b-2 t=1 r=4)) xsize(10) ysize(5) scale(*1.25)
*/
		
* We will keep only residents patents
drop patents patentsPC	
rename patents_res patents

gen patentsPC=patents / population *1000000
label var patentsPC "Patents per 1,000,000 inhabitants"

/* Uncomment if Needed
** Preeliminary Graph: Total Patent Applications per 100,000 Inhabitants
	twoway  ///
	(line patents_per100k year if country=="USA" & inrange(year,1985,2021), color($myBlue) lw(*1.5)) ///
	(line patents_per100k year if country=="China" & inrange(year,1985,2021), color($myRed) lw(*1.5)), ///
	yscale(range() titlegap(*1.5) lw(*0.5)) ///
	ylabel(, glcolor(gs6) glw(*0.2) glpat(l) format(%12.0fc) labsize(*1)) ///
	xscale(range(1984.5 2021.5) lw(*0.2)) ///
	xlabel(1985(1)2021, nogrid format(%6.0f) labsize(*0.8) angle(90) tlw(*0.45) tlc(gs4)) ///
	xtitle("Year", size(*0.95)) ///
	ytitle("Patents per 100,000 people", size(*1.1)) ///	
	legend(order(1 "USA" 2 "China") ///
	position(12) cols(2) colgap(*10)  ///
	symx(*1) keygap(*.85) region(lcolor(none) color(none) margin(l=0 r-15 t=0)) nobox size(*1.2)) ///
	title("")  ///	
	plotregion(lcolor(white) margin(t=1 r=0 l=0 b=0)) ///
	graphregion(color(white) ilcolor(white) margin(l-2 b-2 t=1 r=4)) xsize(9) ysize(5) scale(*1.15)
*/


** Forecast of log(Patents)
sort id year
keep if year>=1990


** Finding Structural Breaks
preserve
	keep if country=="USA" & inrange(year,1990,2024)
	tsset year
	
	xtbreak test patents year 
	xtbreak estimate patents year, breaks(1)

	mkspline t1 2004 t2 = year
	reg patents t1 t2
	estat ic 
	drop t1 t2	
restore


preserve
	keep if country=="China" & inrange(year,1990,2024)
	tsset year
	
	xtbreak test patents year 

	xtbreak estimate patents year, breaks(2)
	xtbreak estimate patents year, breaks(3)

	mkspline t1 1998 t2 2014 t3 = year
	reg patents t1 t2 t3
	estat ic 
	drop t1 t2 t3	
	
	mkspline t1 1994 t2 2000 t3 2014 t4 = year
	reg patents t1 t2 t3 t4
	estat ic 
	drop t1 t2 t3 t4	
restore

** Forecasting using Structural Breaks
mkspline u1 2004 u2 = year if country=="USA"
reg patents u1 u2 if country=="USA" & inrange(year,2005,2024)
predict xb_usa if country=="USA", xb
label var xb_usa "USA's Predicted Patents"

mkspline c1 1994 c2 2000 c3 2014 c4 = year if country=="China"
reg patents c1 c2 c3 c4 if country=="China" & inrange(year,2015,2024)
predict xb_china if country=="China", xb
label var xb_china "China's Predicted Patents"

* Predicted Patents
gen hat_patents = xb_usa if country=="USA"
replace hat_patents = xb_china if country=="China"
label var hat_patents "Predicted Patents"

* Predicted Patents per 1,000,000 Inhabitants
gen hat_patentsPC=hat_patents / population *1000000
label var hat_patentsPC "Predicted Patents per 1,000,000 Inhabitants"

bys country (year): gen gr_patentsPC=(patentsPC-patentsPC[_n-1])/patentsPC[_n-1] *100
bys country (year): egen avg_gr_patentsPC= mean(gr_patentsPC) if inrange(year,1990,2024)

sum avg_gr_patentsPC if country=="USA"
local avg_usa : display %3.1f `r(mean)'

sum avg_gr_patentsPC if country=="China"
local avg_china : display %3.1f `r(mean)'

sum patents if country=="USA" & year==2021
local pat_usa : display %4.1f `r(mean)'/1000

sum patents if country=="China" & year==2021
local pat_china : display %7.1fc `r(mean)'/1000

** FIGURE 1: Total Patent Applications per 1,000,000 Inhabitants
twoway  ///
	(line patentsPC year if country=="USA" & inrange(year,1990,2024), color($myBlue) lw(*1.5)) ///
	(line patentsPC year if country=="China" & inrange(year,1990,2024), color($myRed) lw(*1.5)) ///
	(line hat_patentsPC year if country=="USA" & inrange(year,2025,2035), color($myBlue) lpat(-#) lw(*1.5)) ///
	(line hat_patentsPC year if country=="China" & inrange(year,2025,2035), color($myRed) lpat(-#) lw(*1.5)),  ///
	yscale(range(0 1800) titlegap(*1.5) lw(*0.5)) ///
	ylabel(0(500)1500, glcolor(gs6) glw(*0.2) glpat(l) format(%12.0fc) labsize(*1)) ///
	xscale(range(1990.5 2035.5) titlegap(*0.5) lw(*0.2)) ///
	xlabel(1990(5)2035, nogrid format(%6.0f) labsize(*1) angle(90) tlw(*0.45) tlc(gs4)) ///
	xtitle("Year", size(*0.9)) ///
	ytitle("Patents per Million Inhabitants", size(*1)) ///	
	legend(order(1 "USA" 2 "China") ///
	position(3) cols(1) rowgap(*3)  ///
	symx(*0.85) keygap(*.5) region(lcolor(black) color(gs15) margin(t=3 b=3 l=2 r=2)) nobox size(*1.1)) ///
	title("") xmtick(##5, tlw(*1) tl(*0.75) tlc(gs6)) ///	
	plotregion(lcolor(white) margin(t=0 r=0 l=0 b=0)) ///
	graphregion(color(white) ilcolor(white) margin(l-2 b-2 t=1 r=0)) xsize(7) ysize(4) scale(*1.1) ///
	text(1720 2005 "{it:Actual}" , size(*1.2) place(n) color(black)) ///
	text(1720 2030 "{it:Projected}" , size(*1.2) place(n) color(black)) ///
	note("Sources: WIPO & World Bank", margin(l-20) size(*0.85)) ///
	xline(2024.5, lpat(.) lcolor(gs6)) ///
	text(560 1996 "Average Growth", size(*0.5) place(n) color(gs1)) ///
	text(250 2017 "Average Growth", size(*0.5) place(n) color(gs1)) ///
	text(690 1995.75 "{bf:+ `avg_usa'%}", size(*1.4) place(c)  color($myBlue)) ///
	text(380 2016.5 "{bf:+ `avg_china'%}", size(*1.4) place(c) color($myRed))
		graph export "$output/patentsPerCapita1990-2035_CHN-USA.png", as(png) replace width(1400) height(800)

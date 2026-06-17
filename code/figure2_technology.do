************************************/*

		Patents by technology
	**-------------------------**

Source: OECD Data

	STRUCTURE_ID: 		OECD.STI.PIE:DSD_PATENTS@DF_PATENTS(1.0)	
	STRUCTURE_NAME: 	Patents by technology	
	ACTION:				I (Inventor)
	PATENT_AUTHORITIES: IP5 patent family	
	FREQUENCY:			Annual
	MEASURE:			Patent families
	UNIT_MEASURE:		Sets of patents
	DATE_TYPE:			Priority date
	AGENT_ROLE: 		Applicant
	TIME_PERIOD:		2000-2023
	
*************************************/

**# Importing Data 
import delimited "$raw_data\OECD_Patents_Inventor.csv", varnames(1) clear

foreach v of varlist _all {
    capture assert `v' == `v'[1]
    if _rc == 0 drop `v'
}

drop referencearea wipo
rename worldintellectualpropertyorganiz wipo

**# Grouping by Technology
gen others=(!inlist(wipo,"Digital communication","Computer technology","Electrical machinery, apparatus, energy","Semiconductors","Audio-visual technology","Biotechnology","Pharmaceuticals"))
replace wipo="_Others" if others==1
replace wipo="Electrical machinery" if wipo=="Electrical machinery, apparatus, energy"

replace wipo="digital" 		if wipo=="Digital communication"
replace wipo="technology" 	if wipo=="Computer technology"
replace wipo="technology" 	if wipo=="Audio-visual technology"
replace wipo="electrical" 	if wipo=="Electrical machinery"
replace wipo="semicond" 	if wipo=="Semiconductors"
replace wipo="biomed" 		if wipo=="Biotechnology"
replace wipo="biomed" 		if wipo=="Pharmaceuticals"
replace wipo="others" 		if wipo=="_Others"

**# Reshaping to Aggregate by Technology
collapse (sum) obs_value , by(ref_area wipo time_period)

rename time_period year
rename obs_value fam_

egen id=group(ref_area year)

reshape wide fam_, i(id) j(wipo) string
drop id

rename fam_* *

gen country=ref_area if ref_area=="USA"
replace country="China" if ref_area=="CHN"
replace country="World" if ref_area=="W"
drop ref_area

**# Reshaping to Panel by Country and Year
reshape wide digital technology electrical semicond biomed others, i(year) j(country) string

rename *China *China
rename *USA *USA
rename *World *World

// Share of China's Industry wrt World
foreach country in China USA {
	foreach x in digital technology electrical semicond biomed others {
		gen wsh_`x'`country'=`x'`country'/`x'World *100
	}
}

// Share of US's Industry wrt World
foreach x in digital technology electrical semicond biomed others {
	rename wsh_`x'China wshChina`x'
	rename wsh_`x'USA wshUSA`x'
}

**# Reshaping to Panel by Industry and Year
reshape long wshChina wshUSA, i(year) j(industry) string

gen wshRest=100-(wshUSA + wshChina)
label var wshChina "China's Industry Worldwide Share"
label var wshUSA "USA's Industry Worldwide Share"
label var wshRest "Rest of the World Industry Worldwide Share"

// Renaming for graph creation
gen wipo=.
replace wipo=1 if industry=="digital"
replace wipo=2 if industry=="technology"
replace wipo=3 if industry=="electrical"
replace wipo=4 if industry=="semicond"
replace wipo=5 if industry=="biomed"
replace wipo=6 if industry=="others"

label define wipo 1 "Communication" 2 "Technologies" 3 "Hardware" 4 "Semiconductors" 5 "Biomedical" 6 "Others", replace
label val wipo wipo


** FIGURE 2 - Panel A: USA and China Worldwide Share by Technology in 2000
***************************************************************************

// Summary Statistics to include in graph
local y=2000
forval w=1/6 {
	sum wshUSA if year==`y' & wipo==`w'
	local wshUSA`w'_`y' : display %3.1f r(mean)
	
	sum wshChina if year==`y' & wipo==`w'
	local wshChina`w'_`y' : display %3.1f r(mean)
}
local w=1
foreach var in digital technology electrical semicond biomed others {
	if inlist(`w',1,4)		local fmt 5
	if inlist(`w',2,3,5)	local fmt 6
	if `w'==6				local fmt 7

	sum `var'World if year==`y'
	local patents`w'_`y' : display %`fmt'.0fc r(mean)
	local ++w
}

// Exporting Figure for 2000
graph hbar wshUSA wshRest wshChina if year==`y', over(wipo) stack ///
bar(1, color($myBlue)) bar(3, color($myRed)) bar(2, color(gs13))  ///
title({bf:`y'}, size(*1)) ///
legend(order(1 "USA" 3 "China" ) ///
position(5) cols(3) colgap(*6.9) ///
symx(*0.5) keygap(*.75) region(lcolor(none) color(none) margin(l=0 r-34 t=0 b=0)) nobox size(*1.2)) ///
plotregion(lcolor(white) margin(t=1 r=0 l=0 b=0)) ///
graphregion(color(white) ilcolor(white) margin(l-5 b=0 t=0 r=8)) xsize(5) ysize(4.5) scale(*1.3) ///
text(7 7  "`wshUSA6_`y''", color(white) size(*0.8)) ///
text(7 25 "`wshUSA5_`y''", color(white) size(*0.8)) ///
text(7 42 "`wshUSA4_`y''", color(white) size(*0.8)) ///
text(7 59 "`wshUSA3_`y''", color(white) size(*0.8)) ///
text(7 76 "`wshUSA2_`y''", color(white) size(*0.8)) ///
text(7 93 "`wshUSA1_`y''", color(white) size(*0.8)) ///
text(95 7  "`wshChina6_`y''", color($myRed) size(*0.8)) ///
text(96.5 25 "`wshChina5_`y''", color(white) size(*0.8)) ///
text(95 42 "`wshChina4_`y''", color($myRed) size(*0.8)) ///
text(94.5 59 "`wshChina3_`y''", color($myRed) size(*0.8)) ///
text(95 76 "`wshChina2_`y''", color($myRed) size(*0.8)) ///
text(95 93 "`wshChina1_`y''", color($myRed) size(*0.8)) ///
text(-3 7  "(N = `patents6_`y'')", color(black) size(*0.6) margin(t=6) placement(w)) ///
text(-3 25 "(N = `patents5_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 42 "(N = `patents4_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 59 "(N = `patents3_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 76 "(N = `patents2_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 93 "(N = `patents1_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
note("Source: OECD", margin(l-26))
	graph export "$output/family_patents_USA-China-Rest`y'.png", as(png) replace width(1000) height(900)

	
** FIGURE 2 - Panel B: USA and China Worldwide Share by Technology in 2022
***************************************************************************

// Summary Statistics to include in graph
local y=2022
forval w=1/6 {
	sum wshUSA if year==`y' & wipo==`w'
	local wshUSA`w'_`y' : display %3.1f r(mean)
	
	sum wshChina if year==`y' & wipo==`w'
	local wshChina`w'_`y' : display %3.1f r(mean)
}
local w=1
foreach var in digital technology electrical semicond biomed others {
	if `w'!=6	local fmt 6
	if `w'==6	local fmt 7

	sum `var'World if year==`y'
	local patents`w'_`y' : display %`fmt'.0fc r(mean)
	local ++w
}

// Exporting Figure for 2022
graph hbar wshUSA wshRest wshChina if year==`y', over(wipo) stack ///
bar(1, color($myBlue)) bar(3, color($myRed)) bar(2, color(gs13))  ///
title({bf:`y'}, size(*1)) ///
legend(order(2 "Rest of the World" ) ///
position(7) cols(3) colgap(*4) ///
symx(*0.5) keygap(*.75) region(lcolor(none) color(none) margin(l-9 r=0 t=0 b=0)) nobox size(*1.2)) ///
plotregion(lcolor(white) margin(t=1 r=0 l=0 b=0)) ///
graphregion(color(white) ilcolor(white) margin(l-6 b=0 t=0 r=9)) xsize(5) ysize(4.5) scale(*1.3) ///
text(7 7  "`wshUSA6_`y''", color(white) size(*0.8)) ///
text(7 25 "`wshUSA5_`y''", color(white) size(*0.8)) ///
text(5 42 "`wshUSA4_`y''", color(white) size(*0.8)) ///
text(5 59 "`wshUSA3_`y''", color(white) size(*0.8)) ///
text(7 76 "`wshUSA2_`y''", color(white) size(*0.8)) ///
text(7 93 "`wshUSA1_`y''", color(white) size(*0.8)) ///
text(94 7  "`wshChina6_`y''", color(white) size(*0.8)) ///
text(94 25 "`wshChina5_`y''", color(white) size(*0.8)) ///
text(94 42 "`wshChina4_`y''", color(white) size(*0.8)) ///
text(94 59 "`wshChina3_`y''", color(white) size(*0.8)) ///
text(94 76 "`wshChina2_`y''", color(white) size(*0.8)) ///
text(94 93 "`wshChina1_`y''", color(white) size(*0.8)) ///
text(-3 7  "(N = `patents6_`y'')", color(black) size(*0.56) margin(t=6) placement(w)) ///
text(-3 25 "(N = `patents5_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 42 "(N = `patents4_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 59 "(N = `patents3_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 76 "(N = `patents2_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
text(-3 93 "(N = `patents1_`y'')", color(black) size(*0.6) margin(t=7) placement(w)) ///
note(" ")
	graph export "$output/family_patents_USA-China-Rest`y'.png", as(png) replace width(1000) height(900)

	
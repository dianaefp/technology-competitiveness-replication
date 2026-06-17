
*************************************************/*

		Table 3: Founder's Financial Capacity 
	**-------------------------------------------**

Source: PitchBook Data, Inc. (2026). PitchBook Platform [Database]. Retrieved June 10, 2026 from \href{https://my.pitchbook.com/}{https://my.pitchbook.com/}.
	
***************************************************/


* Venture Capital Investment by Year
*************************************
import excel "$raw_data\PitchBook_Company_Pivot_Table_2026_06_11.xlsx", sheet("VC Investment") cellrange(B8:I36) clear

drop C
rename B year
rename D company_usa
rename E deal_usa
rename F VC_usa
rename G company_china
rename H deal_china
rename I VC_china

foreach var in * {
	destring `var', force replace
}

keep if inlist(year,2015,2025)
keep year VC_*

replace VC_china = VC_china/1000
replace VC_usa = VC_usa/1000
format VC_* %3.1f

gen id=1
reshape wide VC_usa VC_china, i(id) j(year)
gen temp = "VC Investment ($ billions)"
gen stat = subinstr(temp, "$", char(92) + "$", .)
drop id temp

rename VC_* *
order stat usa2015 usa2025 china2015 china2025

foreach var in usa2015 usa2025 china2015 china2025 {
	tostring `var', replace format("%9.1f") force
	replace `var' = " & " + `var' if "`var'"!="china2025"
	replace `var' = " & " + `var' + " \\\addlinespace" if "`var'"=="china2025"
}

format *20*5 %30s
format stat %55s

tempfile vc_investment
save `vc_investment'

**---------------------------------------------------------------------
**---------------------------------------------------------------------


import excel "$raw_data\PitchBook_Company_Pivot_Table_2026_06_11.xlsx", sheet("Formerly VC 2015") cellrange(B8:G28) clear

rename D usa2015
rename F china2015
rename B stat

keep if stat=="All"
replace stat="Public Formerly VC-backed Firms"
keep stat usa2015 china2015

tempfile formerly2015
save `formerly2015'

**---------------------------------------------------------------------
**---------------------------------------------------------------------

import excel "$raw_data\PitchBook_Company_Pivot_Table_2026_06_11.xlsx", sheet("Formerly VC 2025") cellrange(B8:G38) clear

rename D usa2025
rename F china2025
rename B stat

keep if stat=="All"
replace stat="Public Formerly VC-backed Firms"
keep stat usa2025 china2025

merge 1:1 stat using `formerly2015'
drop _merge

order stat usa2015 usa2025 china2015 china2025

foreach var in usa2015 usa2025 china2015 china2025 {
	destring `var', replace
	tostring `var', force gen(temp) format(%5.0fc)
	drop `var'
	
	gen `var'= " & " + temp if "`var'"!="china2025"
	replace `var' = " & " + temp + " \\\addlinespace" if "`var'"=="china2025"
	drop temp
}

format *20*5 %30s
format stat %55s

tempfile formerlyVC
save `formerlyVC'

**---------------------------------------------------------------------
**---------------------------------------------------------------------
import excel "$raw_data\PitchBook_Company_Pivot_Table_2026_06_11.xlsx", sheet("Unicorns2015") cellrange(B8:G18) clear

rename D usa2015
rename F china2015
rename B stat

keep if stat=="All"
replace stat="Unicorns"
keep stat usa2015 china2015

tempfile unicorns2015
save `unicorns2015'

**---------------------------------------------------------------------
**---------------------------------------------------------------------

import excel "$raw_data\PitchBook_Company_Pivot_Table_2026_06_11.xlsx", sheet("Unicorns2025") cellrange(B8:G28) clear

rename D usa2025
rename F china2025
rename B stat

keep if stat=="All"
replace stat="Unicorns"
keep stat usa2025 china2025

merge 1:1 stat using `unicorns2015'
drop _merge

order stat usa2015 usa2025 china2015 china2025

foreach var in usa2015 usa2025 china2015 china2025 {
	replace `var' = " & " + `var' if "`var'"!="china2025"
	replace `var' = " & " + `var' + " \\\addlinespace" if "`var'"=="china2025"
}

format *20*5 %30s
format stat %55s

tempfile unicorns
save `unicorns'

**---------------------------------------------------------------------
**---------------------------------------------------------------------

use `vc_investment', clear
append using `unicorns'
append using `formerlyVC'

label var usa2015 "USA 2015"
label var usa2025 "USA 2025" 
label var china2015 "China 2015" 
label var china2025 "China 2025"
	
gen b=_n+2

insobs 2
replace b=(_n-3) if b==.
sort b

replace usa2015=" & \multicolumn{2}{c}{\textbf{USA}}" 	 if b==1 
replace china2015=" & \multicolumn{2}{c}{\textbf{China}}" if b==1  
replace china2025=" \\\cmidrule{2-3}\cmidrule{4-5}" 	 if b==1 

replace usa2015=" & \textbf{2015}" 								if b==2 
replace usa2025=" & \textbf{2025}" 								if b==2 
replace china2015=" & \textbf{2015}"								if b==2  
replace china2025=" & \textbf{2025} \\\midrule\addlinespace" 	if b==2 
drop b

format stat usa2015 %36s
format china2015 %37s
format usa2025 %16s
format china2025 %42s


outfile using "$output/table1_financialCapacity2015-2025.tex", noquote wide replace



************************************/*

		Patent applications
	**-------------------------**

Source: https://www3.wipo.int/ipstats/ips-search/countryprofiles

World Intellectual Property Organization
Patent -- Resident applications per million inhabitants

*************************************/


*Import Patents data
**********************
import delimited "$raw_data\countryprofiles_1 - Country profiles_Total count by applicant's origin_1980_2024.csv", varnames(7) clear

local year=1980
forval v=5/49 {
	rename v`v' y`year'
	local year=`year'+1
}

gen country="USA" if origincode=="US"
replace country="China" if origincode=="CN"

drop office origincode origin 

replace statistics="Patent applications" if statistics=="1.1 - Patent - Total patent applications"
replace statistics="Patent Resident applications per million inhabitants" if statistics=="1.2 - Patent - Resident applications per million inhabitants"

keep if inlist(statistics,"Patent applications","Patent Resident applications per million inhabitants")
order country statistics y*

egen id=group(country statistics)

reshape long y, i(id) j(year)
drop id

gen j="patents" if statistics=="Patent applications"
replace j="patentsPC" if statistics=="Patent Resident applications per million inhabitants"
drop statistics 

egen id=group(country year)

reshape wide y, i(id) j(j) string
drop id

gen id=1 if country=="USA" 
replace id=2 if country=="China"

rename ypatents* patents*

order id country year patents patentsPC
format patents* %12.0fc

merge 1:1 id country year using "$data\data_CHN-USA_pop1960-2050.dta"
keep if _merge==3
drop _merge

gen patents_res=patentsPC/1000000*population
format patents* %12.0fc
keep if year>=1990
		
save "$data\data_CHN-USA_patents1990-2024.dta", replace

************************************/*

		1. Population, total
	**-------------------------**

Source: https://databank.worldbank.org/

Data from database: Population estimates and projections
Last Updated: 04/27/2026

*************************************/

import delimited "$raw_data\5c765473-c639-4658-9ccd-82483891a58d_Data.csv", varnames(1) clear

drop if seriescode==""

format yr* %15.0fc

keep if seriescode=="SP.POP.TOTL"

gen country="USA" if countrycode=="USA"
replace country="China" if countryname=="China"

gen id=1 if countrycode=="USA"
replace id=2 if countrycode=="CHN"

drop series* countrycode countryname
order id country 
sort id 

reshape long yr, i(id) j(year)

rename yr population
order id country year population

gen projection=(inrange(year,2025,2050))

label var projection "Projected Population"
label var population "Total Population"
label var country "Country"
label var year "Year"

xtset id year

gen pop_growth = ((population - L.population) / L.population)*100
label var pop_growth "Population Growth (%)"

save "$data\data_CHN-USA_pop1960-2050.dta", replace

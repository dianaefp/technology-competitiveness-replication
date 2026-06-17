/***************************************************************
		
				Cardinal 40
			-------------------
		 Economic Technical Assignment
		*******************************

		Date: June, 2026
		
****************************************************************/

set more off
clear all
set maxvar  20000

** DIRECTORY

// Set your location
global diana=1

* Diana
if $diana==1 global userdir "C:\Users\Diana\...\GitHub"

global raw_data 	"$userdir/raw_data"
global dofiles 		"$userdir/code" 
global data 		"$userdir/data"
global output 		"$userdir/output"

********************************************************************************************************************
********************************************************************************************************************

** PREAMBLE

// Define colors for figures 
global myBlue "#3D65A5"
global myRed "#F05039"

// Confirm installation of these packages
ssc install xtbreak, replace

********************************************************************************************************************
********************************************************************************************************************
	
*****************
* 	Exhibit 1	*
*****************

// Importing Data from 2 sources
do "$dofiles/data_import_population.do"
do "$dofiles/data_import_patents.do"

// Generates figure "We estimated Bai-Perron breakpoints and projected the last regime."
do "$dofiles/figure1_patents.do"

*---------------------------------------------
*---------------------------------------------
*---------------------------------------------

*****************
* 	Exhibit 2	*		
*****************

// Imports Data from 1 source & Generates figure
do "$dofiles/figure2_technology.do"

*---------------------------------------------
*---------------------------------------------
*---------------------------------------------

*****************
* 	Exhibit 3	*		
*****************

// Imports Data from 5 data downloads from 1 single source
// Generates .tex table to import in Latex
do "$dofiles/table3_financial.do"



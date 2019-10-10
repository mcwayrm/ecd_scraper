//**********	Systematic Review Duplicates

clear all
local home "C:\Users\Ryry\Dropbox\Ryan_Intern\ECD_Meta"

/*
	Check duplicates in databases, agencies, and in grey literature
	Mark internal duplicates, remove
	Check duplicates across databases, agencies, and in grey literature
	Mark external duplicates, remove
	Save 
*/

// Within Duplicates (for each source in each category)

	// Databases
import delimited using "`home'\edit\database_master.csv", clear
foreach database in pubmed scopus econlit econstor webscience educationsource psychinfo worldbank econpapers agecon repec{
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = 0
				replace int_dup = 1 if dup != 0
				drop dup
			}
		}
		// crosstab of source and # of internal duplications
tab source int_dup
drop if int_dup == 1
	// Organizations and Agencies
import delimited using "`home'\edit\orgs_master.csv", clear
foreach database in usaid africanbank asianbank americanbank savechildren oxfam jpal ipa brac{
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = 0
				replace int_dup = 1 if dup != 0
			}
		}
		// crosstab of source and # of internal duplications
tab source int_dup
drop if int_dup == 1
	// Grey Literature
import delimited using "`home'\edit\grey_master.csv", clear
foreach database in opengrey proquest{
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = 0
				replace int_dup = 1 if dup != 0
			}
		}
	// crosstab of source and # of internal duplications
tab source int_dup
drop if int_dup == 1
	
// Merge together

import delimited using "`home'\edit\database_master.csv", clear
append using "`home'\edit\orgs_master.csv", force
append using "`home'\edit\grey_master.csv", force

//	Duplicates between
duplicates tag new_title, gen(dup)
gen ext_dup = 0
replace ext_dup = 1 if dup != 0
tab source ext_dup
drop if ext_dup == 1

// Rejection by Year
gen year_filter = 0
replace year_filter = 1 if year < 2000
tab source year_filter
drop if year_filter == 1

// Save

drop new_title dup ext_dup year_filter
sort source combo year
export delimited using "`home'\edit\review_master.csv", replace

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
		pubmed 
		ebsco 
		econlit
		econstor 
		webscience 
		educationsource 
		psychinfo 
		nber 
		worldbank
		econpapers
		agecon
		repec
		import delimited using "`home'\database_master.csv", clear
		foreach database in {
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = .
				replace int_dup = 1 if dup != 0
				drop dup
			}
		}
	// Organizations and Agencies
		usaid
		unicef
		africanbank
		asianbank
		americanbank
		savechildren
		brac
		import delimited using "`home'\orgs_master.csv", clear
		foreach database in {
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = .
				replace int_dup = 1 if dup != 0
			}
		}
	// Grey Literature
		cochrane
		google
		googlescholar
		microsoft
		opengrey
		worldcat
		proquest
		import delimited using "`home'\grey_master.csv", clear
		foreach database in {
			if database == "`database'"{
				duplicates tag new_title, gen(dup)
				gen int_dup = .
				replace int_dup = 1 if dup != 0
			}
		}
	// crosstab of source and # of internal duplications
	tab source int_dup
	drop if int_dup == 1
	
// Merge together

import delimited using "`home'\database_master.csv", clear
append using "`home'\orgs_master.csv", force
append using "`home'\grey_master.csv", force

//	Duplicates between
duplicates tag new_title, gen(dup)
gen ext_dup = .
replace ext_dup = 1 if dup != 0
tab source ext_dup
drop if ext_dup == 1

// Rejection by Year

// Save

drop new_title dup ext_dup
sort source combo year
export delimited using "`home'\review_master.csv", replace

//**********	Systematic Review Duplicates

clear all
//local home "C:\Users\Ryry\Dropbox\Ryan_Intern\ECD_Meta"
local home "C:\Users\bnguyen17\Desktop\ECD_META"
/*
	Check duplicates in databases, agencies, and in grey literature
	Mark internal duplicates, remove
	Check duplicates across databases, agencies, and in grey literature
	Mark external duplicates, remove
	Save 
*/

// Within Duplicates

import delimited using "`home'\`database'_master.csv", clear
		if source == "`database'"{
			duplicates tag new_title, gen(title_int_dup)
			gen int_dup = 0
			replace int_dup = 1 if title_int_dup > 0
			count if ext_dup > 0 // Number of Internal duplicates
			gsort - year + new_title
			egen title_int_group = group(new_title)
			collapse (firstnm) [all the variabels expect title], by(title_int_group)
			sum int_dup
			count if int_dup > 0 // Double Check we got all the duplicates
			* TODO: get rid of the extra duplicates here
			drop title_int_dup int_dup title_int_group
		}

// Merge the Databases

use "`home'\africanbank\africanbank_master.dta", clear

foreach database of local agecon americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience {
	append using "`home'\`database'\`database'_master.dta"
}

//	Duplicates between Databases
duplicates tag new_title, gen(title_ext_dup)
gen ext_dup = 0
replace ext_dup = 1 if title_ext_dup > 0
count if ext_dup > 0 // Number of External duplicates
gsort - year + new_title
egen title_ext_group = group(new_title)
collapse (firstnm) [all the variabels expect title], by(title_ext_group)
sum ext_dup
count if ext_dup > 0 // Double Check we got all the duplicates
* TODO: get rid of the extra duplicates here
drop title_ext_dup ext_dup title_ext_group

// Save

drop new_title
foreach i in yes_no_title yes_no_abstract reject_code_title reject_code_abstract{
	gen `i' = ""
}

order source combo year yes_no_title reject_code_title title new_title yes_no_abstract reject_code_abstract abstract authors journal url doi 

sort source combo year
export delimited using "`home'\database_master.csv", replace

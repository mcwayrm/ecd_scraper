//**********	Systematic Review Duplicates

clear all
local home "C:\Users\Ryry\Google Drive\ECD_META"
// local home "C:\Users\bnguyen17\Desktop\ECD_META"
/*
	Check duplicates in databases, agencies, and in grey literature
	Mark internal duplicates, remove
	Check duplicates across databases, agencies, and in grey literature
	Mark external duplicates, remove
	Save 
*/

// Within Duplicates

local database_1 africanbank agecon americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience worldbank

// Changed from new_title to title. Can switch back later. Just thinking it maybe too restrictive with new_title
foreach database of local database_1{
			use "`home'\edit\\`database'_master.dta", clear
			di "`database'"
			duplicates tag title, gen(title_int_dup)
			gen int_dup = 0
			replace int_dup = 1 if title_int_dup > 0
			count if int_dup > 0 // Number of Internal duplicates
			tostring year, replace
			gsort - year + title
			egen title_int_group = group(title)
			collapse (firstnm) combo year title abstract authors url doi journal new_title source title_int_dup int_dup, by(title_int_group)
			sum int_dup
			count if int_dup > 0 // Double Check we got all the duplicates
			* TODO: get rid of the extra duplicates here
			drop title_int_dup int_dup title_int_group
			save "`home'\edit\\`database'_clean_master.dta", replace
		}

// Merge the Databases


use "`home'\edit\africanbank_clean_master.dta", clear

local database_list_2 agecon americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience worldbank

foreach database of local database_list_2 {
	append using "`home'\edit\\`database'_clean_master.dta"
}


//	Duplicates between Databases
duplicates tag new_title, gen(title_ext_dup)
gen ext_dup = 0
replace ext_dup = 1 if title_ext_dup > 0
count if ext_dup > 0 // Number of External duplicates
gsort - year + new_title
egen title_ext_group = group(new_title)
collapse (firstnm) combo year title abstract authors url doi journal new_title source title_ext_dup ext_dup, by(title_ext_group)
sum ext_dup
count if ext_dup > 0 // Double Check we got all the duplicates
* TODO: get rid of the extra duplicates here
drop title_ext_dup ext_dup title_ext_group

// Save

drop new_title
foreach i in yes_no_title yes_no_abstract reject_code_title reject_code_abstract{
	gen `i' = ""
}

order source combo year yes_no_title reject_code_title title yes_no_abstract reject_code_abstract abstract authors journal url doi 

sort source combo year
export delimited using "`home'\database_clean_master.csv", replace

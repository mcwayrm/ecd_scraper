//**********	Systematic Review structure merge for databases

clear all
local home "C:\Users\Ryry\Google Drive\ECD_META\"

/*
Steps:
1. set up nested loop for databases
2. loop for .csv to .dta
3. loop to append
4. export as .csv to be added to search tracker for reviewer 1 and 2 tabs
- what needs to happen is that you save in the style of these path directories. So long as it is universal this will run, and you can do all the master .csv after you have all the database combo pulls at the very end. If you want to do just 1 database, pull out the first forloop and change `database' to the name of the database.
*/



/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Dropping World Bank and BRAC for now until they are fixed
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

local database_list_1 agecon africanbank americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience

foreach database of local database_list_1{

	foreach combo in C1 C2 C3 C4 C5{
		import delimited using "`home'\\`database'\\`combo'.csv", clear
		
*merge 1:1 KEY using "`home'\`database'\`combo'.txt" if `database' == "pubmed" // need to know ones that need to merge abstracts and also how to reshape abstracts, will need to transpose them before this loop I believe or maybe if statment here

		if "`database'" == "africanbank" | "`database'" == "agecon" | `database' == "americanbank" | `database' == "asianbank" | `database' == "brac" | `database' == "econpapers" | `database' == "econstor" | `database' == "ideas_repec" | `database' == "ipa" | `database' == "jpal" | `database' == "oxfam"{
			rename (year title abstract authors journal doi) (year title abstract authors journal doi)
		}
		else if `database' == "econlit" | `database' == "educationsource"{
			collapse (firstnm) year atl ab au3 jtl ui url, by(resultID)
			rename (atl ab au3 jtl ui) (title abstract authors journal doi)
		}
		else if `database' == "psychinfo"{
			collapse (firstnm) year atl ab au7 jtl ui url, by(resultID)
			rename (atl ab au7 jtl ui) (title abstract authors journal doi)
		}
		else if `database' == "opengrey"{
			rename (Year Title Abstract Author) (year title abstract authors)
		}
		else if `database' == "proquest"{
			split elecPubDate, parse('-') gen(date)
			rename (date1 Title Abstract Authors digitalObjectIdentifier URL) (year title abstract authors doi url)
		}
		else if `database' == "savechildren"{
			rename (Year Title Abstract Authors Link) (year title abstract authors url)
		}
		else if `database' == "scopus"{
			rename (Year Title Abstract Authors 'Source title' DOI Link) (year title abstract authors journal doi url)
		}
		else if `database' == "usaid"{
			rename (Year Title Abstract Authors Link Journal DOI) (year title abstract authors url journal doi)		
		}
		else if `database' == "webscience"{
			rename (PY Title Abstract Author Journal) (year title abstract authors journal)	
		}
		else if `database' == "worldbank"{
			split publish_date, parse('-') gen(date)
			rename (summary link date1 author) (abstract url year authors)
		}
		
		split(title), p(" ") gen(parts)
		egen new_title = concat(parts*)
		replace new_title = strlower(new_title)
		drop parts*
		foreach x in "`" "~" "!" "@" "#" "$" "%" "^" "&" "*" "(" ")" "-" "_" "+" "=" "{" "}" "[" "]" "|" "\" ";" ":" "'" "," "<" "." ">" "/" "?" `"""'{
			replace new_title = subinstr(new_title, `"`x'"', "", .)
		}
		gen combo = "`combo'"
		order combo
		rename (ïyear) (year)
		keep year title abstract authors journal url doi new_title 
		save "`home'\\`database'\\`combo'.dta", replace
	}

	use "`home'\\`database'\\C1.dta", clear

	foreach combo in C2 C3 C4 C5{
		append using "`home'\\`database'\\`combo'.dta", force
	}

	gen source = "`database'"

	export delimited using "`home'\\`database'\\`database'_master.csv", replace
	save "`home'\\`database'\\`database'_master.dta", replace
}

use "`home'\africanbank\africanbank_master.dta", clear

local database_list_2 "agecon americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience"

foreach database of local database_list_2 {
	append using "`home'\`database'\`database'_master.dta"
}

foreach i in yes_no_title yes_no_abstract reject_code_title reject_code_abstract{
	gen `i' = ""
}

order source combo year yes_no_title reject_code_title title new_title yes_no_abstract reject_code_abstract abstract authors journal url doi 
export delimited using "`home'\database_master.csv", replace

clear all
local home "C:\Users\Ryry\Google Drive\ECD_META"
import delimited using "`home'\\agecon\\C1.csv", clear
// rename (year link) (year url)
rename (ïyear) (year)
rename (year title abstract authors journal doi link) (year title abstract authors journal doi url)
split(title), p(" ") gen(parts)
egen new_title = concat(parts*)
replace new_title = strlower(new_title)
drop parts*
// foreach x in "`" "~" "!" "@" "#" "$" "%" "^" "&" "*" "(" ")" "-" "_" "+" "=" "{" "}" "[" "]" "|" "\" ";" ":" "'" "," "<" "." ">" "/" "?" `"""'{
// replace new_title = subinstr(new_title, `"`x'"', "", .)
// }
gen combo = "`combo'"
order combo
keep year title abstract authors journal url doi new_title 
save "`home'\\`database'\\`combo'.dta", replace



gen x



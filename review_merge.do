//**********	Systematic Review structure merge for databases

clear all
local home "C:\Users\Ryry\Dropbox\Ryan_Intern\ECD_Meta"

/*
Steps:
1. set up nested loop for databases
2. loop for .csv to .dta
3. loop to append
4. export as .csv to be added to search tracker for reviewer 1 and 2 tabs
- what needs to happen is that you save in the style of these path directories. So long as it is universal this will run, and you can do all the master .csv after you have all the database combo pulls at the very end. If you want to do just 1 database, pull out the first forloop and change `database' to the name of the database.
*/

foreach database in pubmed scopus ebsco econlit econstor webscience educationsource psychinfo nber worldbank econpapers agecon repec{

	foreach combo in C1 C2 C3 C4 C5{
		import delimited using "`home'\`database'\`combo'.csv", clear
		merge 1:1 KEY using "`home'\`database'\`combo'.txt" if `database' == "pubmed" // need to know ones that need to merge abstracts and also how to reshape abstracts, will need to transpose them before this loop I believe or maybe if statment here
		if `database' == "pubmed" | `database' == "econstar"{
			rename (<year> <title> <abstract> <authors> <journal>) (year title abstract authors journal)
		}
		else if `database' == "ebsco"{
			rename (<year> <title> <abstract> <authors> <journal>) (year title abstract authors journal)
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
		save "`home'\`database'\`combo'.dta", replace
	}

	use "`home'\`database'\C1.dta", clear

	foreach combo in C2 C3 C4 C5{
		append using "`home'\`database'\`combo'.dta", force
	}

	gen source = "`database'"

	export delimited using "`home'\`database'\`database'_master.csv", replace
}

foreach database in pubmed scopus ebsco econlit econstor webscience educationsource psychinfo nber worldbank econpapers agecon repec{
	import delimited using "`home'\`database'\`database'_master.csv", clear
	save "`home'\`database'\`database'_master.dta", replace
}

use "`home'\pubmed\pubmed_master.dta", clear

foreach database in scopus ebsco econlit econstor webscience educationsource psychinfo nber worldbank econpapers agecon repec{
	append using "`home'\`database'\`database'_master.dta"
}

foreach i in yes_no_title yes_no_abstract reject_code_title reject_code_abstract{
	gen `i' = ""
}

order source combo year yes_no_title reject_code_title title yes_no_abstract reject_code_abstract abstract authors journal
export delimited using "`home'\database_master.csv", replace

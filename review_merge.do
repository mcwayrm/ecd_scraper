//**********	Systematic Review structure merge for databases

clear all
local home "C:\Users\Ryry\Google Drive\ECD_META\"
// local home "C:\Users\whattywhat\Desktop\ECD_META"

/*
Steps:
1. set up nested loop for databases
2. loop for .csv to .dta
3. loop to append
4. export as .csv to be added to search tracker for reviewer 1 and 2 tabs
- what needs to happen is that you save in the style of these path directories. So long as it is universal this will run, and you can do all the master .csv after you have all the database combo pulls at the very end. If you want to do just 1 database, pull out the first forloop and change `database' to the name of the database.
*/



/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Dropping BRAC for now, add later
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

local database_1 africanbank agecon americanbank asianbank econlit econpapers econstor educationsource ideas_repec ipa jpal opengrey oxfam proquest psychinfo savechildren scopus usaid webscience worldbank

foreach database of local database_1{
	
	foreach combo in C1 C2 C3 C4 C5{
		import excel using "`home'\\`database'\\`combo'.xlsx", firstrow clear
		*merge 1:1 KEY using "`home'\`database'\`combo'.txt" if `database' == "pubmed" // need to know ones that need to merge abstracts and also how to reshape abstracts, will need to transpose them before this loop I believe or maybe if statment here
		
		if "`database'" == "agecon" | "`database'" == "africanbank"| "`database'" == "asianbank" | "`database'" == "brac" | "`database'" == "econpapers" | "`database'" == "econstor" | "`database'" == "ipa" | "`database'" == "jpal" | "`database'" == "oxfam"{
			rename (Year Title Abstract Authors Link DOI Journal) (year title abstract authors url doi journal)
			tostring year title abstract authors url doi journal, replace 
		}
		else if "`database'" == "ideas_repec"{
			rename (Year Title Abstract Authors Link DOI Journal) (year title abstract authors url doi journal)
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "americanbank"{
			rename (Year Title Abstract Authors Link DOI) (year title abstract authors url doi)
			gen journal = "americanbank"
			tostring year title abstract authors url doi journal, replace 
		}
		else if "`database'" == "econlit" | "`database'" == "educationsource"{
			// Checks if using au2/au3/au4/au5 then replaces au with these values
			local vlist au2 au3 au4 au5
			foreach var of local vlist {
				capture confirm variable `var'
				if(_rc == 0) {
					replace au = `var' if !missing(`var')
				}
			}
			collapse (firstnm) year atl ab au jtl ui url, by(resultID)
			rename (atl ab au jtl) (title abstract authors journal)
			gen doi = ""
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "psychinfo"{
			collapse (firstnm) year atl ab au7 jtl ui url, by(resultID)
			rename (atl ab au7 jtl ui) (title abstract authors journal doi)
			tostring year title abstract authors url doi journal, replace 
		}
		else if "`database'" == "opengrey"{
			rename (Year Title Abstract Author) (year title abstract authors)
			gen journal = "opengrey"
			gen url = ""
			gen doi = ""
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "proquest"{
			foreach var in URL{
				capture confirm variable `var'
				if(_rc != 0) {
					gen url = ""
					rename(Title Abstract Authors Database) (title abstract authors journal)
				}
				else {
					rename(Title Abstract Authors URL Database) (title abstract authors url journal)
				}
			}
			gen doi = ""
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "savechildren"{
			rename(Year Title Abstract Authors Link) (year title abstract authors url)
			gen doi = ""
			gen journal = "savechildren"
			tostring title abstract authors url doi journal, replace
			destring year, replace
		}
		else if "`database'" == "scopus"{
			rename (Year Title Authors Source Link DOI) (year title authors journal url doi)
			foreach var in abstract {
				capture confirm variable `var'
				if(_rc != 0) {
					gen abstract =.
				}
			}
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "usaid"{
			rename (Year Title Abstract Authors Link DOI Journal) (year title abstract authors url doi journal)
			tostring title abstract authors url doi journal, replace
			destring year, replace
		}
		else if "`database'" == "webscience"{
			
			local vlist Abstract AB
			foreach var of local vlist {
				capture confirm variable `var'
				if(_rc == 0){
					label variable `var' Abstract
					rename `var' abstract
				}
}
			rename (Title PY Author DI Journal) (title year authors doi journal)
			gen url = ""
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		else if "`database'" == "worldbank"{
			tostring publish_date, replace
			split publish_date, parse('-') gen(date)
			rename (summary link publish_date author) (abstract url year authors)
			gen journal = "worldbank"
			gen doi = ""
			tostring title abstract authors url doi journal, replace 
			destring year, replace
		}
		
		describe
		capture confirm string variable title
		if (r(N) >= 1 & !_rc){
			split(title), p(" ") gen(parts)
			egen new_title = concat(parts*)
			replace new_title = strlower(new_title)
			drop parts*
			// Can't figure out how to check for quotation marks 
			// "Too few quotes" error
// 			local test "~ ! @ # $ % ^ & * ( ) - _ + = { } [ ] | \ ; : ' , < . > / ? ' `"
// 			foreach x of local test {
// 				replace new_title = subinstr(new_title, `"`x'"', "", .)
// 			}

			gen combo = "`combo'"
			order combo
			keep year title abstract authors journal url doi new_title combo
			save "`home'\\`database'\\`combo'.dta", replace
		}
		else {	
			gen combo = "`combo'"
			order combo
			keep year title abstract authors journal url doi combo
			save "`home'\\`database'\\`combo'.dta", replace
		}
	}

	use "`home'\`database'\C1.dta", clear

	foreach combo in C2 C3 C4 C5{
		append using "`home'\`database'\\`combo'.dta", force
	}

	gen source = "`database'"

	export delimited using "`home'\edit\`database'_master.csv", replace
	save "`home'\\edit\\`database'_master.dta", replace
}

//----------------------------------------------------------------------------
//
// clear all
// local home "C:\Users\whattywhat\Desktop\ECD_META"
// import excel using "`home'\worldbank\C1.xlsx", firstrow
//
//
// local vlist Abstract AB
// foreach var of local vlist {
// 	capture confirm variable `var'
// 	if(_rc == 0){
// 		label variable `var' Abstract
// 		rename `var' abstract
// 	}
// }

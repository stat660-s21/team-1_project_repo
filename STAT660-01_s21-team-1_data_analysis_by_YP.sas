*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/*
create macro variable with path to directory where this file is located,
enabling relative imports
*/
%let path=%sysfunc(tranwrd(%sysget(SAS_EXECFILEPATH),%sysget(SAS_EXECFILENAME),));

/*
execute data-prep file, which will generate final analytic dataset used to
answer the research questions below
*/
%include "&path.STAT660-01_s21-team-1_data_preparation.sas";


*******************************************************************************;
* Research Question 1 Analysis Startinqg Point;
*******************************************************************************;
/*
Question 1 of 3: How do rates of homeless students and rates of ESL learners 
interact in California at the School level? 
Rationale: This should help us understand which regions in the state are in 
greater need of resources earmarked for various social programs.
Notes: 
This compares the columns EL_Rate and Homeless_Rate in the by_school_analytic
file. 
Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file. 
*/

title1 justify=left
'Question 1 of 3: How do rates of homeless students and rates of ESL learners interact in California schools?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

title3 justify=left
"This table shows rates of chronic absenteeism among homeless students, English learners, and for the total population in 4886 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=by_school_analytic noobs;
    var cdscode EL_Rate Homeless_Rate;
run;
options obs=max;

title;
footnote;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: How does the rate of ESL learners affect chronic absenteeism 
rates in California schools?
Rationale: This information will further help to identify regions in greater 
need of funding from the state.  
Notes: 
This compares the columns EL_Rate and ChronicAbsentee_Rate in the 
by_school_analytic file. 
Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file. 
*/

title1 justify=left
'Question 2 of 3: How does the rate of ESL learners in a County affect chronic absenteeism rates in California schools?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

title3 justify=left
"This table shows rates of chronic absenteeism among English learners and for the total population in 4886 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=by_school_analytic noobs;
    var cdscode EL_Rate ChronicAbsentee_Rate;
run;
options obs=max;

title;
footnote;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: How does the relative proportion of FEP students to EL 
students affect the rate of chronic absenteesim in California schools? 
Rationale: This question would attempt to assess the relative rates of 
abenteeism between English Learners, and those who have successfully learned 
English. This knowledge would help us understand whether successful ESL programs
are effective in lowering absenteeism.    
Note: 
This compares the columns FEPtoELratio and ChronicAbsentee_Rate in the 
by_school_analytic file. 
Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file.  
*/

/*Print table*/
title1 justify=left
'Question 3 of 3: How does the relative proportion of FEP students to EL students affect the rate of chronic absenteesim in California schools?'
;

title2 justify=left
'Rationale: This question would attempt to assess the relative rates of abenteeism between English Learners, and those who have successfully learned English. This information would help us understand whether successful ESL programs are effective in lowering chronic absenteeism.'
;

title3 justify=left
"This table contains count and rate information for EL and FEP students as well as chronic absenteeism rates for 4886 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=by_school_analytic noobs;
    var cdscode FEPtoELratio ChronicAbsentee_Rate;
run;
options obs=max;

title;
footnote;

proc contents data=by_school_analytic; 
run; 

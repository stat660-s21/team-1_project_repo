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
This compares the column "Repoting category" from chronicabsenteeism19 
to the column "LC" in the "elsch19" file. 
Changed question to address Counties instead of Districts since that will 
be more accessible with these datasets.
Changed Question again to address schools since it's now possible.  

Limitations: Edited (4/24): this question can actually be addressed using only 
the chronic_abs_analytic file: 

Need to summarize data: 

Chronic_abs_analytic
(cdscode & reportingcat=SE)
/
(cdscode & reportingcat=TA) 
= 
School ESL rate 

(cdscode & reportingcat=SH)
/
(cdscode & reportingcat=TA) 
= 
School homeless rate 
*/

/*
From the Chronicabsenteeism_analytic data set, I need to look at the number of 
homeless students in each County. To that end, I will create another dataset 
called homeless_absentees which includes only the homeless students. 
*/ 
data homeless_absentees;
    set Chronic_abs_analytic;
    where ReportingCategory = "SH";
run;
data esl_absentees;
    set Chronic_abs_analytic;
    where ReportingCategory = "SE";
run;

data absentees_temp;
    merge esl_absentees (rename=(ChronicAbsenteeismRate=eslabsenteerate))
        homeless_absentees (rename=(ChronicAbsenteeismRate=homelessabsenteerate));
    by cdscode;
run; 

data absentees_temp; 
    set absentees_temp; 
    ;
    where
        not(missing(eslabsenteerate))
        and
        not(missing(homelessabsenteerate))     
    ;
run;





 























title1 justify=left
'Question 1 of 3: How do rates of homeless students and rates of ESL learners interact in California at the County level?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

footnote1 justify=left
"I still need to understand how to merge these tables into one dataset with just the county totals."
;

/* 
This code creates a table for each county summarizing the number of homeless
students 
*/
title3 justify=left
'This first set of tables summarizes homelessness within Counties.'
;

proc sort data=homeless_absentees out=temp; 
    by CountyName;
run;
proc print data=temp;
    var CumulativeEnrollment;
    sum CumulativeEnrollment; 
    by CountyName; 
run;

/* 
This creates tables for each county summarizing the total number of students. 
*/
title3 justify=left
'This set of tables summarizes total enrollment within Counties.'
;

proc sort data=Chronicabsenteeism_analytic out=temp; 
    by CountyName;
run;
proc print data=temp;
    var CumulativeEnrollment;
    sum CumulativeEnrollment; 
    by CountyName; 
run;

/* 
The last set of tables here looks at the number of ESL students in each County
*/
title3 justify=left
'This set of tables summarizes total number of ESL students within Counties.'
;

proc sort data=elsch19_raw_analytic out=temp; 
    by COUNTY;
run;
proc print data=temp;
    var TOTAL_EL;
    sum TOTAL_EL; 
    by COUNTY; 
run;

title;
footnote;









options obs=10;
proc print data=Chronicabsenteeism_analytic; 
run; 
options obs=max;  












*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

/*
Question 2 of 3: How does the rate of ESL learners affect chronic absenteeism 
rates in California schools?

Rationale: This information will further help to identify regions in greater 
need of funding from the state.  

Notes: 
This compares the column "LC" in the "elsch19" file to the 
column "Chronic Absenteeism Rate" in the "chronicabsenteeism19" datafile.
Changed question to address Counties instead of Districts since that will be 
more accessible with these datasets.
Changed Question again to address schools since it's now possible.  

Limitations: In the files "elsch19", missing values and zeros should be omitted 
from the LC column since they are potentially missing values. The same is true 
for missing information in the CHRONICABSENTEEISMRATE column of the 
"chronicabsenteeism19" dataset. 

Need: 

Chronic_abs_analytic:
(cdscode & reportingcat=SE)
/
(cdscode & reportingcat=TA) 
= 
School ESL rate

cdscode & reportingcat=TA: need column: chronicabsenteeismrate
*/

title1 justify=left
'Question 2 of 3: How does the rate of ESL learners in a County affect chronic absenteeism rates in California schools?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

footnote1 justify=left
"As before, I need to understand how to merge these tables into one dataset with just the county totals."
;

/*
This creates tables for each county summarizing chronic absenteeism.
*/
title3 justify=left
'These tables summarize Chronic Absenteeism within Counties.'
;

proc sort data=Chronicabsenteeism_analytic out=temp; 
    by CountyName;
run;
proc print data=temp;
    var ChronicAbsenteeismCount;
    sum ChronicAbsenteeismCount; 
    by CountyName; 
run;

/*
These tables show the total enrollment for each county.  
*/
title3 justify=left
'These tables summarize Total Enrollment within Counties.'
;

proc sort data=Chronicabsenteeism_analytic out=temp; 
    by CountyName;
run;
proc print data=temp;
    var CumulativeEnrollment;
    sum CumulativeEnrollment; 
    by CountyName; 
run;

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
This compares the column "LC" in the "elsch19" and "fepsch19" files to the 
column "Chronic Absenteeism Rate" in the "chronicabsenteeism19" datafile.
Changed question to address Counties instead of Districts since that will be 
more accessible with these datasets.
Changed Question again to address schools since it's now possible.

Limitations: In the files "elsch19" and "fepsch19", missing values and zeros 
should be omitted from the LC column since they are potentially missing values. 
The same is true for missing information in the CHRONICABSENTEEISMRATE column of
the "chronicabsenteeism19" dataset.  

need: 
proportion of FEP students 
proportion of EL students 
chronic absenteesim rate   
*/

title1 justify=left
'Question 3 of 3: How does the relative proportion of FEP students to EL students affect the rate of chronic absenteesim in California schools?'
;

title2 justify=left
'Rationale: This question would attempt to assess the relative rates of abenteeism between English Learners, and those who have successfully learned English. This information would help us understand whether successful ESL programs are effective in lowering chronic absenteeism.'
;

footnote1 justify=left
"."
;

/* 
Create a set of tables to look at the number of FEP students in each County
*/
title3 justify=left
'These tables summarize the FEP students within Counties.'
;


/* 
Create a set of tables to look at the number of ESL students in each County
*/
title3 justify=left
'These tables summarize the ES students within Counties.'
;


/* 
Create a set of tables to look at chronic absenteeism in each County
*/
title3 justify=left
'These tables summarize chronic absenteeism within Counties.'
;


title;
footnote;










data one; 
input var1$ var2$; 
cards; 
1 2 
2 3 
3 5
; 
run; 

data two; 
input var1$ var3$; 
cards; 
1 3 
2 5 
4 6 
;
run; 

data onetwo;
merge one (rename=(var2=ball)) 
    two; 
by var1; 
run; 

proc print data=onetwo; 
run;  

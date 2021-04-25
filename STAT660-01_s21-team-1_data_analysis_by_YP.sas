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
*/

/*
Here I create a single dataset with all of the information needed to address
this question. The file it outputs contains only the cdscode, rate of chronic
absenteeism among English learners, rate of absenteeism among homeless students,
and rates of absenteeism among the entire school population.  
*/ 
data homeless_absentees;
    set Chronic_abs_analytic;
    where ReportingCategory = "SH";
data esl_absentees;
    set Chronic_abs_analytic;
    where ReportingCategory = "SE";
data tot_absentees;
    set Chronic_abs_analytic;
    where ReportingCategory = "TA";
data absentees_temp;
    merge 
        esl_absentees (rename=(ChronicAbsenteeismRate=ESLAbsenteeRate))
        homeless_absentees (rename=(ChronicAbsenteeismRate=HomelessAbsenteeRate))
        tot_absentees (rename=(ChronicAbsenteeismRate=TotalAbsenteeRate))
    ;
    by cdscode;
run; 

data absentees_analytic; 
    set absentees_temp; 
    ;
    where
        not(missing(ESLAbsenteeRate))
        and
        not(missing(HomelessAbsenteeRate))
        and 
        not(missing(TotalAbsenteeRate))
        and
        ESLAbsenteeRate^="*" 
        and 
        HomelessAbsenteeRate^="*"
        and 
        TotalAbsenteeRate^="*"
    ;
    drop 
        ReportingCategory
        CumulativeEnrollment
        ChronicAbsenteeismCount
        CountyName
    ;       
run;

title1 justify=left
'Question 1 of 3: How do rates of homeless students and rates of ESL learners interact in California schools?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

title3 justify=left
"This table shows rates of chronic absenteeism among homeless students, English learners, and for the total population in 4736 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=absentees_analytic;
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
This compares the column "LC" in the "elsch19" file to the 
column "Chronic Absenteeism Rate" in the "chronicabsenteeism19" datafile.
Changed question to address Counties instead of Districts since that will be 
more accessible with these datasets.
Changed Question again to address schools since it's now possible.  

Limitations: In the files "elsch19", missing values and zeros should be omitted 
from the LC column since they are potentially missing values. The same is true 
for missing information in the CHRONICABSENTEEISMRATE column of the 
"chronicabsenteeism19" dataset. 
*/

title1 justify=left
'Question 2 of 3: How does the rate of ESL learners in a County affect chronic absenteeism rates in California schools?'
;

title2 justify=left
'Rationale: This should help us understand which regions in the state are in greater need of resources earmarked for various social programs.'
;

title3 justify=left
"This table shows rates of chronic absenteeism among English learners and for the total population in 4736 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=absentees_analytic;
    var cdscode ESLAbsenteeRate TotalAbsenteeRate;
run;
options obs=max;

title;
footnote;

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
*/

/*
This code sums the count of FEP and EL students within cdscodes. The result is 
a dataset with one row for each cdscode containing the sums of the values of 
interest.
*/
data FEPEL_counts(drop=COUNTY LC LANGUAGE TOTAL_EL TOTAL_FEP);
    set fepel_analytic; 
    by cdscode;
    if First.cdscode then EL_Count=0;
    EL_Count + Total_EL;
    if Last.cdscode;
    if First.cdscode then FEP_Count=0;
    FEP_Count + Total_FEP;
    if Last.cdscode;
run;

/*
This chunk of code gets information from the chronic absenteeism analytic file
and stores it in a temporary file.
*/
data chronic_abs_count(keep=cdscode ChronicAbsenteeismCount CumulativeEnrollment); 
    set chronic_abs_analytic; 
    where
        reportingcategory="TA";
run;

/* This code chunk merges the temporary files created in the last two steps. */
data fepel_abs_analytic;
    merge 
        FEPEL_counts
        chronic_abs_count
    ;
    by
        cdscode
    ;
run;

/* Here I drop rows with missing values.*/
data fepel_abs_analytic; 
    set fepel_abs_analytic; 
    ;
    where
        not(missing(EL_Count))
        and
        not(missing(FEP_Count))
        and 
        not(missing(CumulativeEnrollment))
        and 
        not(missing(ChronicAbsenteeismCount))
        and 
        CumulativeEnrollment^="*"
        and 
        ChronicAbsenteeismCount^="*"
    ;
run;

/* Calculate rate columns. */
data fepel_abs_analytic; 
    set fepel_abs_analytic;
    EL_Rate=EL_Count/CumulativeEnrollment;
    FEP_Rate=FEP_Count/CumulativeEnrollment;
    ChronicAbsenteeismRate=ChronicAbsenteeismCount/CumulativeEnrollment;
run; 

/*Print table*/
title1 justify=left
'Question 3 of 3: How does the relative proportion of FEP students to EL students affect the rate of chronic absenteesim in California schools?'
;

title2 justify=left
'Rationale: This question would attempt to assess the relative rates of abenteeism between English Learners, and those who have successfully learned English. This information would help us understand whether successful ESL programs are effective in lowering chronic absenteeism.'
;

title3 justify=left
"This table contains count and rate information for EL and FEP students as well as chronic absenteeism rates for 9850 California schools."
;

footnote1 justify=left
"This should be the only file I need to carry out this analysis."
;

options obs=10;
proc print data=fepel_abs_analytic;
run; 
options obs=max;

title;
footnote;

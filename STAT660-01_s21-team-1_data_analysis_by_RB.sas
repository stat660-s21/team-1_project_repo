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
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: What are the main language spoken by English learners (EL) and 
Fluent-English-Proficient (FEP) students in different schools? Can we find 
anything interesting among them? 

Rationale: To take a look at the percentage of different languages, which would 
help school gain culture diversity. And to see if some type of native languages 
will have positive influence on the students’ English proficiency.

Note: This compares the column “Language”, “School” from elsch19 to the 
column of the same name from fepsch19.

Limitations: Values of "Language" and "School" equal to zero or empty should be 
excluded from this analysis, since they are potentially missing data values.
*/

proc means data=Whole_School_analytic;
        value chrabs_rate

run;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: If English learners with different language will have various
Chronic Absenteeism Rate? 

Rationale: This would help inform whether native languages are associated with 
Chronic Absenteeism Rate.

Note: This compares the column "Language" from elsch19 to the column “Chronic 
Absenteeism Rate” from chronicabsenteeism19.

Limitations: Values of "Language" and "Chronic Absenteeism Rate" equal to zero 
or empty should be excluded from this analysis, since they are potentially 
missing data values. And only values of "AggregateLevel" eaqul to "S" should be 
included in this analysis, since these rows contain SchoolName information.
*/

/* Build analytic dataset from raw datasets imported above including only 
the columns and minimal data-cleaning/transforamtion needed to address this
research queation/objective.*/
proc format;
    value chrabs
	    0-<30='0-30'
        30-<70='30-70'
		70-100='70-100'
	;
run;

title "Correlation Analysis for Chronic Absenteeism Rate and Languages of English Learners";
proc freq data=Whole_School_analytic;
    table chrabs_rate language_EL;
	format chrabs_rate chrabs.;
run;
title;

proc sql;
    create table EL_Chrabs_count_analytic as
	    select chrabs_rate format chrabs., language_EL
        from Whole_School_analytic
        where 
            chrabs_rate is not null 
	        and
            language_EL is not null
		group by chrabs_rate, language_EL
        order by chrabs_rate, language_EL;
run;

proc freq data=EL_Chrabs_count_analytic;
    table language_EL;
	
run;


proc sort data=Whole_School_analytic out=EL_Chrabs_analytic;
    format chrabs_rate chrabs.;
	where 
        not(missing(chrabs_rate))
	    and
        not(missing(language_EL))
	;
	by chrabs_rate language_EL;
run;

data EL_Chrabs_count_analytic;
    set EL_Chrabs_analytic;
    count+1;
	by chrabs_rate language_EL;
	if first.language_EL then count=1;
run;

proc sql;
    create table EL_Chrabs_max_analytic as
	    select distinct language_EL, chrabs_rate, max(count) as count
		from EL_Chrabs_count_analytic
	group by chrabs_rate, language_EL
	
	order by chrabs_rate, count desc
	;
quit;

proc print data=EL_Chrabs_count_analytic(obs=500);
 format chrabs_rate chrabs.;
run;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a relationship between the type of students (classified 
by their English level) with the Chronic Absenteeism Rate?

Rationale: This would help identify if students’ English level will determine 
their Chronic Absenteeism Rate.

Note: This compares the column “EO”, “IFEP”, “EL”, “RFEP”, “TBD” 
from ELAS/LTEL/AT-Risk Data to the column “Chronic Absenteeism Rate” from 
chronicabsenteeism19.

Limitations: Values of “EO”, “IFEP”, “EL”, “RFEP”, “TBD” and 
"Chronic Absenteeism Rate" equal to zero or empty should be excluded from this 
analysis, since they are potentially missing data values. And only values of 
"AggLEvel" and "AggregateLevel" eaqul to "S" should be included in this analysis, 
since these rows contain SchoolName information.
*/

/* Build analytic dataset from raw datasets imported above including only 
the columns and minimal data-cleaning/transforamtion needed to address this
research queation/objective.*/
proc sql;
    create table Chrabsrate_ELAS_analytic as
	    select 
            coalesce(S.cdscode, C.cdscode)
			as CDSCode,
            S.EO as EO_num
            label"Total Number of EO",
            S.IFEP as IFEP_num
            label"Total Number of IFEP", 
            S.EL as EL_num 
			label"Total Number of EL",
            S.RFEP as RFEP_num
			label"Total Number of RFEP",
            S.TBD as TBD_num
			label"Total Number of TBD",
			C.chrabsrate as chrabs_rate
			label"Chronic Absenteeism Rate"
		from 
            ELAS_analytic as S
			full join
            Chrabs_rate_analytic as C
            on S.cdscode=C.cdscode
        order by cdscode
	;
quit;
proc print data=Chrabsrate_ELAS_analytic(obs=10);
run;


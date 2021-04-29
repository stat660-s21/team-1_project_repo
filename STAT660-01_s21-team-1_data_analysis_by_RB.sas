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
proc sql;
    create table fep_el_analytic_1 as
	    select 
            coalesce(E.cdscode, F.cdscode)
			as CDSCode,
            coalesce(E.lc, F.lc)
			as LC
            label "Language Identification Code",,
			E.language as language_EL 
            label "Language Name Spoken by the Most EL",
			E.totalnum as total_EL 
            label "Total Number of EL Speaking that Selected Language",
			F.language as language_FEP 
            label "Language spoken by the most FEP",
			F.totalnum as total_FEP
            label "Total Number of FEP Speaking that Selected Language",
		from elsch_analytic as E
		    full join
            fepsch_analytic as F
			on E.cdscode=F.cdscode
        order by CDSCode
	;
quit;


/* Build analytic dataset from raw datasets imported above including only the 
columns and minimal data-cleaning/transforamtion needed to address the first
queation/objective.*/
proc sql;
    create table fep_el_analytic_2 as
	    select cdscode, lc, language, max(total_el) as totalnum_EL,
               max(total) as totalnum_FEP
		from fepel_analytic
		group by cdscode
		having total_el=totalnum_EL | total=totalnum_FEP
        order by cdscode;
quit;

/* 
Check fep_el_analytic2 for bad unique id values, where the column cdscode
is intended to be a primary key.

After executing this data step, the resulting dataset is emptywe, meaning
that full joins used above didn't introduce duplicates in the 
fep_el_analytic2. So we can do further proceeding.
*/
data fep_el_analytic_2_bad_ids;
    set fep_el_analytic_2;
	by cdscode;
	if
        first.cdscode * last.cddscode = 0
        or
        missing(cdscode)
        or
        substr(cdscode,8,7) in ("00000000", "0000001")
	then
	    do;
		    output;
		end;
run;
proc sort
        nodupkey
        data=fep_el_analytic_2
        dupout=fep_el_analytic_2_dups
    ;
    by
		cdscode
    ;
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
proc sql;
    create table el_chrabsrate_analytic as
	    select 
            coalesce(E.cdscode, C.cdscode)
			as CDSCode,
			E.language as language_EL 
            label"Language Spoken by the Most EL",
			E.totalnum as total_EL 
            label"Total Number of EL Speaking that Selected Language",
			C.chrabsrate as chrabs_rate
			label"Chronic Absenteeism Rate"
		    from elsch_analytic as E
		    full join
            Chrabs_rate_analytic as C
            on E.cdscode=C.cdscode
        order by cdscode
	;
quit;


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


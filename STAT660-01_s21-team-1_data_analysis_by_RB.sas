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
    create table abc as
	    select cds, school
		from elsch19_raw_analytic
		group by cds
        order by cds;
quit;
proc print data=elsch19_raw_analytic(obs=50); 
    format cds 14.;
run;
proc sql;
    create table elsch19_anakytic as
	    select cds, county, district, school, language, max(total_el) as total
		from elsch19_raw_analytic
		group by cds
		having total_el=total
        order by cds;
quit;
proc print data=elsch19_analytic(obs=20); 
    format cds 14.;
run;
proc sql;
    create table elsch19_fepsch19_raw AS
        select coalesce(E.SCHOOL, F.SCHOOL), E.LANGUAGE AS LANGUAGE_EL, E.TOTAL_EL, 
              F.LANGUAGE AS LANGUAGE_FEP, F.TOTAL AS TOTAL_FEP
        from elsch19_raw_analytic AS E full join fepsch19_analytic AS F
        on E.SCHOOL=F.SCHOOL
        group by SCHOOL;
quit;
title "All Languages spkoen by EL and FEP in Different Schools";
proc print data=elsch19_fepsch19_raw(obs=5); 
run;
title;

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

proc sql;
   create table chronicabsenteeism_filter AS
       select SchoolName AS SCHOOL, 
              avg(ChronicAbsenteeismRate) AS Average_ChronicAbsenteeismRate 
       from chronicabsenteeism_analytic
       group by SCHOOL
       order by SCHOOL;
quit;
proc sql;
   create table elsch19_chronicabsenteeism_raw AS
       select coalesce(E.SCHOOL, C.SCHOOL), E.LANGUAGE AS LANGUAGE_EL, E.TOTAL_EL, 
              C.Average_ChronicAbsenteeismRate
       from elsch19_raw_analytic AS E full join chronicabsenteeism_filter AS C
       on E.SCHOOL=C.SCHOOL;
quit;
title "Language Information of EL and Their Chronic Absenteeism Rate";
proc print data=elsch19_chronicabsenteeism_raw(obs=5); 
run;
title;

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
proc sql;
   create table ELASatrisk_filter AS
       select SchoolName AS SCHOOL, 
              EO,IFEP,EL,RFEP,TBD
       from ELASatrisk_analytic
       group by SCHOOL
       order by SCHOOL;
quit;
proc sql;
   create table ELASatrisk_chroabsent_raw AS
       select coalesce(S.SCHOOL, C.SCHOOL), EO,IFEP,EL,RFEP,TBD, 
              C.Average_ChronicAbsenteeismRate
       from ELASatrisk_filter AS S full join chronicabsenteeism_filter AS C
       on S.SCHOOL=C.SCHOOL;
quit;
title "Students Type and Their Chronic Absenteeism Rate in Each School";
proc print data=ELASatrisk_chroabsent_raw(obs=10); 
run;
title;

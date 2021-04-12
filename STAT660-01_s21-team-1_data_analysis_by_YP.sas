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
Question 1 of 3: How do rates of homeless students and rates of ESL learners 
interact in California school districts? 

Rationale: This should help us understand which segments of society are in 
greater need of resources earmarked for learning English as a seond language.

Note: This compares the column "Repoting category" from chronicabsenteeism19 
to the column "LC" in the "elsch19" and "fepsch19" files.

Limitations: In the files "elsch19" and "fepsch19", missing values and zeros 
should be omitted from the LC columns since they are potentially missing values. 
The same is true for missing information in the REPORTINGCATEGORY column of the 
"chronicabsenteeism19" dataset.   
*/

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

/*
Question 2 of 3: How does the primary language spoken affect chronic 
absenteeism among California primary and secondary schools?

Rationale: This information will further help to identify districts in greater 
need of funding from the state.  

Note: This compares the column "LC" in the "elsch19" file to the 
column "Chronic Absenteeism Rate" in the "chronicabsenteeism19" datafile. 


Limitations: In the files "elsch19" and "fepsch19", missing values and zeros 
should be omitted from the LC column since they are potentially missing values. 
The same is true for missing information in the CHRONICABSENTEEISMRATE column of the 
"chronicabsenteeism19" dataset.  
*/

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: How does the relative proportion of FEP students to EL 
students affect the rate of chronic absenteesim in California schools? 

Rationale: This question would attempt to assess the relative rates of 
abenteeism between English Learners, and those who have successfully learned 
English. This knowledge would help us understand whether ESL programs are 
effective in lowering absenteeism.    

Note: This compares the column "LC" in the "elsch19" and "fepsch19" files to the 
column "Chronic Absenteeism Rate" in the "chronicabsenteeism19" datafile.

Limitations: In the files "elsch19" and "fepsch19", missing values and zeros 
should be omitted from the LC column since they are potentially missing values. 
The same is true for missing information in the CHRONICABSENTEEISMRATE column of the 
"chronicabsenteeism19" dataset.  
*/

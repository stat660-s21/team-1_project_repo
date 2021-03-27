*******************************************************************************;
*******************************************************************************;



/*
[Dataset 1 Name] elsch19

[Dataset Description] English Learners by Grade and Language, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 62,911   

[Number of Features] 21

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=EL&cPage=fileselsch

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fselsch.asp

[Unique ID Schema] The column CDS is a unique id.

***

[Dataset 2 Name] fepsch19

[Dataset Description] Fluent-English Proficient Students by Grade and Language,
AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 76,171

[Number of Features] 21

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=FEP&cPage=filesfepsch

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesfepsch.asp

[Unique ID Schema] The column CDS is a unique id.

***

[Dataset 3 Name] ELAS/LTEL/AT-Risk Data

[Dataset Description] Enrollment by ELAS, LTEL, and At-Risk by Grade, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 210,816

[Number of Features] 24

[Data Source] http://dq.cde.ca.gov/dataquest/longtermel/lteldnld.aspx?year=2018-19

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesltel.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School Code"
form a composite key, which together are equivalent to the unique id column CDS
in dataset fepsch19 and dataset elsch19.

***

[Dataset 4 Name] chronicabsenteeism19

[Dataset Description] Chronic Absenteeism Data, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 239,810

[Number of Features] 14

[Data Source] https://www3.cde.ca.gov/demo-downloads/attendance/chrabs1819.txt

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesabd.asp

[Unique ID Schema] The columns "County Code", "District Code", and "School Code"
form a composite key, which together are equivalent to the unique id column CDS 
in dataset elsch19 and dataset fepsch19.

*/


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


filename csvFile 
	url "https://github.com/stat660/team-1_project_repo/raw/main/data/fepsch19.csv";

proc import datafile=csvFile 
	out=fep replace dbms=csv; 
run;

filename csvFile 
	url "https://github.com/stat660/team-1_project_repo/raw/main/data/elsch19.csv";

proc import datafile=csvFile 
	out=els replace dbms=csv; 
run;

filename csvFile 
	url "https://github.com/stat660/team-1_project_repo/raw/main/data/chronicabsenteeism.csv";

proc import datafile=csvFile 
	out=ch_abs replace dbms=csv; 
run;

filename csvFile 
	url "https://github.com/stat660/team-1_project_repo/raw/main/data/ELASatrisk.csv";

proc import datafile=csvFile 
	out=elas replace dbms=csv; 
run;

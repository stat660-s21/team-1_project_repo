*******************************************************************************;
******************** Project analysis *****************************************; 
******************** Data Preparation *****************************************;
*******************************************************************************;

/* 
[Dataset 1 Name] elsch19

[Dataset Description] English Learners by Grade and Language, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 62,911   
                  
[Number of Features] 21

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=EL&cPage=fileselsch

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fselsch.asp

[Unique ID Schema] The columns COUNTY, DISTRICT, SCHOOL, and LANGUAGE form a 
composite key. 
*/

%let inputDataset1DSN = elsch19_raw;
%let inputDataset1URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/elsch19.csv
;
%let inputDataset1Type = CSV;

/*
[Dataset 2 Name] fepsch19

[Dataset Description] Fluent-English Proficient Students by Grade and Language, 
AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 76,171
                    
[Number of Features] 21

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=FEP&cPage=filesfepsch

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesfepsch.asp

[Unique ID Schema] The columns COUNTY, DISTRICT, SCHOOL, and LANGUAGE form a 
composite key. 
*/

%let inputDataset2DSN = fepsch19_raw;
%let inputDataset2URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/fepsch19.csv
;
%let inputDataset2Type = CSV;

/*
[Dataset 3 Name] ELAS/LTEL/AT-Risk Data

[Dataset Description] Enrollment by ELAS, LTEL, and At-Risk by Grade, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 210,816
                    
[Number of Features] 24

[Data Source] 
http://dq.cde.ca.gov/dataquest/longtermel/lteldnld.aspx?year=2018-19

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesltel.asp

[Unique ID Schema] The columns COUNTYCODE, DISTRICTCODE, SCHOOLCODE, GRADE and 
GENDER form a composite key, which together are equivalent to the unique id 
column CDS in dataset fepsch19 and dataset elsch19 but also incorporate 
demographic information.
*/

%let inputDataset3DSN = ELASatrisk_raw;
%let inputDataset3URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/ELASatrisk.csv
;
%let inputDataset3Type = CSV;

/*
[Dataset 4 Name] chronicabsenteeism19

[Dataset Description] Chronic Absenteeism Data, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 239,810
                    
[Number of Features] 14

[Data Source] https://www3.cde.ca.gov/demo-downloads/attendance/chrabs1819.txt

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/filesabd.asp

[Unique ID Schema] The columns COUNTYCODE, DISTRICTCODE, SCHOOLCODE, and 
REPORTINGCATEGORY form a composite key, which together are equivalent to the 
unique id column CDS in dataset fepsch19 and dataset elsch19 but also 
incorporate demographic information.
*/

%let inputDataset4DSN = chronicabsenteeism_raw;
%let inputDataset4URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/chronicabsenteeism.csv
;
%let inputDataset4Type = CSV;

/* load raw datasets over the wire, if they don't already exist */
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                    method="get"
                    url="&url."
                    out=tempfile
                ;
            run;
            proc import
                    file=tempfile
                    out=&dsn.
                    dbms=&filetype.
                ;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 4;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets

/* 
This code checks the elsch19_raw dataset for missing key values and removes 
them. For elsch19_raw, the column SCHOOL is a primary key, so any rows 
corresponding to multiple values should be removed. In addition, rows should
be removed if they are missing values for SCHOOL.

But we cannot remove directly duplicates of SCHOOL from the original table, 
because each school name corresponds to multiple languages and we want to 
keep the language with the highest total.

After running the proc sort and proc sql steps below, the new dataset 
elsch19_analytic will have no duplicate/repeated unique id values, and all 
unique id values will corresond to our experimental units of interests, 
which are California Schools. This means the column SCHOOL in 
elsch19_analytic is guranteed to be a primary key.
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=elsch19_raw
        dupout=elsch19_raw_dups
        out=elsch19_raw_analytic
    ;
    where
        /* remove rows with missing composite key components */
		not(missing(COUNTY))
		and
		not(missing(DISTRICT))
		and
		not(missing(SCHOOL))
		and
		not(missing(LANGUAGE))
    ;
    by
		COUNTY
		DISTRICT
		SCHOOL
		LANGUAGE
    ;
run;
proc sql;
    create table elsch19_analytic as
	    select county, school, language, max(total_el) as totalnum
		from elsch19_raw_analytic
		group by school
		having total_el=totalnum
        order by school;
quit;
title "First Twenty Rows of 'elsch19_analytic' Table";
proc print data=elsch19_analytic(obs=20);
run;
title;

/* 
This code checks the fepsch19_raw dataset for missing key values and removes 
them. For fepsch19_raw, the column SCHOOL is a primary key, so any rows 
corresponding to multiple values should be removed. In addition, rows should
be removed if they are missing values for SCHOOL.

But we cannot remove directly duplicates of SCHOOL from the original table, 
because each school name corresponds to multiple languages and we want to 
keep the language with the highest total.

After running the proc sort and proc sql steps below, the new dataset 
fepsch19_analytic will have no duplicate/repeated unique id values, and all 
unique id values will corresond to our experimental units of interests, 
which are California Schools. This means the column SCHOOL in 
fepsch19_analytic is guranteed to be a primary key.
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=fepsch19_raw
        dupout=fepsch19_raw_dups
        out=fepsch19_raw_analytic
    ;
    where
        /* remove rows with missing composite key components */
		not(missing(COUNTY))
 		and
		not(missing(DISTRICT))
 		and
		not(missing(SCHOOL))
  		and
		not(missing(LANGUAGE))
    ;
    by
		COUNTY
		DISTRICT
		SCHOOL
		LANGUAGE
    ;
run;
proc sql;
    create table fepsch19_analytic as
	    select county, school, language, max(total) as totalnum
		from fepsch19_raw_analytic
		group by school
		having total=totalnum
        order by school;
quit;
title "First Twenty Rows of 'fepsch19_analytic' Table";
proc print data=fepsch19_analytic(obs=20);
run;
title;

/* 
This code checks the ELASatrisk_raw dataset for missing key values and 
removes them. For ELASatrisk_raw, the column SCHOOLNAME is a primary key,
so any rows corresponding to multiple values should be removed. In addition,
rows should be removed if they are missing values for SCHOOLNAME.

But we cannot remove directly duplicates of SCHOOLNAME from the original 
table, because each school name corresponds to multiple rows and we want to
keep the average values of these duplicate rows.

After running the proc sort and proc sql steps below, the new dataset 
ELASatrisk_analytic will have no duplicate/repeated unique id values, and 
all unique id values will corresond to our experimental units of interests,
which are California Schools. This means the column SCHOOL in 
ELASatrisk_analytic is guranteed to be a primary key.
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=ELASatrisk_raw
        dupout=ELASatrisk_raw_dups
        out=ELASatrisk_raw_analytic
    ;
    where
    /* remove rows with missing composite key components */

		not(missing(COUNTYCODE))
		and
		not(missing(DISTRICTCODE))
		and
		not(missing(SCHOOLCODE))
		and
		not(missing(COUNTYNAME))
		and
		not(missing(DISTRICTNAME))
		and
		not(missing(SCHOOLNAME))
		and
		/* select rows with results only shown in School aggregate level */
		AggLevel = "S"       
	;
    by
		COUNTYCODE
		DISTRICTCODE
		SCHOOLCODE
		COUNTYNAME
		DISTRICTNAME
		SCHOOLNAME
	;
run;
proc sql;
    create table ELASatrisk_analytic as
	    select countyname, schoolname, avg(EO) as EO, avg(IFEP) as IFEP, 
               avg(EL) as EL, avg(RFEP) as RFEP, avg(TBD) as TBD
		from ELASatrisk_raw_analytic
		group by schoolname
        order by schoolname;
quit;
title "First Twenty Rows of 'ELASatrisk_analytic' Table";
proc print data=ELASatrisk_analytic(obs=20);
run;
title;

/* 
This code checks the chronicabsenteeism_raw dataset for missing key values
and removes them. For chronicabsenteeism_raw, the column SCHOOLNAME is a
primary key, so any rows corresponding to multiple values should be removed.
In addition, rows should be removed if they are missing values for 
SCHOOLNAME.

But we cannot remove directly duplicates of SCHOOLNAME from the original 
table, because each school name corresponds to multiple rows and we want to
keep the average values of these duplicate rows.

After running the proc sort and proc sql steps below, the new dataset 
chronicabsenteeism_analytic will have no duplicate/repeated unique id values, 
and all unique id values will corresond to our experimental units of 
interests, which are California Schools. This means the column SCHOOL in 
ELASatrisk_analytic is guranteed to be a primary key.
*/
options firstobs=1;
options OBS=max;
proc sort
		nodupkey
		data=chronicabsenteeism_raw
		dupout=chronicabsenteeism_raw_dups
		out=chronicabsenteeism_raw_analytic
	;
	where
	/* remove rows with missing composite key components */
		not(missing(COUNTYCODE))
		and
		not(missing(DISTRICTCODE))
		and
		not(missing(SCHOOLCODE))
		and
		
		not(missing(COUNTYNAME))
		and
		not(missing(DISTRICTNAME))
		and
		not(missing(SCHOOLNAME))
		and
		/* select rows with results only shown in School aggregate level */
		AggregateLevel = "S"
	;
	by
		COUNTYCODE
		DISTRICTCODE
		SCHOOLCODE
		
		COUNTYNAME
		DISTRICTNAME
		SCHOOLNAME
	;
run;
data chrabs_raw_format_analytic;
    set chronicabsenteeism_raw_analytic;
        chrabsrate=input(chronicabsenteeismrate, 4.1);
		drop chronicabsenteeismrate;
run;
proc sql;
    create table chronicabsenteeism_analytic as
	    select countyname, schoolname,  
               avg(chrabsrate) as chrabsrate
		from chrabs_raw_format_analytic
		group by schoolname
        order by schoolname;
quit;
title "First Twenty Rows of 'chronicabsenteeism_analytic' Table";
proc print data=chronicabsenteeism_analytic(obs=20);
run;
title;

/* Build analytic dataset from raw datasets imported above including only 
the columns and minimal data-cleaning/transforamtion needed to address each
research queations/objectives in data-analysis files.*/
proc sql;
    create table cde_analytic_raw as
	    select 
            coalesce(E.county, F.county, S.countyname, C.countyname)
			as county,
            coalesce(E.school, F.school, S.schoolname, C.schoolname)
			as school,
			E.language as language_EL 
            label"Language Spoken by the Most EL",
			E.totalnum as total_EL 
            label"Total Number of EL Speaking that Selected Language",
			F.language as language_FEP 
            label"Language spoken by the most FEP",
			F.totalnum as total_FEP
            label"Total Number of FEP Speaking that Selected Language",
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
			label"ChronicAbsenteeismRate"
		from elsch19_analytic as E
		    full join
            fepsch19_analytic as F
			on E.school=F.school
			full join
            ELASatrisk_analytic as S
			on E.school=S.schoolname
			full join
            chronicabsenteeism_analytic as C
            on E.school=C.schoolname
        order by school
	;
quit;
title "First Twenty Rows of 'cde_analytic_raw' Table";
proc print data=cde_analytic_raw(obs=20);
run;
title;

/* 
Check cde_analytic_raw for bad unique id values, where the column school
is intended to be a primary key.

After executing this data step, the resulting dataset is emptywe, meaning
that full joins used above didn't introduce duplicates in the 
cde_analytic_raw. So we can do further proceeding.
*/
data cde_analytic_raw_bad_ids;
    set cde_analytic_raw;
	by school;
	if
		missing(school)
	then
	    do;
		    output;
		end;
run;
proc sort
        nodupkey
        data=cde_analytic_raw
        dupout=cde_analytic_raw_dups
        out=cde_analytic
    ;
    by
		school
    ;
run;

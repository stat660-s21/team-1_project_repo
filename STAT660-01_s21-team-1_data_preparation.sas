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
https://github.com/stat660/team-1_project_repo/raw/main/data/elsch19.xlsx
;
%let inputDataset1Type = xlsx;

/*
[Dataset 2 Name] fepsch19

[Dataset Description] Fluent-English Proficient Students by Grade and Language, 
AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 76,171
                    
[Number of Features] 21

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2018-19&cCat=FEP&cPage=filesfepsch

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsfepsch.asp

[Unique ID Schema] The columns COUNTY, DISTRICT, SCHOOL, and LANGUAGE form a 
composite key. 
*/

%let inputDataset2DSN = fepsch19_raw;
%let inputDataset2URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/fepsch19.xlsx
;
%let inputDataset2Type = xlsx;

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
https://github.com/stat660/team-1_project_repo/raw/main/data/ELASatrisk.xlsx
;
%let inputDataset3Type = xlsx;

/*
[Dataset 4 Name] chronicabsenteeism19

[Dataset Description] Chronic Absenteeism Data, AY2018-19

[Experimental Unit Description] California schools in AY2018-19

[Number of Observations] 239,810
                    
[Number of Features] 14

[Data Source] https://www3.cde.ca.gov/demo-downloads/attendance/chrabs1819.txt

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsabd.asp

[Unique ID Schema] The columns COUNTYCODE, DISTRICTCODE, SCHOOLCODE, and 
REPORTINGCATEGORY form a composite key, which together are equivalent to the 
unique id column CDS in dataset fepsch19 and dataset elsch19 but also 
incorporate demographic information.
*/

%let inputDataset4DSN = chronicabsenteeism_raw;
%let inputDataset4URL = 
https://github.com/stat660/team-1_project_repo/raw/main/data/chronicabsenteeism.xlsx
;
%let inputDataset4Type = xlsx;

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
them. The composite key is CDSCODE and LANGUAGE. The two features were all
necessary to create a composite key for this set. 
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=elsch19_raw
        dupout=elsch19_raw_dups
        out=elsch19_analytic
    ;
    where
        /* remove rows with missing composite key components */
        not(missing(cdscode))
        and
        not(missing(LANGUAGE))
    ;
    by
        cdscode
        LANGUAGE
    ;
run;

/* 
This code checks the fepsch19_raw dataset for missing key values and removes 
them. The composite key is CDSCODE and LANGUAGE. The two features were all 
necessary to create a composite key for this set. 
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=fepsch19_raw
        dupout=fepsch19_raw_dups
        out=fepsch19_analytic
    ;
    where
        /* remove rows with missing composite key components */
        not(missing(cdscode))
        and
        not(missing(LANGUAGE))
    ;
    by
        cdscode
        LANGUAGE
    ;
run;

/* 
This code checks the ELASatrisk_raw dataset for missing key values and removes
them. The composite key is CDSCODE, GRADE and GENDER. These features were all
necessary to create a composite key for this set. 
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=ELASatrisk_raw
        dupout=ELASatrisk_raw_dups
        out=ELASatrisk_analytic
    ;
    where
    /* remove rows with missing composite key components */

        not(missing(cdscode))
        and
        not(missing(GRADE))
        and
        not(missing(GENDER))
        and
        /* select rows with results only shown in School aggregate level */
        AggLevel = "S"       
    ;
    by
        cdscode
        GRADE
        GENDER
    ;
run;

/* 
This code checks the chronicabsenteeism_raw dataset for missing key values and 
removes them. The composite key is CDSCODE, and REPORTINGCATEGORY. These two
features were all necessary to create a composite key for this set. 
*/
options firstobs=1;
options OBS=max;
proc sort
        nodupkey
        data=chronicabsenteeism_raw
        dupout=chronicabsenteeism_raw_dups
        out=chronicabsenteeism_analytic
    ;
    where
    /* remove rows with missing composite key components */
        not(missing(cdscode))
        and
        /* select rows with results only shown in School aggregate level */
        AggregateLevel = "S"
    ;
    by
       cdscode
       REPORTINGCATEGORY
    ;
run;


/*
The following code combines all of the above datasets into sets usable for 
all of our analyses. 
*/

/*
This first set of code chunks combines the files elsch19_analytic and 
fepsch19_analytic into one file called fepel_analytic.
*/

/*
Sort both sets by cdscode and lc.
*/
proc sort data=elsch19_analytic out=elsch19_temp;
    by cdscode lc; 
run;
proc sort data=fepsch19_analytic out=fepsch19_temp;
    by cdscode lc; 
run;


/*
Drop irrelevant columns.
*/
data elsch19_temp; 
    set elsch19_temp; 
    keep
        cdscode 
        lc 
        language
        total_el
    ;
run; 

data fepsch19_temp; 
    set fepsch19_temp; 
    keep
        cdscode 
        lc 
        language
        total
    ;
run; 

/*
Merge into one dataset.
*/
data fepel_analytic; 
    merge 
        fepsch19_temp (rename=(total=Total_FEP)) 
        elsch19_temp; 
    by 
        cdscode 
        lc; 
run;  

/*
The next code chunk creates a usable ELASatrisk_analytic file.
*/
data ELAS_atrisk_analytic;
    set ELASatrisk_analytic; 
    keep 
        cdscode
        EO
        IFEP 
        EL
        RFEP
        TBD
    ;
run; 

/*
Here we create a usable chronicabsentessism file.
*/
data Chronic_abs_analytic;
    set chronicabsenteeism_analytic; 
    keep 
        cdscode
        reportingcategory
        cumulativeenrollment
        chronicabsenteeismcount
        chronicabsenteeismrate
    ;
    if REPORTINGCATEGORY in ("SE", "SH", "TA");
run; 












/*
Hi Ran, 

I think the easiest way to do it so that we both get our files and we still 
produce the fewest number of files is to just put all of my data prep steps 
in here. Then you can see what files I've created and if you can use them then 
we don;t need more, and if you can add to them to use them then that also works.

I put my data processing below. I've created two seperate files: 

One has EL and FEP students summarized at the school level:  


We just want as few files as possible at the end of this prep step.

Cheers, 
Yale
*/



/*
Here I create a single dataset called absentees_analytic with all of the 
information needed to address my first two questions. The file it outputs 
contains only the cdscode, rate of chronic absenteeism among English learners, 
rate of absenteeism among homeless students, and rate of absenteeism among the 
entire school population.  
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








/*
For my third question I needed another file that summarizes the number of fep 
and el students in each school. 

The file created below (fepel_abs_analytic) has that summarized data. 

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



















/*
The next set of code chunks summarizes data in the fepel file and then merges it 
with the chronicabsenteeism file to create a new file callled fepel_abs which 
aggregates information from three of our four datasets and allows us to answer

*/









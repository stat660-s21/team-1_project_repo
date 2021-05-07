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
Note: This compares the column "Language" from elsch19 to the column of the same
name from fepsch19.

Limitations: Values of "CDS" equal to zero and values of "Language" empty should 
be excluded from this analysis, since they are potentially missing data values.

Methodology: Use proc means to take a close look at the summary statistics for 
the number of languages spoken by FEP speakers and EL speakers. And then use proc
sgplot to build a scatterplot, illustrating their correlation.

Followup Steps: A possible follow-up to this approach could use hypothesis test 
to check if the number of languages spoken by EL speakers can predict the number
of languages spoken by FEP speakers. And building a linear regression model may
be helpful.
*/

title1 justify=left
"Question 1 of 3: What are the main languages spoken by English learners (EL) and Fluent-English-Proficient (FEP) students?"
;

title2 justify=left
"Rationale: To take a look at the percentage of different languages among students, which would help school gain culture diversity. And to see if some types of native language will have positive influence on the students' English proficiency."
;

title3 justify=left
"Summary Statistics for Languages of FEP students and Languages of EL"
;

footnote1 justify=left
"Spanish is the most common language among both English learners (EL) and Fluent-English-Proficient (FEP) students"
;

footnote2 justify=left
"The most common foreign languages such as Spanish, Mandarin and Vietnamese have higher percentage of speakers among Fluent-English-Proficient (FEP) students than among English learners (EL). On the contrast, some minor languages such as Dutch, Lao and Samoan tend to have higher percentage of speakers among English learners (EL)"
;

footnote3 justify=left
"The number of Spanish speakers among both English learners (EL) and Fluent-English-Proficient (FEP) students is nearly 1000000."
;

proc means data=EL_FEP_analytic maxdec=0;
    var 
        total_EL total_FEP
    ;
	label
	    total_EL="Total Number of One Specific Language Spoken by EL",
	    total_FEP="Total Number of One Specific Language Spoken by FEP"
	;
run;

/* clear titles/footnotes */
title;
footnote;

title1 justify=left
"Scatter Plot of the Number of Languages of FEP students and EL"
;

footnote1 justify=left
"The scatter plot has excluded Spanish because the number of Spanish is much larger than other values and badly influences the visualization of all points."
;

proc sgplot data=EL_FEP_analytic(where=(total_EL<100000));
    scatter 
        x=total_EL
        y=total_FEP/
		group=language
		datalabel=language
    ;
	lineparm 
        x=0 y=0 slope=2/ lineattrs=(color='red')
    ;
	label
	    total_EL="Total Number of One Specific Language Spoken by EL",
	    total_FEP="Total Number of One Specific Language Spoken by FEP"
	;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Note: This compares the column "Language" from elsch19 to the column Chronic 
Absenteeism Rateù from chronicabsenteeism19.

Limitations: Values of "Language" and "Chronic Absenteeism Rate" equal to zero 
or empty should be excluded from this analysis, since they are potentially 
missing data values. And only values of "AggregateLevel" eaqul to "S" should be 
included in this analysis, since these rows contain SchoolName information.

Methodology: Use proc format to create a customized format called chrabs to re-
arrange Chronic Absenteeism Rate. Next, use proc freq to perform a correlation 
analysis and then use the output to extract a subgroup. Last, use proc sgplot 
to output a vertical barchart, illustrating how different range of Chronic 
Absenteeism Rate is allocated among the main native languages.

Followup Steps: A possible follow-up to this approach could use mathematical 
method to normalize the number of different native languages and to study the
correlation between tht native language types and Chronic Absenteeism Rate.
*/

proc format;
    value chrabs
	    0-<30='0-30%'
        30-<70='30%-70%'
		70-100='70%-100%'
	;
run;

title1 justify=left
"Question 2 of 3: Will English learners with different native languages have various Chronic Absenteeism Rates?"
;

title2 justify=left
"Rationale: This would help inform whether native languages are associated with Chronic Absenteeism Rate."
;

title3 justify=left
"Correlation Analysis for Chronic Absenteeism Rate and Languages of English Learners"
;

footnote1 justify=left
"The number of Spanish speakers is much more than other types of language, so it may influence the visulization of associations between languages and Chronic Absenteeism Rate."
;

footnote2 justify=left
"Overall, Spanish speakers tend to have lower Chronic Absenteeism Rate."
;

footnote3 justify=left
"Chronic Absenteeism Rates of speakers of other typre of language (not Spanish) are mostly within a low percentage of range of 0-30%."
;

ods graphics on;
proc freq data=Whole_School_analytic order=freq;
    table 
        chrabs_rate language_EL language_EL*chrabs_rate/crosslist out=EL_Chrabs_count outpct
    ;
	format 
        chrabs_rate chrabs.
    ;
	label 
	    language_EL="Language Name Spoken by the Most EL in Each School",
        chrabs_rate="Chronic Absenteeism Rate"
    ;
	where 
	    not(missing(chrabs_rate))
		and
        not(missing(language_EL))
    ;
run;

/* clear titles/footnotes */
title;
footnote;

data EL_Chrabs_count_analytic;
   set EL_Chrabs_count;
   where count>50;
run;

title1 justify=left
"Counts of Language by Chronic Absenteeism Rate"
;

footnote1 justify=left
"The number of Spanish speakers is much more than other types of language, and Spanish speakers tend to have lower Chronic Absenteeism Rate."
;

proc sgplot data=EL_Chrabs_count_analytic;
    vbar 
        language_EL/response=pct_row group=chrabs_rate groupdisplay=cluster
    ;
	label 
	    language_EL="Language Name Spoken by the Most EL in Each School",
        chrabs_rate="Chronic Absenteeism Rate"
    ;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Note: This compares the column EOù, IFEPù, ELù, RFEPù, TBD from ELAS/LTEL/AT-Risk to 
the column Chronic Absenteeism Rateù from chronicabsenteeism19.

Limitations: Values of EOù, IFEPù, ELù, RFEPù, TBD and Chronic Absenteeism Rate equal 
to zero or empty should be excluded from this analysis, since they are 
potentially missing data values. And only the values of AggLEvel and 
AggregateLevel eaqul to "S" should be included in this analysis, since these 
rows contain SchoolName information.

Methodology: Use proc freq to perform a correlation analysis and then based on the
output, use proc sgplot to create a vertical barchart, illustrating how different 
range of Chronic Absenteeism Rate is allocated among the each type of students.

Followup Steps: In order to deeply study the relationship between type of students
and Chronic Absenteeism Rate, a possible follow-up could be to make a vertical 
comparison between this results with the results from previous years' data.
*/

title1 justify=left
"Question 3 of 3: Is there a relationship between the type of students (classified by their English level) with the Chronic Absenteeism Rate?"
;

title2 justify=left
"Rationale: This would help identify if students' English level will determine their Chronic Absenteeism Rate."
;

title3 justify=left 
"Correlation Analysis for Chronic Absenteeism Rate and Student Type"
;

footnote1 justify=left
"The percentages of different type of students among each range of Chronic Absenteeism Rate are similar but show slight differences."
;

footnote2 justify=left
"The number of EO is much more than other types of students, so that may have influence on our results of Chronic Absenteeism Rate."
;

footnote3 justify=left
"The IFEP has the highest percentage of lower Chronic Absenteeism Rate within range 0-30% compared to other type of student, and RFEP has the lowest percentage of low Chronic Absenteeism Rate and the highest percentage of high Chronic Absenteeism Rate."
;

proc freq data=Whole_School_analytic order=freq;
    table 
        student_type student_type*chrabs_rate/crosslist out=Chrabs_Stutype_count outpct
    ;
	format 
        chrabs_rate chrabs.
    ;
	label 
        chrabs_rate="Chronic Absenteeism Rate"
        student_type="The Type of Students"
    ;
	where 
	    not(missing(chrabs_rate))
		and
        not(missing(student_type))
    ;
run;

/* clear titles/footnotes */
title;
footnote;

title1 justify=left 
"Percent of Different Chronic Absenteeism Rate by Student Type"
;

footnote1 justify=left
"Among all types of students, IFEP tend to have the highest percentage of low Chronic Absenteeism Rate and the lowest percentage of high Chronic Absenteeism Rate."
;

proc sgplot data=Chrabs_Stutype_count;
    vbar 
        student_type/response=pct_row group=chrabs_rate groupdisplay=cluster filltype=gradient datalabel
    ;
	label 
        chrabs_rate="Chronic Absenteeism Rate"
        student_type="The Type of Students"
    ;
run;

/* clear titles/footnotes */
title;
footnote;


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
Question 1 of 3: How do rates of homeless students affect rates of chronic 
absenteeism in California schools? 

Rationale: One of the most pressing issues facing California and espescially 
facing Clifornia schools is a lack of affordable housing. Homeless students are
expected to miss more school days because of environmental circumstances than 
a typical student. This should analysis should help us understand how schools 
that face these problems can better serve their students.

Note: This compares the columns ChronicAbsentee_Rate and Homeless_Rate in the 
by_school_analytic file. 

Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file. 
*/

title1 justify=left
'Question 1 of 3: How do rates of homeless students affect rates of chronic absenteeism in California schools?'
;

title2 justify=left
'Rationale: One of the most pressing issues facing California, and one that especially affects California schools, is a lack of affordable housing. Homeless students are expected to miss more school days because of environmental circumstances than a typical student. This analysis should help us understand how schools that face these problems can better serve their students.'
;

title3 justify=left
"Chronic Absenteeism by homelessness in 4719 California Schools."
;

footnote1 justify=left
"This plot show an obvious skew along both axes."
;

proc sgplot data=by_school_analytic; 
    scatter x=homeless_rate y=chronicabsentee_rate;
run;

title;
footnote;

title3 justify=left
"log(Chronic Absenteeism) by log(Homelessness) in 4719 California Schools."
;

footnote1 justify=left
"Here we can see that there isn't a strong visual relationship."
;

proc sgplot data=by_school_analytic; 
    scatter x=logHless y=logChronAbs;
run;

title;
footnote;

title3 justify=left
"OLS regression of log(Chronic Absentee Rate)=log(Homelessness Rate)."
;

footnote1 justify=left
"The OLS regression shows a significant relationship between the two log values."
;

proc reg data=by_school_analytic;
    model logchronabs=loghless;
    ods select ParameterEstimates FitPlot;
run;

title;
footnote;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: How does the rate of English Learners affect chronic 
absenteeism rates in California schools?

Rationale: Much like homelessness among their students, Califonria schools face 
the challenge of helping students who struggle to understand the language being 
used by their instructors. Many students miss school because they find it hard 
to effectively communicate with their teachers and classmates. This analysis 
will further help to identify schools in greater need of funding from the state.  

Notes: 
This compares the columns EL_Rate and ChronicAbsentee_Rate in the 
by_school_analytic file. 

Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file. 
*/

title1 justify=left
'Question 2 of 3: How does the rate of English learners affect the rate of chronic absenteeism in California schools?'
;

title2 justify=left
'Rationale: Much like homelessness among their students, Califonria schools face the challenge of helping students who struggle to understand the language being used by their instructors. Many students miss school because they find it hard to effectively communicate with their teachers and classmates. This analysis will further help to identify schools in greater need of funding from the state.'
;

title3 justify=left
"Chronic Absenteeism by EL Rates in 4719 California Schools."
;

footnote1 justify=left
"Like the first question, this plot show an obvious skew along both axes."
;

proc sgplot data=by_school_analytic; 
    scatter x=homeless_rate y=chronicabsentee_rate;
run;

title;
footnote;

title3 justify=left
"log(Chronic Absenteeism) by log(EL Rate) in 4719 California Schools."
;

footnote1 justify=left
"Here we can see that, like above, there isn't a strong visual relationship."
;

proc sgplot data=by_school_analytic; 
    scatter x=logEL y=logChronAbs;
run;

title;
footnote;

title3 justify=left
"OLS regression of log(Chronic Absentee Rate)=log(EL Rate)."
;

footnote1 justify=left
"The OLS regression shows a significant relationship between the two log values."
;

proc reg data=by_school_analytic;
    model logchronabs=logEL;
    ods select ParameterEstimates FitPlot;
run;

title;
footnote;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: How do homelessness and EL rates interact to affect chronic 
absenteeism in California schools? 

Rationale: While we may not expect a great amount of overlap between the two 
groups, we do expect schools to vary in the number of these at-risk populations
that they serve, and we should expect some schools to have a greater number of 
both populations of students in need of aid. This analysis should help us 
understand if certain schools within the state are in greater need of resources 
earmarked for various social programs based on the combination of factors.

Note: This compares the ChronicAbsentee_Rate column to the EL_Rate and 
Homless_Rate in the by_school_analytic file. 

Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file.  
*/

title1 justify=left
'Question 3 of 3: How do homelessness and EL rates interact to affect chronic absenteeism in California schools?'
;

title2 justify=left
'Rationale: While we may not expect a great amount of overlap between the two groups, we do expect schools to vary in the number of these at-risk populations that they serve, and we should expect some schools to have a greater number of both populations of students in need of aid. This analysis should help us understand if certain schools within the state are in greater need of resources earmarked for various social programs based on the combination of factors.'
;

title3 justify=left
"OLS regression of log(Chronic Absentee Rate)=log(EL Rate) + log(Homelessness)."
;

footnote1 justify=left
"When both terms are considered along with their interaction, the OLS regression shows a significant relationship between the logs of both the two predictor values and the log of chronic absenteeism. It also shows that their interaction is an important factor that should be considered when assessing a school's need."
;

proc glm data=by_school_analytic;
    model logchronabs=logEL logHless logEL*logHless;
    ods select ParameterEstimates ContourFit;
run;

title;
footnote;

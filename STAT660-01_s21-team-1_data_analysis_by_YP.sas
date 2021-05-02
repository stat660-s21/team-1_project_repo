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
"Note: Because rate data is of interest as both the predictor and the outcome, the most useful metric to examine here is the log of both variables."
;

title4 justify=left
"Figure 1.1: log(Chronic Absenteeism) by log(Homelessness) in 4719 California Schools."
;

footnote1 justify=left
"Here we can see a visual trend."
;

footnote2 justify=left
"I will proceed next to examine this relationship analytically."
;

proc sgplot data=by_school_analytic; 
    scatter x=logHless y=logChronAbs;
run;

title;
footnote;

title1 justify=left
"OLS regression of log(Chronic Absentee Rate) vs. log(Homelessness Rate)."
;

title2 justify=left
"Figure 1.2: Scatterplot of log(Chronic Absenteeism) by log(Homelessness) along with the fitted linear model."
;

footnote1 justify=left
"The linear regression output below shows strong evidence that this reationship is significant." 
;

proc glm data=by_school_analytic; 
    model logchronabs=loghless;
    ods select FitPlot;
run;

title;
footnote;

title1 justify=left
"Figure 1.3: Estimated regression coefficients for rate of chronic absenteeism as a function of rate of homelessness among students."
;

footnote1 justify=left
"The OLS regression shows a significant relationship between the two log values."
;

footnote2 justify=left
"Based on the p-value above (logHless: p < 0.0001) there is strong evidence that homelessness affects chronic abesnteeism in public schools."
;

footnote3 justify=left
"The estimate of the effect can be interpreted directly. For every 1% increase in homelessness among its students, a school can expect to see a .17% increase in chronic absenteeism."
;

footnote4 justify=left
"(Note: This model assumes that the relationship is generally linear, and that the errors are normally disrtibuted and vary constantly. The usual means by which to check these assumptions is to look at various diagnostic plots. While I have not included those plots here, I have assessed the validity of these assumptions and there appears to be no significant violation.)"
;

proc glm data=by_school_analytic;
    model logchronabs=loghless;
    ods select ParameterEstimates;
run;

title;
footnote;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
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
"Note: As with the previous question, because rate data is of interest as both the predictor and the outcome, the most useful metric to examine here is the log of both variables."
;

title4 justify=left
"Figure 2.1: log(Chronic Absenteeism) by log(Homelessness) in 4719 California Schools."
;

footnote1 justify=left
"Here, again, we can see a trend in the data."
;

footnote2 justify=left
"I will proceed to examine this relationship analytically."
;

proc sgplot data=by_school_analytic; 
    scatter x=logEL y=logChronAbs;
run;

title;
footnote;

title1 justify=left
"OLS regression of log(Chronic Absentee Rate) vs. log(English learners Rate)."
;

title2 justify=left
"Figure 2.2: Scatterplot of log(Chronic Absenteeism) by log(English learners) along with the fitted linear model."
;

footnote1 justify=left
"The linear regression output below shows strong evidence that this reationship is significant." 
;

proc glm data=by_school_analytic; 
    model logchronabs=logEL;
    ods select FitPlot;
run;

title;
footnote;

title1 justify=left
"Figure 2.3: Estimated regression coefficients for rate of chronic absenteeism as a function of rate of English learners."
;

footnote1 justify=left
"The linear regression shows a significant relationship between the two log values."
;

footnote2 justify=left
"Based on the p-value above (logEL: p < 0.0001) there is strong evidence that homelessness affects chronic abesnteeism in public schools."
;

footnote3 justify=left
"The estimate of the effect can be interpreted directly. For every 1% increase in English learners among its students, a school can expect to see a .13% increase in chronic absenteeism."
;

footnote4 justify=left
"(Note: This model assumes that the relationship is generally linear, and that the errors are normally disrtibuted and vary constantly. The usual means by which to check these assumptions is to look at various diagnostic plots. While I have not included those plots here, I have assessed the validity of these assumptions and there appears to be no significant violation.)"
;

proc glm data=by_school_analytic;
    model logchronabs=logEL;
    ods select ParameterEstimates;
run;

title;
footnote;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Note: This compares the ChronicAbsentee_Rate column to the EL_Rate and 
Homless_Rate in the by_school_analytic file. 

Limitations: Edited (4/29): This question can now be addressed using only the 
by_school_analytic file.  
*/

title1 justify=left
'Question 3 of 3: How do homelessness and EL rates interact to affect chronic absenteeism in California schools?'
;

title2 justify=left
'Rationale: While we may not expect a great amount of overlap between the two groups, we do expect schools to vary in the number of these at-risk populations that they serve, and we should expect some schools to have a greater number of both populations of students in need of aid. This analysis should help us understand if certain schools within the state are in greater need of resources earmarked for various programs based on the combination of factors.'
;

title3 justify=left
"Note: Since rate data is again of interest as both the predictors and the outcome, the most useful metric to examine here is the log of all variables."
;

title4 justify=left
"Figure 3.1: Estimated regression coefficients for rate of chronic absenteeism as a function of both the rate of English learners and the rate of homelessness in a school, as well as their interaction." 
;

footnote1 justify=left
"When both terms are considered along with their interaction, the OLS regression shows a significant relationship between the logs of the two predictor values and the log of chronic absenteeism. It also shows that their interaction is an important factor that should be considered when assessing a school's need."
;

footnote2 justify=left
"Based on the p-value above, all of which are less than 0.0001, there is strong evidence that when considered together, the rate of homelessness and the rate of English learners both have a significant effect on the rate of chronic abesnteeism in California schools."
;

footnote3 justify=left
"The estimates of the effects can again be interpreted directly in the same manner as above. E.g. Other variables being held constant, for every 1% increase in English learners among its students, a school can expect to see a .21% increase in chronic absenteeism. Note that that estimate is much greater than the .13% estimated change when homelessness is ignored. The estimate for the coefficient on the interaction term is a little more difficult to interpret, but it shows that the effects of each predictor are not enough to explain the variation in the data and that the way they interact within a school is also an important factor to consider when modeling the outcomes."
;

footnote4 justify=left
"From these anayses it has become clear that a student's homelessness status and their ability to effecitively communicate with those around them both have an impact on the rate of chronic absenteeism a school can expect to experience. I've further found that while considering EL rates has little effect on the estimated effect of homelessness, the estimated effect of EL rates increases drastically when the two are considered rtogether."
;

footnote4 justify=left
"(Note: This model assumes that the relationship is generally linear, and that the errors are normally disrtibuted and vary constantly. The usual means by which to check these assumptions is to look at various diagnostic plots. While I have not included those plots here, I have assessed the validity of these assumptions and there appears to be no significant violation.)"
;

proc glm data=by_school_analytic;
    model logchronabs=logEL logHless logEL*logHless;
    ods select ParameterEstimates;
run;
quit;

title;
footnote;

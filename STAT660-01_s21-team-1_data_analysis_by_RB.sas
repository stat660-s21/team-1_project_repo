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
title1 justify=left
"Question 1 of 3: What are the main language spoken by English learners (EL) and 
Fluent-English-Proficient (FEP) students in different schools? Can we find 
anything interesting among them?"
;

title2 justify=left
"Rationale: To take a look at the percentage of different languages, which would 
help school gain culture diversity. And to see if some type of native languages 
will have positive influence on the students English proficiency."
;

footnote1 justify=left
"Spanish is the most common language among both English learners (EL) and 
Fluent-English-Proficient (FEP) students"
;

footnote2 justify=left
"The most common languages such as Spanish, Mandarin and Vietnamese have higher 
percentage of speakers among Fluent-English-Proficient (FEP) students than the
percentage among English learners (EL). On the contrast, the minor languages 
such as Dutch, Lao and Samoan tend to have higher percentage of speakers among
English learners (EL)"
;

title;
footnote;

proc sql;
    create table EL_FEP_analytic as
	    select coalesce(E.language, F.language) as language, E.total_EL, F.total_FEP
        from 
            (select language_EL as language, sum(total_EL) as total_EL
			    from Whole_School_analytic
				where
				    language is not null
					and
					total_EL is not null
                group by language
            ) as E
		    inner join
            (select language_FEP as language, sum(total_FEP) as total_FEP
			    from Whole_School_analytic
				where
				    language is not null
					and
					total_FEP is not null
                group by language
            ) as F
			on E.language=F.language
        
    order by language; 
quit;

title;
footnote;

title1 justify=left
"Summary Statistics for Language of FEP students and Languages of EL"
;

footnote1 justify=left
"The number of Spanish speakers among both English learners (EL) and 
Fluent-English-Proficient (FEP) students is nearly 1000000."
;

proc means data=EL_FEP_analytic maxdec=0;
    var total_EL total_FEP;
run;

title;
footnote;

title1 justify=left
"Scatter Plot of the Number of Languages of FEP students and EL"
;

footnote1 justify=left
"The scatter plot has excluded Spanish because the number of Spanish is much
larger than other values and badly influences the visualization of all points."
;

proc sgplot data=EL_FEP_analytic(where=(total_EL<100000));
    scatter 
        x=total_EL
        y=total_FEP/
		group=language
		datalabel=language
    ;
	lineparm x=0 y=0 slope=2/ lineattrs=(color='red')
    ;
run;

title;
footnote;



*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
"Question 2 of 3: Will English learners with different language have various
Chronic Absenteeism Rate?"
;

title2 justify=left
"Rationale: This would help inform whether native languages are associated with 
Chronic Absenteeism Rate."
;

footnote1 justify=left
"The number of Spanish speakers is much more than other types of language, so it
is hard to find some associations between languages and Chronic Absenteeism Rate."
;

footnote2 justify=left
"Overall, Spanish speakers tend to have lower Chronic Absenteeism Rate."
;

proc format;
    value chrabs
	    0-<30='0-30%'
        30-<70='30%-70%'
		70-100='70%-100%'
	;
run;

title;
footnote;

title1 justify=left
"Correlation Analysis for Chronic Absenteeism Rate and Languages of English 
Learners"
;

footnote1 justify=left
"Chronic Absenteeism Rates of speakers of other typre of language (not Spanish)
are mostly within a low percentage of range of 0-30%."
;

ods graphics on;
proc freq data=Whole_School_analytic order=freq;
    table chrabs_rate language_EL chrabs_rate*language_EL/crosslist plots=freqplot out=EL_Chrabs_count;
	format chrabs_rate chrabs.;
	label chrabs_rate="Chronic Absenteeism Rate";
	where 
	    not(missing(chrabs_rate))
		and
        not(missing(language_EL))
;
run;

data EL_Chrabs_count_analytic;
   set EL_Chrabs_count;
      where count>50;
run;

title1 justify=left
"Counts of Language by Chronic Absenteeism Rate"
;

footnote1 justify=left
"The number of Spanish speakers is much more than other types of language, and 
Spanish speakers tend to have lower Chronic Absenteeism Rate."
;

proc sgplot data=EL_Chrabs_count_analytic;
    vbar chrabs_rate/response=count
         group=language_EL groupdisplay=cluster;
run;

title;
footnote;



*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
title1 justify=left
"Question 3 of 3: Is there a relationship between the type of students 
(classified by their English level) with the Chronic Absenteeism Rate?"
;

title2 justify=left
"Rationale: This would help identify if students' English level will determine 
their Chronic Absenteeism Rate."
;

title3 justify=left 
"Correlation Analysis for Chronic Absenteeism Rate and Student Type"
;

footnote1 justify=left
"The percentages of different type of students among each range of Chronic 
Absenteeism Rate are similar but show slight differences."
;

footnote2 justify=left
"The number of EO is much more than other types of students, so that may have
influence on our results of Chronic Absenteeism Rate."
;

footnote3 justify=left
"The EL has the highest percentage of lower Chronic Absenteeism Rate within 
range 0-30% compared to other type of student, and RFEP has the lowest 
percentage of low Chronic Absenteeism Rate and the highest percentage of high 
Chronic Absenteeism Rate."
;

proc freq data=Whole_School_analytic order=freq;
    table student_type student_type*chrabs_rate/
          crosslist out=Chrabs_Stutype_count;
	format chrabs_rate chrabs.;
	label chrabs_rate="Chronic Absenteeism Rate"
          student_type="Type of Students";
	where 
	    not(missing(chrabs_rate))
		and
        not(missing(student_type))
;
run;

title;
footnote;

title1 justify=left 
"Counts of Different Chronic Absenteeism Rate by Student Type"
;

footnote1 justify=left
"Among all types of students, EL tend to have the highest percentage of low 
Chronic Absenteeism Rate and the lowest percentage of high Chronic Absenteeism
Rate."
;

proc sgplot data=Chrabs_Stutype_count;
    vbar chrabs_rate/response=count
         group=student_type groupdisplay=cluster filltype=gradient datalabel;
run;

title;
footnote;


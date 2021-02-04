/*===================================================*/
/*													 */
/* Title: CO Hospitalization data validation checks  */
/* Author: Mackenzie Malone							 */
/* Date created: 6/20/2019							 */
/* Description: Adaption of CDC EPHTN validation     */
/* scripts for use by recipients prior to submission */
/*													 */
/*===================================================*/

/******************** INSTRUCTIONS FOR USE  ************************/
* 1. Code is generic and needs to be adapted before use and is 
	written to validate one health outcome at a time;
* 2. Variable names assigned in this script are based on the 
  	most recent data dictionary available on the SharePoint;
* 3. Refer to Validation framework and documentation for more 
	information on validation themes and their applications;
* 4. Please note the check numbering does not match with Battelle 
	provided reports;
* 5. Comments provided throughout the code offer guidance on interpreting 
	the output;
* 6. For questions about the provided code or how to use it,
	please contact Tracking Support (nephtrackingsupport@cdc.gov);
/*******************************************************************/




/**** STEP 1: Update macro variables for dataset of interest ****/

%let FolderLocation= ; /* Assign a folder locaiton to send the output */
%let HealthOutcomeId = 3; 
%let HealthOutcome = COPoisoning;
%let StateName= ; /*include your jurisdiction ex. Arizona*/
%let DataCall= Fall2019; /*include data call information, if you wish to save for records*/



/**** STEP 2. Import the data (ex. data from a SQL data base)****/

proc sql exec; 
  connect to oledb
     (init_string= /*database credentials*/ );

  create table Validation as select * from connection to oledb
                                  	(select * from /*table name*/);
disconnect from oledb;
  quit;
run;



/**** STEP 3. Route output to a pdf and set formats****/

ods pdf body = "&FolderLocation.\&StateName._&HealthOutcome._Hosp_&DataCall..pdf";


/* set formats for categorical variables */
proc format;
value AGEGROUP	1 = '0-4 Years'
				2 = '5-9 Years'
				3 = '10-14 Years'
				4 = '15-19 Years'
				5 = '20-24 Years'
				6 = '25-29 Years'
				7 = '30-34 Years'
				8 = '35-39 Years'
				9 = '40-44 Years'
				10 = '45-49 Years'
				11 = '50-54 Years'
				12 = '55-59 Years'
				13 = '60-64 Years'
				14 = '65-69 Years'
				15 = '70-74 Years'
				16 = '75-79 Years'
				17 = '80-84 Years'
				18 = '85+ Years'
				19 = 'Unknown';
value OUTCOME  1 = 'Asthma'
  			   2 = 'MI'
			   3 = 'CO'
			   4 = 'Heat'
			   5= 'COPD';

run;


/**** STEP 4. Basic review of data, data cleaning (adapted gateway checks) ****/
/* These checks look for: Missing/Invalid Values, Improper Structure,Duplicates */


/*Check data for expected variables based off of data dictionary and schema*/ 
proc contents data=Validation; 
	title 'Check 1. Valid variables/schema match';
	run; 

/*Check HealthOutcomeID is properly assigned*/
proc freq data=Validation; 
	tables HealthOutcomeID ; 
	format  HealthOutcomeID  Outcome.;
	title 'Check 2. Health Outcome ID';
run;

/*Check for Duplicates*/
proc freq data=Validation; tables State*HealthOutcomeID*county*YearAdmitted*AdmissionMonth*AgeGroup*Sex /*Race*Ethnicity*/
	/noprint out=hosp_dup noprint; 
	
run; 

proc sql noprint;
select count(*) into :nobs from hosp_dup;
quit;
%put &nobs;run; 

title 'Check 3. Duplicates';
proc print data=hosp_dup;
where count ge 2;
var State HealthOutcomeID County YearAdmitted AdmissionMonth AgeGroup Sex /* Race Ethnicity*/ count;
run;


/**** STEP 5. Strange Pattern Check ****/
/* This check looks for all even or odd records, all even records needs to be investigated */

data even;
  set Validation;
  if mod(MonthlyHosp,2)=0 or mod(IncidentCountFire,2)=0 or mod(IncidentCountNonFire,2)=0 or mod(IncidentCountUnknown,2)=0 then even=1;
  else even=0;
run;

  /* Note: The MOD function returns the remainder from the division of */
  /* argument-1 by argument-2.  If the remainder is zero, when         */
  /* the second argument is 2, then the first argument must be even    */

proc freq data=even; 
	tables even; 
	title 'Check 4. Even/Odd Counts';
run;



/**** STEP 6. Lack or Excess of data/Record Level Checks ****/
/* These checks look at the data on the record level, lower/higher number of records than expected need to be confirmed */

/*Number of total records by year*/ 
title 'Check 5. Records per year of data';
proc sql; 
	select YearAdmitted, count(*) as Records from Validation
	group by YearAdmitted; 
quit;run;


/*Number of counties reported*/
title ' Check 6. Number of unique counties per year';
proc sql; 
	select YearAdmitted, count(distinct County) as Counties from Validation
	group by YearAdmitted; 
quit;run;
 

/*Number of records per county*/
title 'Check 7. Number of records by county';
proc freq data=Validation; 	
	tables County*YearAdmitted/nocol norow nopercent;
run;


/*Frequency by CO cause*/
Proc freq data=Validation; 
	title 'Check 8a. Number of records - Fire';
	tables IncidentCountFire/norow nocol nopercent;

	title 'Check 8b. Number of records - Non-Fire';
    tables IncidentCountNonfire/norow nocol nopercent;

	title 'Check 8c. Number of records - Unknown';
    tables IncidentCountUnknown/norow nocol nopercent;
run;


/*Frequency and percent records by age groups */
Title 'Check 9. Variable Level Frequency - Age Groups';
proc freq data=Validation; 
	tables AgeGroup*YearAdmitted/ norow nocol; 
	*format AgeGroup AgeGroup.;
run; 


/*Frequency and percent records by gender*/
Title 'Check 10. Variable Level Frequency - Gender';
proc freq data=Validation; 
	tables Sex*YearAdmitted/ norow nocol; 
run;


/**** STEP 7. Outliers and Inconsistencies - Values ****/
/* These checks look at the number/sum of admissions  */


/*Sum of events per year*/
Title 'Check 11. Sum of Admissions by  year';
proc sql; 
	select YearAdmitted, Sum(IncidentCountFire) as Fire, Sum(IncidentCountNonFire) as Nonfire, 
	Sum(IncidentCountUnknown) as Unknown from Validation
	group by YearAdmitted; 
run; quit;


/*Sum of Events by County/Year*/
Title 'Check 12. Sum of Admissions by County and Cause';
proc tabulate data=Validation; 
	Class County YearAdmitted; 
	var IncidentCountFire IncidentCountNonFire IncidentCountUnknown MonthlyHosp; 
	table YearAdmitted*County, IncidentCountFire IncidentCountNonFire IncidentCountUnknown MonthlyHosp;
run;

/*Sum of admissions by cause/sex*/
proc sort data = Validation;
  by State YearAdmitted Sex;
  run;
proc means noprint data = Validation;
  by State YearAdmitted Sex;
  OUTPUT OUT =sum_by_sex (drop= _freq_ _type_)
  SUM(MonthlyHosp) = ADMISSIONS
  SUM(IncidentCountFire) = FIRE_ADMISSIONS
  SUM(IncidentCountNonFire) = NON_FIRE_ADMISSIONS
  SUM(IncidentCountUnknown) = UNK_FIRE_ADMISSIONS;
run; 
proc print data=sum_by_sex; 
  title 'Check 13. Sum of admissions by cause/sex';
RUN;


/*Sum of events by age group*/
proc sort data = Validation;
  by State YearAdmitted AgeGroup;
  run;
proc means noprint data = Validation;
  by State YearAdmitted AgeGroup;
  OUTPUT OUT =sum_by_age (drop= _freq_ _type_)
  SUM(MonthlyHosp) = ADMISSIONS
  SUM(IncidentCountFire) = FIRE_ADMISSIONS
  SUM(IncidentCountNonFire) = NON_FIRE_ADMISSIONS
  SUM(IncidentCountUnknown) = UNK_FIRE_ADMISSIONS;
run; 
proc print data=sum_by_age; 
  title 'Check 14. Sum of Admissions by Age Group/Year - Cause';
RUN;


ods pdf close; 
quit;





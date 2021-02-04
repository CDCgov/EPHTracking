/*===================================================*/
/*													 */
/* Title: Sample Archive checks 				     */
/* Author: Mackenzie Malone							 */
/* Date created: 6/20/2019							 */
/* Description: Adaption of CDC EPHTN validation     */
/* scripts for use by recipients prior to submission */
/*													 */
/*===================================================*/

/******************** INSTRUCTIONS FOR USE  ************************/
* 1. In this code: Sample % difference code and sample box plot 
	code;
* 2. Code is generic and needs to be adapted before use and is 
	written to validate one health outcome at a time;
* 3. Some data preparation my need to be done before running the 
	sample archive codes;
* 4. Variable names assigned in this script are based on the 
  	most recent data dictionary available on the SharePoint;
* 5. Refer to Validation framework and documentation for more 
	information on validation themes and their applications;
* 6. For questions about the provided code or how to use it,
	please contact Tracking Support (nephtrackingsupport@cdc.gov);
/*******************************************************************/



/**** STEP 1: Update macro variables for dataset of interest ****/
%let FolderLocation= ; /* Assign a folder locaiton to send the output */
%let HealthOutcomeId =1; /*1=Asthma, 2=AMI, 3=CO, 4=Heat, 5=COPD*/
%let HealthOutcome = Asthma; 
%let Dataname= Hospitalizations; /* Name of dataset Hospitalizations or Emergency Dept*/
%let StateName= ; /*include your jurisdiction*/
%let DataCall= Fall2019; /*include data call information, if you wish to save for records*/


/**** STEP 2: Import data sets, New year of data and archive years of data ****/

*** Importing state data - newly submitted and archive data ***;

proc sql exec; 
  connect to oledb
     (init_string= /*database credentials*/ );

  	create table New_Data as select * from connection to oledb
                                  	(select * from /*table name*/);

 	create table Archive_Data as select * from connection to oledb
                                  	(select * from /*table name*/);
disconnect from oledb;
  quit;
run;


/**** STEP 3. Route output to a pdf and set formats ****/

ods pdf body = "&FolderLocation.\&StateName._&HealthOutcome._Hosp_&DataCall..pdf";


/********************************************/
/*        	 Sample Box Plot Code			*/
/********************************************/


/**** STEP 4. Sum events in new dataset ****/

**** Sort new year of data ****;
proc sort data=New_Data;
by Year County; 
run;

**** Sum events by year and county ****;
proc means noprint data=New_Data; 
	by Year County;
	output out= New_Sum (drop=_type_ _freq_) 
	sum(MonthlyHosp)= n_visits; 
run; 



/**** STEP 5. Sum events in previously submitted years of data ****/
* If all years are kept in one dataset, disregard this step *;

**** Sort previous years of data (dataset of all previous submitted year) ****; 
proc sort data=Archive_Data; 
	by Year County; 
run;

**** Sum events by county and year ****;
proc means data= Archive_Data; 
	by Year Couty; 
	output out=Archive_sum (drop= _type_ _freq_)
	sum(MonthlyHosp)= n_visits;
run;


/**** STEP 6. Combine datasets for a complete dataset with all years ****/

data Full_Data; 
	set New_Sum Archive_Sum; 
run;


/**** STEP 7. Create boxplot for # tested by year/county ****/  
proc sgplot data=Full_Data;
  hbox n_visits / category=year ;
  title "Number of &outcome.-&dataname. visits by Year for &state. - New years v. archive years";
  xaxis label= "Number of Events";
run;


/**** STEP 8. Pull in population data and merge with full dataset ****/

proc sql exec; 
  connect to oledb
     (init_string= /*database credentials*/ );

  	create table Pop_data as select * from connection to oledb
                                  	(select * from /*table name*/);
	disconnect from oledb;

quit;
run;

**** Sum data by county/year ****;
proc means noprint data=Pop_Data; 
	by Year County;
	output out= Pop_Sum (drop=_type_ _freq_) 
	sum(Population_amount)= total_pop; 
run; 

**** Sort data and merge with full dataset ****;
proc sort data=Pop_Sum; 
	by Year County; 
run; 

proc sort data=Full_Data; 
	by Year County; 
run;

data Merge_pop; 
	merge Full_data(in=a) Pop_Sum(in=b);
	by Year County; 
	if a and b; 
run;

/**** STEP 9. Calculate crude rates and plot crude rate by county/year****/
data Rate_data; 
	set merge_pop; 
	rate= (n_visits/total_pop)* 10000; *Check population multiplier is correct for the outcome of interest;
run;


proc sgplot data=Rate_Data;
  hbox rate / category=year ;
  title "Crude Rate &outcome.-&dataname. visits by Year for &state. - New years v. archive years";
  xaxis label= "Crude Rate";
run;



/************************************************/
/*     Sample Percent Difference calculation    */
/************************************************/

/**** STEP 10. Sum events by stratification variables ****/


proc means data=New_Data noprint; 
	by Year County Sex Age;
	output out= Sum_strat (drop=_type_ _freq_) 
	sum(MonthlyHosp)= n_visits; 
run; 


/**** STEP 11. Pull 3 most recent years from archive and calculate the mean ****/

proc sql; 
	create table max as select max(Year) as max_year, State from Archive_Data; 
quit;
run;

data max; 
	merge Archive_Data max; 
	by State; 
run; 

data Archive_3year; 
	set max; 
	where Year >= (max_year - 2);
run;


**** Sum events by county and year ****;
proc means data= Archive_3year mean noprint; 
	by Couty Sex Age; 
	output out=Archive_strat (drop= _type_ _freq_)
	mean(MonthlyHosp)= archive_visits;
run;


/**** STEP 12: Merge current and archive data and calculate differences ****/
proc sort data=Sum_strat; 
	by County Sex Age; 
run;

proc sort data=Archive_strat; 
	by County Sex Age; 
run;

data total_strat; 
	merge Sum_strat Arvhive_Strat; 
	by county sex age; 
run; 

***** Calculate absolute difference and percent difference between archive and current data ****;
data Percent_diff; 
	set total_strat; 
	abs_diff= abs(archive_visits - n_visits); *absolute difference;
	percent_diff= (abs(Archive_visits - n_visits)/Archive_visits)*100; *percent difference;
run; 


/**** STEP 13: Print records with large difference and review output ****/
proc print data=pecent_diff; 
	where abs_diff > 8 and percent_diff >= 20; 
	title "Records with differences from archive";
run;

ods pdf close; 
quit;

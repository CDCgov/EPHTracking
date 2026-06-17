/*===================================================*/
/*                                                   */
/* Title: Hospitalization and ED data archive        */
/* validation checks                                 */
/* Provided by CDC's Environmental Public Health     */
/* Tracking (EPHT)Program                            */
/* Date created: 6/20/2019                           */
/* Description: Adaption of CDC EPHT validation       */
/* scripts                                           */
/*                                                   */
/* Source: Data Validation/Sample Validation         */
/*   Scripts/ArchiveCheck_Examples.sas (STEPs 4-9,    */
/*   the box-plot / crude-rate comparison of new vs   */
/*   archive years). STEP 2 OLEDB import replaced by  */
/*   New_Data/Archive_Data/Pop_Data in autoexec.sas.  */
/*===================================================*/

/**** STEP 1: Update macro variables for dataset of interest ****/
%let FolderLocation = .; /* Assign a folder location to send the output */
%let HealthOutcomeId = 1; /*1=Asthma, 2=AMI, 3=CO, 4=Heat, 5=COPD*/
%let HealthOutcome = Asthma;
%let Outcome = Asthma;
%let Dataname = Hospitalizations; /* Name of dataset Hospitalizations or Emergency Dept*/
%let StateName = Colorado; /*include your jurisdiction*/
%let State = Colorado;
%let DataCall = Fall2019; /*include data call information, if you wish to save for records*/


/**** STEP 2: Import data — see autoexec.sas (New_Data, Archive_Data, Pop_Data) ****/


/**** STEP 3. Route output to a pdf and set formats ****/

ods pdf body = "&FolderLocation./&StateName._&HealthOutcome._Hosp_&DataCall..pdf";


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
	by Year County;
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

ods pdf close;
quit;

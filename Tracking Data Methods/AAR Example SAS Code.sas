/*=============================================================================*/
/*                                                                             */
/* Title: Example Age-Adjusted Rate Calculation		                           */ 
/* Provided by CDC's Environmental Public Health Tracking (EPHT)Program        */
/* Date created: 11/21/2022                                                    */
/* Description: Adaption of CDC EPHT data processing scripts for calculating   */
/* age adjusted rates using Tracking data									   */
/*                                                                             */
/*=============================================================================*/


/******************** INSTRUCTIONS FOR USE  ************************/ 
* 1. Code is generic and needs to be adapted before use and is 
	written to validate one health outcome at a time;
* 2. Variable names assigned in this script are based on the 
    most recent Emergency Department (ED) visits data dictionary available in the GitHub repository;
* 3. Comments provided throughout the code offer guidance on interpreting 
	the output and updating for your data;
* 5. For questions about the provided code or how to use it,
	please contact Tracking Support (nephtrackingsupport@cdc.gov);
/*******************************************************************/


/**** STEP 1: Import data sets, analysis dataset and population data. For this example we are using Tracking Asthma Hospitalization 
data and census vintage population estimates ****/

*** Importing state count data and population data. Example using proc sql connection ***;

proc sql exec; 
  connect to oledb
     (init_string= /*database credentials*/ );

  	create table Count_Data as select * from connection to oledb
                                  	(select * from /*table name*/);

 	create table Population_Data as select * from connection to oledb
                                  	(select * from /*table name*/);
disconnect from oledb;
  quit;
run;

/*STEP 2: Sum count dataset to be merged with census, this example is summing at county level and year*/
*** Data use 5 year age bands 1-18, age breakdowns are consistent for both count and population data ***;

proc sort data=Count_data; 
	by countyfips statefips age year; 
run;


proc means noprint data=Count_data; 
	by countyfips statefips  age year;
	output out= Count_sum (drop=_type_ _freq_) 
	sum (&events) = n_count; 
run;


/*STEP 3: Sum census population dataset to be merged with count data, also summing by age, year and countyfips*/

proc sort data= Population_data; 
	by countyfips statefips age year; 
run;


proc means noprint data= population_data; 
	by countyfips statefips  age year;
	output out= population_sum (drop=_type_ _freq_) 
	sum (population_amt) = n_pop; 
run;


/*STEP 4: Merge datasets together by county, state, age and year */

data full; 	
	merge count_sum(in=a) population_sum(in=b); 
	by countyfips statefips age year ; 
run;



/*STEP 5: Create variable for age weights for 2000 standard population weights */

data aar_nat ;
set full;

where (AGE ne 19) ;

if AGE = 1  then Yr2000STDWT = 0.06913564962823250;
if AGE = 2  then Yr2000STDWT = 0.07253289833014120;
if AGE = 3  then Yr2000STDWT = 0.07303174406664870;
if AGE = 4  then Yr2000STDWT = 0.07216877735458830;
if AGE = 5  then Yr2000STDWT = 0.06647756650669620;
if AGE = 6  then Yr2000STDWT = 0.06452951928748810;
if AGE = 7  then Yr2000STDWT = 0.07104364354012980;
if AGE = 8  then Yr2000STDWT = 0.08076203237763710;
if AGE = 9  then Yr2000STDWT = 0.08185075409454040;
if AGE = 10 then Yr2000STDWT = 0.07211780041801090;
if AGE = 11 then Yr2000STDWT = 0.06271619682923450;
if AGE = 12 then Yr2000STDWT = 0.04845357821682680;
if AGE = 13 then Yr2000STDWT = 0.03879344873540790;
if AGE = 14 then Yr2000STDWT = 0.03426378379952960;
if AGE = 15 then Yr2000STDWT = 0.03177319632674760;
if AGE = 16 then Yr2000STDWT = 0.02699957033724880;
if AGE = 17 then Yr2000STDWT = 0.01784192780209300;
if AGE = 18 then Yr2000STDWT = 0.01550791234879880;
AgeBandId = Age;

run;



/*STEP 6: Create the crude rate and weighted rate variables by age */

data rate; 
	set AAR_nat; 

	rate= n_count/n_pop *10000; *crude age rate;
	wrate= (n_count/n_pop *10000)* Yr2000STDWT; *age weighted rate;
run; 


/*STEP 7: Sum age specific rates for the county specific AAR */

proc means data=rate; 
	by countyfips statefips year;
	output out= AAR (drop=_type_ _freq_) 
	sum (wrate) = AAR; *this variable is the county, state, year AAR;
run;





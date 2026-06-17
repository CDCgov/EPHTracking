/* autoexec for t001_aar_age_adjusted_rate
 *
 * Caps the run at OBS=100 for reproducibility, and stands up the two
 * source datasets the AAR script reads from a live OLEDB connection
 * (Count_Data, Population_Data). The mock data here is a small,
 * structurally faithful sample: 5-year age bands 1-18, two counties in
 * one state, two years. The age-adjustment logic, the 2000 standard
 * population weights, and the crude/weighted rate math in script.sas are
 * exactly as published by the CDC EPHT Program.
 */
options obs=100;

/* &events names the event-count column summed in STEP 2 of the script */
%let events = n_events;

/* Count_Data: state count data keyed by county/state/age/year */
data Count_Data;
  input countyfips statefips age year n_events;
  datalines;
1001 1 1 2018 12
1001 1 5 2018 31
1001 1 9 2018 27
1001 1 13 2018 18
1001 1 17 2018 9
1003 1 1 2018 22
1003 1 5 2018 44
1003 1 9 2018 38
1003 1 13 2018 25
1003 1 17 2018 14
1001 1 1 2019 15
1001 1 5 2019 29
1001 1 9 2019 33
1001 1 13 2019 20
1001 1 17 2019 11
1003 1 1 2019 19
1003 1 5 2019 41
1003 1 9 2019 36
1003 1 13 2019 28
1003 1 17 2019 16
;
run;

/* Population_Data: census vintage population estimates, same key */
data Population_Data;
  input countyfips statefips age year population_amt;
  datalines;
1001 1 1 2018 3100
1001 1 5 2018 5400
1001 1 9 2018 4800
1001 1 13 2018 4200
1001 1 17 2018 2600
1003 1 1 2018 6200
1003 1 5 2018 9800
1003 1 9 2018 8700
1003 1 13 2018 7900
1003 1 17 2018 5100
1001 1 1 2019 3150
1001 1 5 2019 5450
1001 1 9 2019 4850
1001 1 13 2019 4250
1001 1 17 2019 2650
1003 1 1 2019 6250
1003 1 5 2019 9850
1003 1 9 2019 8750
1003 1 13 2019 7950
1003 1 17 2019 5150
;
run;

/* autoexec for t004_archivecheck_boxplot
 *
 * Caps the run at OBS=100 and stands up the three datasets the archive
 * check reads from a live OLEDB connection: New_Data (the newly
 * submitted year), Archive_Data (previously submitted years), and
 * Pop_Data (population estimates). Columns follow the Hospitalization
 * data dictionary the script references: Year, County, State, Sex, Age,
 * MonthlyHosp (event counts) and Population_amount. The box-plot and
 * crude-rate logic in script.sas is exactly as published by the CDC
 * EPHT Program.
 */
options obs=100;

/* New_Data: newly submitted year of data */
data New_Data;
  length County $20 State $2 Sex $1;
  input Year County $ State $ Sex $ Age MonthlyHosp;
  datalines;
2021 Adams CO F 4 38
2021 Adams CO M 4 41
2021 Adams CO F 9 26
2021 Adams CO M 9 29
2021 Weld CO F 4 22
2021 Weld CO M 4 24
2021 Weld CO F 9 15
2021 Weld CO M 9 17
;
run;

/* Archive_Data: previously submitted years */
data Archive_Data;
  length County $20 State $2 Sex $1;
  input Year County $ State $ Sex $ Age MonthlyHosp;
  datalines;
2018 Adams CO F 4 31
2018 Adams CO M 4 34
2018 Adams CO F 9 21
2018 Adams CO M 9 24
2018 Weld CO F 4 18
2018 Weld CO M 4 20
2018 Weld CO F 9 12
2018 Weld CO M 9 14
2019 Adams CO F 4 33
2019 Adams CO M 4 36
2019 Adams CO F 9 23
2019 Adams CO M 9 26
2019 Weld CO F 4 19
2019 Weld CO M 4 22
2019 Weld CO F 9 13
2019 Weld CO M 9 15
2020 Adams CO F 4 35
2020 Adams CO M 4 38
2020 Weld CO F 4 20
2020 Weld CO M 4 23
;
run;

/* Pop_Data: population estimates by year/county */
data Pop_Data;
  length County $20;
  input Year County $ Population_amount;
  datalines;
2018 Adams 504000
2018 Weld 314000
2019 Adams 512000
2019 Weld 324000
2020 Adams 519000
2020 Weld 330000
2021 Adams 526000
2021 Weld 336000
;
run;

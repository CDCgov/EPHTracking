/* autoexec for t002_ed_validation
 *
 * Caps the run at OBS=100 and stands up the Validation dataset the ED
 * validation script reads from a live OLEDB connection. Columns follow
 * the Emergency Department (ED) data dictionary the script references:
 * HealthOutcomeID, State, County, EDVisitYear, EDVisitMonth, AgeGroup,
 * Sex, MonthlyVisits. A duplicate row pair is included so the duplicate
 * check (Check 3) has something to surface. All 14 validation checks in
 * script.sas are exactly as published by the CDC EPHT Program.
 */
options obs=100;

data Validation;
  length State $2 County $20 Sex $1;
  input HealthOutcomeID State $ County $ EDVisitYear EDVisitMonth
        AgeGroup Sex $ MonthlyVisits;
  datalines;
1 AZ Maricopa 2018 1 4 F 142
1 AZ Maricopa 2018 1 4 M 118
1 AZ Maricopa 2018 2 5 F 96
1 AZ Maricopa 2018 2 5 M 88
1 AZ Pima 2018 1 4 F 73
1 AZ Pima 2018 1 4 M 61
1 AZ Pima 2018 2 5 F 55
1 AZ Pima 2018 2 5 M 49
1 AZ Maricopa 2019 1 4 F 151
1 AZ Maricopa 2019 1 4 M 124
1 AZ Maricopa 2019 2 5 F 102
1 AZ Maricopa 2019 2 5 M 91
1 AZ Pima 2019 1 4 F 78
1 AZ Pima 2019 1 4 M 64
1 AZ Pima 2019 2 5 F 58
1 AZ Pima 2019 2 5 M 52
1 AZ Pima 2019 2 5 M 52
1 AZ Maricopa 2018 3 9 F 67
1 AZ Maricopa 2018 3 9 M 71
1 AZ Pima 2019 3 9 F 33
;
run;

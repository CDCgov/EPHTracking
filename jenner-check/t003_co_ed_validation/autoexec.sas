/* autoexec for t003_co_ed_validation
 *
 * Caps the run at OBS=100 and stands up the Validation dataset the CO
 * (carbon monoxide) ED validation script reads from a live OLEDB
 * connection. This script tracks CO poisoning, which carries three
 * cause counts in the data dictionary — IncidentCountFire,
 * IncidentCountNonFire, IncidentCountUnknown — in addition to
 * MonthlyVisits. Columns: HealthOutcomeID, State, County, EDVisitYear,
 * EDVisitMonth, AgeGroup, Sex, MonthlyVisits, IncidentCountFire,
 * IncidentCountNonFire, IncidentCountUnknown. The validation checks in
 * script.sas are exactly as published by the CDC EPHT Program.
 */
options obs=100;

data Validation;
  length State $2 County $20 Sex $1;
  input HealthOutcomeID State $ County $ EDVisitYear EDVisitMonth
        AgeGroup Sex $ MonthlyVisits
        IncidentCountFire IncidentCountNonFire IncidentCountUnknown;
  datalines;
3 CO Denver 2018 1 4 F 24 6 14 4
3 CO Denver 2018 1 4 M 31 9 18 4
3 CO Denver 2018 2 9 F 18 4 11 3
3 CO Denver 2018 2 9 M 22 7 12 3
3 CO Boulder 2018 1 4 F 12 3 7 2
3 CO Boulder 2018 1 4 M 15 5 8 2
3 CO Boulder 2018 2 9 F 9 2 6 1
3 CO Boulder 2018 2 9 M 11 3 7 1
3 CO Denver 2019 1 4 F 27 8 15 4
3 CO Denver 2019 1 4 M 33 10 19 4
3 CO Denver 2019 2 9 F 20 5 12 3
3 CO Denver 2019 2 9 M 25 8 14 3
3 CO Boulder 2019 1 4 F 14 4 8 2
3 CO Boulder 2019 1 4 M 17 6 9 2
3 CO Boulder 2019 2 9 F 10 3 6 1
3 CO Boulder 2019 2 9 M 13 4 8 1
;
run;

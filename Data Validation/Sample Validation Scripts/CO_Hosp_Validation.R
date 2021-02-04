###################################################################################################
#
# Title: CO Hospitalization Data Validation Checks
# Author: T.J. Pierce
# Date Created: 2/7/2020
# Description: Adaption of CDC EPHTN Validation scripts for use by recipients prior to submission.
#
###################################################################################################

######################### INSTRUCTIONS FOR USE ####################################################
#
# 1. Code is generic and needs to be adapted before use and is written
#    to validate one health out come at a time.
# 2. Variables names assigned in this script are based on the most recent
#    data dictionary available on the Sharepoint.
# 3. Refer to Validation framework and documentation for more information
#    on validation themes and their applications.
# 4. Please note the check numbering does not match with Battelle
#    provided reports.
# 5. Comments provided throughout the code offer guidance on
#    interpreting the output.
# 6. For questions about the provided code or how to use it,
#    please contact Tracking Support (nephtrackingsupport@cdc.gov).
#
###################################################################################################

###################################################################################################
#### STEP 1: Import Data ####

library("RODBC")
library("tidyverse")
library("dplyr")
library("pracma")
library("gmodels")

# First set up the ODBC connection:
# 1- go to start menu and type ODBC
# 2- A new window pops up called ODBC Data Source Administrator (32-bit). Click add
# 3- Scroll down to SQL Server and click that
# 4- Add a unique name for your connection
# 5- Description optional
# 6- Choose server. Click next
# 7- On the next screen click the second radio button, "With SAL server authentication...". Type in the server user ID and password.
# 8- Verify and connect. 
# more info here: https://support.microsoft.com/en-us/help/965049/how-to-set-up-a-microsoft-sql-server-odbc-data-source 

# connection string 
ch <- odbcConnect("", # unique name for connection (see step 4 above)
                  uid = "", # user ID
                  pwd = "") # password provided and updated by Battelle  

# data pull example
# Tier 2 ED Data 
Dataset_Name <-sqlQuery(ch, paste("SELECT *
                            FROM [].[].[]"))

###################################################################################################

###################################################################################################
#### STEP 2: Create Subset of Data for Outcome of Interest ####

Dataset_name <- subset(Dataset_Name, Dataset_Name$HEALTHOUTCOMEID== & Dataset_Name$STATE==)

# Format Categorical Variable

Dataset_name$AGEGROUP <- factor(Dataset_name$AGEGROUP)
levels(Dataset_name$AGEGROUP) <- c('0-4 Years', '5-9 Years', '10-14 Years', '15-19 Years', '20-24 Years', '25-29 Years', '30-34 Years', '35-39 Years', '40-44 Years', '45-49 Years', '50-54 Years', '55-59 Years', '60-64 Years', '65-69 Years', '70-74 Years', '75-79 Years', '80-84 Years', '85+ Years' )

###################################################################################################

###################################################################################################
#### STEP 3: Basic review of data, data cleaning (adpated gateway checks) ####
# These checks look for: Missing/Invalid Values, Improper Structure, Duplicates

# Check data for expected variables based on data dictionary and schema

str(Dataset_name)

# Check for duplicates

Hosp_dup <- cbind(Dataset_name, Dataset_name$STATE, Dataset_name$HEALTHOUTCOMEID, Dataset_name$COUNTY, Dataset_name$YEARADMITTED, Dataset_name$ADMISSIONMONTH, Dataset_name$AGEGROUP, Dataset_name$SEX)
Check_3 <- as.matrix(duplicated(Hosp_dup))
sum(Check_3)

###################################################################################################

###################################################################################################
#### STEP 4: Strange Pattern Check ####
# This check looks for all even or odd records, all even records need to be investigated

Check_4 <- as.matrix(with(Dataset_name, MONTHLYHOSP%%2==0 | INCIDENTCOUNTFIRE%%2==0 | INCIDENTCOUNTNONFIRE%%2==0 | INCIDENTCOUNTUNKNOWN%%2==0))

#Summing provides the total # of evens and summing all zeros provides total # of odds.
sum(Check_4)
sum(Check_4==0)

###################################################################################################

###################################################################################################
#### STEP 5: Lack or Excess of Data/Record Level Checks ####
# These checks look at data on the record level, lower/higher numbers of records than expected 
# need to be confirmed

# Number of Total Records by Year

Check_5 <- Dataset_name %>% group_by(YEARADMITTED) %>% tally(name="Records")

# Number of Counties Reported

Check_6 <- Dataset_name %>% group_by(YEARADMITTED) %>% distinct(COUNTY) %>% tally(name="Counties")

# Number of Records per County

Check_7 <- Dataset_name %>% group_by(COUNTY) %>% tally(name="Frequency")

# Frequency by CO Cause

Check_8a <- Dataset_name %>% group_by(INCIDENTCOUNTFIRE) %>% tally(name="Frequency")

Check_8b <- Dataset_name %>% group_by(INCIDENTCOUNTNONFIRE) %>% tally(name="Frequency")

Check_8c <- Dataset_name %>% group_by(INCIDENTCOUNTUNKNOWN) %>% tally(name ="Frequency")

# Frequency and Percent Records by Age Groups

Check_9 <- as.matrix(CrossTable(Dataset_name$AGEGROUP,Dataset_name$YEARADMITTED, digits=2, prop.r = FALSE, prop.c = TRUE, prop.t = FALSE, prop.chisq = FALSE))

# Frequency and Percent Records by Gender

Check_10 <- as.matrix(CrossTable(Dataset_name$SEX, Dataset_name$YEARADMITTED, digits = 2, prop.r = FALSE, prop.c = TRUE, prop.t = FALSE, prop.chisq = FALSE))

###################################################################################################

###################################################################################################
#### STEP 6: Outliers and Inconsistencies - Values ####
# These checks look at the number of/sum of admissions

# Sum of Visits by Year and Cause

Check_11a <- Dataset_name %>% group_by(YEARADMITTED) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_11b <- Dataset_name %>% group_by(YEARADMITTED) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_11c <- Dataset_name %>% group_by(YEARADMITTED) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

# Sum of Visits by County and Cause

Check_12a <- Dataset_name %>% group_by(YEARADMITTED, COUNTY) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_12b <- Dataset_name %>% group_by(YEARADMITTED, COUNTY) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_12c <- Dataset_name %>% group_by(YEARADMITTED, COUNTY) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_12d <- Dataset_name %>% group_by(YEARADMITTED, COUNTY) %>% summarise(sum(MONTHLYHOSP))

# Sum of Admissions by Cause and Sex

Check_13a <- Dataset_name %>% group_by(YEARADMITTED, SEX) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_13b <- Dataset_name %>% group_by(YEARADMITTED, SEX) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_13c <- Dataset_name %>% group_by(YEARADMITTED, SEX) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_13d <- Dataset_name %>% group_by(YEARADMITTED, SEX) %>% summarise(sum(MONTHLYHOSP))

# Sum of Events by Age Group

Check_14a <- Dataset_name %>% group_by(YEARADMITTED, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_14b <- Dataset_name %>% group_by(YEARADMITTED, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_14c <- Dataset_name %>% group_by(YEARADMITTED, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_14d <- Dataset_name %>% group_by(YEARADMITTED, AGEGROUP) %>% summarise(sum(MONTHLYHOSP))

###################################################################################################

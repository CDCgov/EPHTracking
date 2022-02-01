###################################################################################################
#
# Title: CO Emergency Dept data validation checks
# Provided by CDC's Environmental Public Health Tracking (EPHT) Program
# Date Created: 2/4/2020
# Description: Adaption of CDC EPHT validation scripts.
#
###################################################################################################

######################### INSTRUCTIONS FOR USE ####################################################
#
# 1. Code is generic and needs to be adapted before use and is written
#    to validate one health outcome at a time.
# 2. Variable names assigned in this script are based on the most recent Emergency
#    Department (ED) visits data dictionary available in the GitHub repository.
# 3. Refer to Validation protocol and documentation for more 
#    information on validation themes and their applications.
# 4. Comments provided throughout the code offer guidance on 
#    interpreting the output.
# 5. For questions about the provided code or how to use it,
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
# 6- Choose server. Click next.
# 7- On the next screen click the second radio button, "With SAL server authentication...". Type in the server user ID and password
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

DATASET_NAME <- subset(Dataset_Name, Dataset_Name$HEALTHOUTCOMEID== & Dataset_Name$STATE==)

# Format Categorical Variable

DATASET_NAME$AGEGROUP <- factor(DATASET_NAME$AGEGROUP)
levels(DATASET_NAME$AGEGROUP) <- c('0-4 Years', '5-9 Years', '10-14 Years', '15-19 Years', '20-24 Years', '25-29 Years', '30-34 Years', '35-39 Years', '40-44 Years', '45-49 Years', '50-54 Years', '55-59 Years', '60-64 Years', '65-69 Years', '70-74 Years', '75-79 Years', '80-84 Years', '85+ Years' )

###################################################################################################

###################################################################################################
#### STEP 3: Basic review of data, data cleaning (adapted gateway checks) ####
# These checks look for: Missing/Invalid values, Improper Structure, Duplicates

# Check data for expected variables based on data dictionary and schema

str(DATASET_NAME)

# Check for duplicates

CO_dup <- cbind(DATASET_NAME, DATASET_NAME$STATE, DATASET_NAME$HEALTHOUTCOMEID, DATASET_NAME$COUNTY, DATASET_NAME$EDVISITYEAR, DATASET_NAME$EDVISITMONTH, DATASET_NAME$AGEGROUP, DATASET_NAME$SEX)
Check_3 <- as.matrix(duplicated(CO_dup))
sum(Check_3)

###################################################################################################

###################################################################################################
#### STEP 4: Strange Pattern Check ####
# This check looks for all even or odd records, all even records needs to be investigated

even <- as.matrix(with(DATASET_NAME, MONTHLYVISITS%%2==0 | INCIDENTCOUNTFIRE%%2==0 | INCIDENTCOUNTNONFIRE%%2==0 | INCIDENTCOUNTUNKNOWN%%2==0))
sum(even)

###################################################################################################

###################################################################################################
#### STEP 5: Lack or excess of data/record level checks ####
# These checks look at data on the record level, lower/higher number of records than expected need to 
# be confirmed

# Number of Total Records by Year

Check_5 <- DATASET_NAME %>% group_by(EDVISITYEAR) %>% tally(name="Records")

# Number of Counties Reported

Check_6 <- DATASET_NAME %>% group_by(EDVISITYEAR) %>% distinct(COUNTY) %>% tally(name="Counties")

# Number of Records per County

Check_7 <- DATASET_NAME %>% group_by(COUNTY) %>% tally(name="Frequency")

# Frequency by CO Cause

Check_8a <- DATASET_NAME %>% group_by(INCIDENTCOUNTFIRE) %>% tally(name="Frequency")

Check_8b <- DATASET_NAME %>% group_by(INCIDENTCOUNTNONFIRE) %>% tally(name="Frequency")

Check_8c <- DATASET_NAME %>% group_by(INCIDENTCOUNTUNKNOWN) %>% tally(name ="Frequency")

# Frequency and Percent Records by Age Groups

Check_9 <- as.matrix(CrossTable(DATASET_NAME$AGEGROUP,DATASET_NAME$EDVISITYEAR, digits=2, prop.r = FALSE, prop.c = TRUE, prop.t = FALSE, prop.chisq = FALSE))

# Frequency and Percent Records by Gender

Check_10 <- as.matrix(CrossTable(DATASET_NAME$SEX, DATASET_NAME$EDVISITYEAR, digits = 2, prop.r = FALSE, prop.c = TRUE, prop.t = FALSE, prop.chisq = FALSE))

###################################################################################################

###################################################################################################
#### STEP 6: Outliers and Inconsistencies - Values ####
# These checks look at the number/sum of admissions

# Sum of Visits by Year and Cause

Check_11a <- DATASET_NAME %>% group_by(EDVISITYEAR) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_11b <- DATASET_NAME %>% group_by(EDVISITYEAR) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_11c <- DATASET_NAME %>% group_by(EDVISITYEAR) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

# Sum of Visits by County and Cause

Check_12a <- DATASET_NAME %>% group_by(EDVISITYEAR, COUNTY) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_12b <- DATASET_NAME %>% group_by(EDVISITYEAR, COUNTY) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_12c <- DATASET_NAME %>% group_by(EDVISITYEAR, COUNTY) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_12d <- DATASET_NAME %>% group_by(EDVISITYEAR, COUNTY) %>% summarise(sum(MONTHLYVISITS))

# Sum of Admissions by Cause and Sex

Check_13a <- DATASET_NAME %>% group_by(EDVISITYEAR, SEX) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_13b <- DATASET_NAME %>% group_by(EDVISITYEAR, SEX) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_13c <- DATASET_NAME %>% group_by(EDVISITYEAR, SEX) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_13d <- DATASET_NAME %>% group_by(EDVISITYEAR, SEX) %>% summarise(sum(MONTHLYVISITS))

# Sum of Events by Age Group

Check_14a <- DATASET_NAME %>% group_by(EDVISITYEAR, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTFIRE))

Check_14b <- DATASET_NAME %>% group_by(EDVISITYEAR, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTNONFIRE))

Check_14c <- DATASET_NAME %>% group_by(EDVISITYEAR, AGEGROUP) %>% summarise(sum(INCIDENTCOUNTUNKNOWN))

Check_14d <- DATASET_NAME %>% group_by(EDVISITYEAR, AGEGROUP) %>% summarise(sum(MONTHLYVISITS))

###################################################################################################

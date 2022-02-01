###################################################################################################
#
# Title: Emergency Dept Data Validation Checks
# Provided by CDC's Environmental Public Health Tracking (EPHT) Program.
# Data Created: 1/15/2020
# Description: Adaption of CDC EPHT validation scripts.
#
###################################################################################################

######################### INSTRUCTIONS FOR USE ####################################################
#
# 1. Code is generic and needs to be adapted before use and is written
#    to validate one health outcome at a time.
# 2. Variable names assigned in this script are based on the most recent Emergency
#    Department (ED) data dictionary available in the GitHub repository.
# 3. Refer to validation protocol and documentation for more 
#    information on validation themes and their applications.
# 4. Comments provided throughout the code offer guidance on 
#    interpreting the output.
# 5. For questions about the provided code or how to use it,
#    please contact Tracking Support (nephtrackingsupport@cdc.gov).
#
###################################################################################################

#### STEP 1: Import DATA
# Install/Load Necessary Packages

library("RODBC")
library("tidyverse")
library("dplyr")
library("pracma")
library("gmodels")

# First set up the ODBC connection:
# 1- go to start menu and type ODBC
# 2- A new window pops up called ODBC Data Source Administrator (32-bit). Click add
# 3- Scroll down to SQL Server and click that
# 4- Add a unique name for your connection.
# 5- Description optional
# 6- choose server. Click next
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
#### StEP 2: Create Subset of Data for outcome of Interest

Dataset_Name <- subset(Dataset_Name, Dataset_Name$HEALTHOUTCOMEID== & Dataset_Name$STATE==)

# Format Categorical Variables

Dataset_Name$AGEGROUP <- factor(Dataset_Name$AGEGROUP)
levels(Dataset_Name$AGEGROUP) <- c('0-4 Years', '5-9 Years', '10-14 Years', '15-19 Years', '20-24 Years', '25-29 Years', '30-34 Years', '35-39 Years', '40-44 Years', '45-49 Years', '50-54 Years', '55-59 Years', '60-64 Years', '65-69 Years', '70-74 Years', '75-79 Years', '80-84 Years', '85+ Years' )

###################################################################################################

###################################################################################################
#### STEP 3: Basic Review of data, data cleaning (adapted gateway check) ####
# These checks look for: Missing/Invalid Values, Improper Structure, Duplicates 

# Check data for expected variables based on data dictionary and schema

str(Dataset_Name)

# Check for duplicates

ED_dup <- cbind(Dataset_Name, Dataset_Name$STATE, Dataset_Name$HEALTHOUTCOMEID, Dataset_Name$COUNTY, Dataset_Name$EDVISITYEAR, Dataset_Name$EDVISITMONTH, Dataset_Name$AGEGROUP, Dataset_Name$SEX)
Check_3 <- as.matrix(duplicated(ED_dup))
sum(Check_3)

###################################################################################################

###################################################################################################
#### STEP 4: Strange Pattern Check ####
# This check looks for all even or odd records,all even records needs to be investigated

Check_4 <- as.matrix(Dataset_Name, MONTHLYVISITS%%2==0)

#Summing provides the total of the evens and summing the zeros provides the total of the odds

sum(Check_4)
sum(Check_4==0)

###################################################################################################

###################################################################################################
#### STEP 5: Lack or Excess of Data/Record Level Checks ####
# These checks look at data on the record level, lower, higher number of records than expected need to 
# be confirmed

# Number of Total Records by Year

Check_5 <- Dataset_Name %>% group_by(EDVISITYEAR) %>% tally(name="Records")

# Number of Counties Reported

Check_6 <- Dataset_Name %>% group_by(EDVISITYEAR) %>% distinct(COUNTY) %>% tally(name = "Counties")

# Number of Records per County

Check_7 <- Dataset_Name %>% group_by(COUNTY) %>% tally(name="Records")

# Frequency and Percent Records by Age Groups

Check_8 <- as.matrix(CrossTable(Dataset_Name$AGEGROUP,Dataset_Name$EDVISITYEAR, digits = 2, prop.r = FALSE, prop.c = TRUE, prop.t = FALSE, prop.chisq = FALSE))

# Frequency and Percent Records by Gender

Check_9 <- as.matrix(CrossTable(Dataset_Name$SEX, Dataset_Name$EDVISITYEAR, digits=2, prop.r = FALSE, prop.c=TRUE, prop.t=FALSE, prop.chisq = FALSE))

###################################################################################################

###################################################################################################
#### STEP 6: Outliers and Inconsistencies - Values ####
# These checks look at the number/sum of admissions 

Check_10 <- Dataset_Name %>% group_by(EDVISITYEAR) %>% summarise(sum(MONTHLYVISITS))

# Sum of events by County/year

Check_11 <- Dataset_Name %>% group_by(EDVISITYEAR, COUNTY) %>% summarise(sum(MONTHLYVISITS))

# Sum of events by County/Month/Year

Check_12 <- Dataset_Name %>% group_by(EDVISITYEAR, EDVISITMONTH, COUNTY) %>% summarise(sum(MONTHLYVISITS))

# Sum of events by age group

Check_13 <- Dataset_Name  %>% group_by(EDVISITYEAR, AGEGROUP) %>% summarise(sum(MONTHLYVISITS))

# Sum of Events by Gender/Year

Check_14 <- Dataset_Name %>% group_by(EDVISITYEAR, SEX) %>% summarise(sum(MONTHLYVISITS))


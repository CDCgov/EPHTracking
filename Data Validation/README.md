# Data Management and Validation Methods <img src="EPHTracking/Tracking_Graphic.jpg" align="right" height=140/>

This folder contains resources and code for the Tracking Program’s data validation process. All data undergo a thorough validation process before being accepted into the Tracking Network. The Tracking Program uses a series of data quality checks to identify potential errors in the raw datasets they receive, including the data submitted to Tracking from state constituents. The validation process primarily looks to identify unusual patterns, missing or excess data, outliers, or other inconsistencies within the dataset that may impact data quality. For further information on the Tracking Network’s validation methods and themes, please see the [Data Validation Protocol](https://github.com/CDCgov/EPHTracking/blob/master/Data%20Validation/TrackingValidationProtocol_2021.pdf) file. 

Sample R and SAS scripts for data validations are currently available for several tracking datasets. Once the dataset has been loaded into the statistical software, the scripts will run the series of data validation checks. The codes are written for the validation of Tracking Network datasets based on the provided data dictionaries; however, these data quality checks can be adapted and applied to other similar datasets. For information about the Tracking Network’s datasets and measure calculation, please visit the folder [Measure Creation and Calculation](https://github.com/CDCgov/EPHTracking/tree/master/Measure%20Creation) in the main repository. 

## Additional Resources: 

* [SAS: Analytics, Artificial Intelligence and Data Management | SAS](https://www.sas.com/en_us/home.html)

* [R: The R Project for Statistical Computing (r-project.org)](https://www.r-project.org/)
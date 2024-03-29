# Geoshifting #
In 2016, the Tracking Program introduced a feature related to census tract-level data called Geoshifting. Geoshifting allows Tracking’s Data Explorer to show changes in data over time as they relate to changes in census tract boundaries over time. The Data Explorer uses the following rules for displaying census tract data.

## Default Rules ##
- Maps of census tract data with years 2020 and later use 2020 census tract boundaries. 
- Maps of census tract data with years 2015 to 2019 use 2015 census tract boundaries. 
- Maps of census tract data with years 2010 to 2014 use 2010 census tract boundaries. 
- Maps of census tract data with years prior to 2010 use 2010 census tract boundaries. 

## Special Rules ##
Sometimes the Tracking Program receives data from partners that have not been coded using the default rules listed above. When this happens, the Tracking Program uses one of the following special rules instead. 
- Match census tract boundaries with the dataset year (e.g., If a dataset has data from 2019 and earlier, but everything has been geocoded to 2020 and later, the special rule would allow the data to be displayed using the 2020 boundaries.)
- Use a geographic ID crosswalk table to adjust the data to fit the census tract boundaries

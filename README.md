## YEG Residential Property Analysis Part 1 - Neighbourhoods

This repository holds the codes and queries from the project "YEG Residential Property Analysis Part 1 - Neighbourhoods". <br>
<br>
This project analyzes the properties in the City of Edmonton AB, Canada to answer the questions below and share insights:
- What are the Top 20 biggest neighbourhoods in the city in 2021?
- What are the average and median assessed property values in these neighbourhoods?
- How have the property values in these neighbourhoods changed over the last 10 years?

### Data source 
1) dbo.pro_historical (downloaded on Jan 18, 2022):
https://data.edmonton.ca/City-Administration/Property-Assessment-Data-Historical-/qi6a-xuwt
2) dbo.neighbourhoods (downloaded on Mar 23, 2022): 
https://data.edmonton.ca/City-Administration/City-of-Edmonton-Neighbourhoods/65fr-66s6
3) dbo.geom (downloaded on Mar 25, 2022):
https://data.edmonton.ca/dataset/Neighbourhood-Boundaries-2019/xu6q-xcmj

### Table Summary

|               			| Data Collection Period | Column Count | Row Count (excl. heading)	|
|:---:|:---:|:---:|:---:|
| dbo.pro_historical  |		    2012-2021		     |		  21      |          3,798,629        |
| dbo.neighbourhoods	|		    2011-2022		     |	    7       |			        401       		|
| dbo.geom			      |		      2019			     |		  4	      |			        399			      |


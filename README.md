## YEG Residential Property Analysis Part 1 - Neighbourhoods

This repository holds the code and queries from the project "YEG Residential Property Analysis Part 1 - Neighbourhoods". <br>
<br>
[![Windermere-trail-2.jpg](https://i.postimg.cc/pLrCMbK9/Windermere-trail-2.jpg)](https://postimg.cc/FYt306Wm)
<br>(Image source: https://www.edmontonrealestate.pro/southwest-edmonton/windermere.php)
<br>
### Why?
With the wild fluctuations we've seen this year (2022) it is difficult to know what the "real" value of a property is. Looking at historical trends can give us a better idea of how much properties in an area are worth. Looking long term, the fluctuations should even out (right?). As I was house hunting, I wanted to look at the historical data for different neighbourhoods in the city of Edmonton. The larger, more popular neighbourhoods have more amenities suitable for a growing family like my own, but can also busier and more expensive.
<br>
<br>**In Part 1, we look into Top 20 largest neighbourhoods in the city.** In Part 2, we focus on the Zone 55 of the city and analyze the properties on MLS ([Multiple Listing Service](https://www.nar.realtor/nar-doj-settlement/multiple-listing-service-mls-what-is-it)) listing to gain insights.<br>
<br>
Some of the questions I wanted to look at in this analysis are:
- What are the Top 20 biggest neighbourhoods in the city in 2021?
- What are the average and median assessed property values in these neighbourhoods?
- How have the property values in these neighbourhoods changed over the last 10 years?

I visualized these data in Tableau. You can see it [here](https://public.tableau.com/app/profile/emily1078/viz/shared/RWM27BD4D).

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
| dbo.neighbourhoods	|		    2011-2022		     |	    7       |			        410       		|
| dbo.geom			      |		      2019			     |		  4	      |			        404			      |

import pandas as pd
from pathlib import Path 

# read the file
neighbourhoods = pd.read_csv('C:\\...\\City_of_Edmonton_-_Neighbourhoods.csv')

# check the dataframe
neighbourhoods.head()

# select the needed columns
neighbourhoods = neighbourhoods[['Descriptive Name', 'Geometry Multipolygon']]

# check the updated dataframe
neighbourhoods.head()

# export the dataframe as a CSV file
filepath = Path('C:\\...\\neighbourhoods.csv')
neighbourhoods.to_csv(filepath, index = False)

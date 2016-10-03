# AV Ultimate Student Hunt
This set of scripts is my solution for the Ultimate Student Hunt Challenge from Analyics Vidhya. With this analytic solution I was able to take the first place on the private leaderboard. The machine learning problem itself was regression based on panel data with daily frequency.

## Data cleaning
### Functions in the data cleaner
There are three customly defined functions in the data cleaning script these are:

1. The feature name normalizer -- this removes dots and capital letters.

2. The hot-one-encoder -- this attaches dummies to an existing dataframe based on vector of possible values that a certain column might take.

3. The data munger -- this function is the actual data cleaner.

### The baseline data cleaning process itself
As a first step I normalized the feature names in the table -- capital letters can only lead to problems. During the baseline data cleaning process I included the following features:

* The park identifier is hot one encoded -- it is interesting that the train and test samples are different in this regard there is a park that is only present in one of them. This step used the hot-one encoder.
* The day variable cannot be used for extracting variables with *lubridate*, so I generated a new day variable. This new variable has the name monkey day.
* Based on this day of week (1-7), day of month(1-31) and day of year can be generated -- it has to be emhasized that the day of year variable in itself leads to low test set performance if the missing values are not treated properly. I will elaborate on this statement later.
* Monthly dummiy features are also extracted. Here the hot one encoder is used again.
* The exogenous weather features are extracted as they are -- I did not differentiate them I assumed that on yearly basis stationarity is satisfied. 
* Based on the weather features I calculated moving window means and standard deviation values. Also I used minimum and maximum values for these variables. These variables capture local tendencies in the data and they also deal with the high frequncy noise in the data.
* The location type variable is encoded with  binary features.

With these variables (if day of year was excluded) and model stacking (extreme gradient boosting) one could have a solid 106 root mean squared error on the public leaderboard.

### 




# Introduction

 (This is a practical application of data science on [this](https://archive.ics.uci.edu/ml/datasets/PM2.5+Data+of+Five+Chinese+Cities) dataset provided by UCI.)
 
PM<sub>2.5</sub> can be used as a metric for gauging air pollution. It is defined as the concentration of fine 
particles with a diameter of ≤ 2.5 μm. These particles cause detrimental health and environmental effects and are the reason air pollution is dangerous. By analyzing the dataset, it can be determined how PM<sub>2.5</sub> levels in Shanghai are changing and how these levels are correlated with different weather metrics.  Other data analysis can also be performed, such as viewing PM<sub>2.5</sub> and weather distributions in addition to visualizing monthly/seasonal changes. By creating a time series and applying a forecasting model on it, the change of PM<sub>2.5</sub> over time can be seen. China has heavily invested in renewable energy recently, so it will be interesting to see the effects of its efforts.

 ## Dataset
 
 Each row corresponds to a measurement for PM<sub>2.5</sub> along with the date and time it was taken. The following weather metrics are provided:
 
* PM<sub>2.5</sub> (μg/m<sup>3</sup>)
* % Humidity  
* Pressure (hPa) 
* Cbwd (wind direction)
* Temperature (°C) 
* Wind speed (m/s) 
* Hourly Precipitation (mm)
* Daily cumulative precipifation (mm)  

Measurements were taken hourly over a period of 6 years. PM<sub>2.5</sub> measurements were missing for 2010 and 2011 so only years 2012 and beyond were considered. All attributes are numerical except for cbwd.

 ## Correlations

Missing values were replaced with the respective modes for each attribute. Outliers were not removed because these can be the nature of the dataset. 

### R provides a powerful platform for data visualization (see [ggplot2](https://www.statmethods.net/advgraphs/ggplot2.html)):
<br />

![Distribution of PM2.5](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/pm_dist.png?raw=true)

![Distribution of Temperature](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/temp_dist.png?raw=true)

![Boxplot Distribution of PM2.5](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/bp.png?raw=true)

### How are PM<sub>2.5</sub> levels changing throughout the months and seasons?
<br />
<br />
<br />

![Monthly](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/monthly.png?raw=true)

![Seasonal](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/seasonal.png?raw=true)

### Are there any correlations between weather metrics?

````R
[1] "DEWP & PRES"
[1] -0.8576494
[1] "DEWP & TEMP"
[1] 0.883808
[1] "PRES & TEMP"
[1] -0.8396896
````

(output of only those combinations that are strongly correlated: If positive, R >= 0.70. If negative, R <= -0.70)

![Dewpoint vs. Pressure](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/dew_pressure.png?raw=true)

![Dewpoint vs. Temperature](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/dew_temp.png?raw=true)

![Pressure vs. Temperature](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/pressure_temp.png?raw=true)

<br />

Finding the relationship between wind speed and PM<sub>2.5</sub> is different. The proportion of the variance in the dependent variable that is predicted from the independent variable was found. Its square root gives R, which represents the correlation between the observed and predicted PM<sub>2.5</sub> (where the predicted PM<sub>2.5</sub> values are the mean PM<sub>2.5</sub> for each of the five wind direction groups: static, NW, NE, SE, and SW. One way ANOVA gives the same results. [This](https://stats.stackexchange.com/questions/119835/correlation-between-a-nominal-iv-and-a-continuous-dv-variable/124618#124618) post explains it in detail.

![R squared](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/rsquared.png?raw=true)

````R
Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)   77.275      1.145  67.498  < 2e-16 ***
data$cbwdNE  -33.679      1.201 -28.041  < 2e-16 ***
data$cbwdNW    1.412      1.256   1.124    0.261    
data$cbwdSE  -32.647      1.219 -26.788  < 2e-16 ***
data$cbwdSW   -8.910      1.321  -6.747 1.54e-11 ***
````

This means:

* Average PM<sub>2.5</sub> for static wind is 77.28 μg/m<sup>3</sup>
* Average PM<sub>2.5</sub> for NE wind is 33.68 μg/m<sup>3</sup> less than it is for static wind.
* Average PM<sub>2.5</sub> for NW wind is 1.41 μg/m<sup>3</sup> more than it is for static wind.
* Average PM<sub>2.5</sub> for SE wind is 32.65 μg/m<sup>3</sup> less than it is for static wind.
* Average PM<sub>2.5</sub> for NW wind is 8.91 μg/m<sup>3</sup> less than it is for static wind.

### Visualized:

![Wind Distribution](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/wind_dist.png?raw=true)

### Verify that results from multiple regression and ANOVA are equivalent:

R (multiple regression) = ````[1] 0.3369611````

R (ANOVA) = ````data$cbwd     0.3369611````

## Time Series Forecasting


![Time Series Plot](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/ts.png?raw=true)

![Decomposition](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/decomp.png)

![Forecasting](https://github.com/ammarzia/pm2.5-shanghai/blob/master/graphs/forecast.png?raw=true)

(more info [here](https://www.statmethods.net/advstats/timeseries.html))



### Source:

 * [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/PM2.5+Data+of+Five+Chinese+Cities)

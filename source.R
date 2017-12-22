# Libraries 

library(magrittr)
library(lubridate)
library(dplyr)
library(forecast)
library(ggfortify)
library(ggplot2)
library(heplots)
library(zoom)

# Loads data (2012+).
input = read.csv(file = "data/ShanghaiPM20100101_20151231.csv", header = TRUE)
data = tail(input, -17520)

# Finds average PM2.5 for each measurement.
data$PM_AVG <- rowMeans(data[,7:9], na.rm = TRUE)

# Generates datetime.
data <- data %>% mutate(date = make_date(year, month, day), datetime = make_datetime(year, month, day, hour)) %>% arrange(datetime)

# Function for finding mode.
Mode <- function(x) {
  ux <- na.omit(unique(x) )
  tab <- tabulate(match(x, ux)); ux[tab == max(tab) ]
}

# Fills missing values with modes of that attribute.
for (i in 10:18) {
  data[is.na(data[,i]),i] <- Mode(data[,i])
}

# Distribution plots
print(ggplot(data, aes(data[, 18])) + 
        geom_histogram(binwidth = 2, fill = "#9999ff") + 
        labs(x = expression(paste(PM[2.5], "  ", mu*"g/", m^3))) +
        labs(title = (expression(paste("Distribution of ", PM[2.5])))) + 
        theme(plot.title = element_text(hjust = .5)))

print(ggplot(data, aes(data[, 13])) + 
        geom_histogram(binwidth = 2, fill = "#FF9999", colour = "black") + 
        labs(x = expression(paste("Temperature ","("*degree*C,")"))) +
        labs(title = "Distribution of Temperature") +
        theme(plot.title = element_text(hjust = .5)))

# Boxplot
boxplot(data$PM_AVG, ylab = (expression(PM[2.5], "  ", mu*"g/", m^3)), 
        main = (expression(paste("Boxplot Distribution of ", PM[2.5]))),
        col = c('#95ff97'),
        whiskcol=c("#0ab60d"), 
        staplecol=c("#0ab60d"),  
        boxcol=c("#0ab60d"),  
        medcol=c("#0ab60d"), 
        outcol=c("#0ab60d"), 
        outbg=c("#0ab60d"), 
        outcex = .5, outpch = 21)

# Correlation between all attributes.
for(i in 10:18) {
  for(j in (i + 1):18) {
    if(j <= 18 & j > i & !is.factor(data[,i]) & !is.factor(data[,j])) {
      print(paste(colnames(data)[i], "&", colnames(data)[j], sep = " "))
      print(cor(data[,i], data[,j])) 
    }
  }
}

# Only prints graphs for those variable pairs that are strongly correlated...
 ################# 
 # STRONGLY CORRELATED (If positive, R >= 0.70. If negative, R <= -0.70) 
 ################# 
# Dewpoint and Pressure
print(ggplot(data, aes(data[,10], data[,12])) + 
        geom_point() + 
        xlab(expression(paste("Dewpoint ","("*degree*C,")"))) +
        ylab("Pressure (hPa)") +
        ggtitle("Dewpoint vs. Pressure")  +
        theme(plot.title = element_text(hjust = 0.5)))
# Dewpoint and Temperature
print(ggplot(data, aes(data[,10], data[,13])) + 
        geom_point() + 
        xlab(expression(paste("Dewpoint ","("*degree*C,")"))) +
        ylab(expression(paste("Temperature ","("*degree*C,")"))) +
        ggtitle("Dewpoint vs. Temperature")  +
        theme(plot.title = element_text(hjust = 0.5)))
# Pressure and Temperature
print(ggplot(data, aes(data[,12], data[,13])) + 
        geom_point() + 
        xlab("Pressure (hPa)") +
        ylab(expression(paste("Temperature ","("*degree*C,")"))) +
        ggtitle("Pressure vs. Temperature")  +
        theme(plot.title = element_text(hjust = 0.5)))
 #################

 #################
# No strong correlation between PM2.5 and any other variable! (If positive, R <= 0.30. If negative, R >= -0.30)
print("No correlation:")
print(paste("PM2.5 and DEWP", cor(data$PM_AVG, data[, 10])))
print(paste("PM2.5 and HUMI", cor(data$PM_AVG, data[, 11])))
print(paste("PM2.5 and PRES", cor(data$PM_AVG, data[, 12])))
print(paste("PM2.5 and TEMP", cor(data$PM_AVG, data[, 13])))
print(paste("PM2.5 and IWS", cor(data$PM_AVG, data[, 15])))
print(paste("PM2.5 and PRECIPITATION", cor(data$PM_AVG, data[, 16])))
print(paste("PM2.5 and IPREC", cor(data$PM_AVG, data[, 17])))
 #################

# Monthly and seasonal PM2.5 Changes.
data$quality <- ifelse(data$PM_AVG <= 50, "Good", ifelse(data$PM_AVG <= 100, "Moderate", ifelse(data$PM_AVG <= 300, "Unhealthy", "Hazardous")))

monthly<- data %>% 
  group_by(month, quality) %>%
  count() %>% 
  as_tibble()

seasonal<- data %>%
  group_by(season, quality) %>%
  count() %>%
  as_tibble()

print(ggplot(monthly, aes(x = factor(month), y = n, fill = factor(quality, c("Good", "Moderate", "Unhealthy", "Hazardous")))) + geom_bar(stat = 'identity', position = 'dodge') +
    theme(legend.title = element_blank()) +
    ylab("Number of Days") +
    xlab("Month") +
    scale_x_discrete(labels = month.abb) + 
    ggtitle(expression(paste("Monthly ", PM[2.5], " Changes")))  +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_fill_manual("legend", values = c("Good" = "#54B850", "Moderate" = "#F1ED3E", "Unhealthy" = "#EA212A", "Hazardous" = "#7C2B7A" )))

print(ggplot(seasonal, aes(x = factor(season), y = n, fill = factor(quality, c("Good", "Moderate", "Unhealthy", "Hazardous")))) + geom_bar(stat = 'identity', position = 'dodge')+
  theme(legend.title = element_blank()) +
  ylab("Number of Days") +
  xlab("Season") +
  scale_x_discrete(labels = c("Spring", "Summer", "Fall", "Winter")) +
  ggtitle(expression(paste("Seasonal ", PM[2.5], " Changes")))  +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_fill_manual("legend", values = c("Good" = "#54B850", "Moderate" = "#F1ED3E", "Unhealthy" = "#EA212A", "Hazardous" = "#7C2B7A" )))

# PM2.5 vs. Wind Direction
boxplot(data$PM_AVG ~ data$cbwd, data = data, 
        xlab = "Wind Direction",
        ylab = expression(PM[2.5], "  ", mu*"g/", m^3),
        main = "Wind Direction Distribution",
        names = c("Static", "NE", "NW", "SE", "SW"))
model.lm <- lm(data$PM_AVG ~ data$cbwd, data = data)

print("Summary:")
print(summary(model.lm))
print(lm(formula = data$PM_AVG ~ data$cbwd, data = data))

# Fitted vs. Observed PM2.5 (Wind)
plot(x = model.lm$fitted, y = data$PM_AVG, 
     xlab = (expression(paste("Fitted ", PM[2.5], " ", mu*"g/", m^3))), 
     ylab = (expression(paste("Observed ", PM[2.5], " ", mu*"g/", m^3))), 
     main = (expression(R^2)))
abline(lm(data$PM_AVG ~ model.lm$fitted), col = "red")
print("Correlation between fitted and observed:")
print(cor(data$PM_AVG, model.lm$fitted))

# ANOVA
print("ANOVA:")
print(model.aov <- aov(data$PM_AVG ~ data$cbwd, data = data))
print(summary(model.aov))
print(etasq(model.aov))
print(sqrt(etasq(model.aov)))

# Multiple regression
print ("Multiple Regression:")
rsq <- summary(model.lm)$r.squared
print(rsq)
print(sqrt(rsq))

# Time series plots
print(myts <- ggplot(data, aes(datetime, PM_AVG)) +
        geom_line(color = "#203496") + 
        scale_x_datetime(date_breaks = "3 months", limits = c(as.POSIXct("2012-01-01"), as.POSIXct("2015-12-31"))) +
        xlab("") +
        ylab(expression(paste(PM[2.5], "  ",mu*"g/", m^3))) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        theme(plot.title = element_text(hjust = 0.5)) +
        ggtitle(expression(paste("Time Series of ", PM[2.5]))))

myts2 <- ts(data$PM_AVG, start=c(2012, 1), end=c(2015, 12), frequency=8766)
plot(decompose(myts2))
fit <- forecast(myts2, h=50000, method="arima")
plot(forecast(fit), xlab="Year", ylab=(expression(paste(PM[2.5], " ",mu*"g/", m^3))))

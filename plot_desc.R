### Create descriptive plots of the taxi data.

library(ggplot2)
library(data.table)
library(fasttime)

## Load the data.
yellow <- readRDS("yellow.RDS")


## Add columns.
yellow_data <- yellow[, ':=' (pickup_year=as.numeric(substr(tpep_pickup_datetime, 1, 4)), 
                                pickup_month=as.numeric(substr(tpep_pickup_datetime, 6, 7)), 
                                pickup_day=as.numeric(substr(tpep_pickup_datetime, 9, 10)),
                                pickup_hour=as.numeric(substr(tpep_pickup_datetime, 12, 13)),
                                weekday=weekdays(fastPOSIXct(tpep_pickup_datetime), abbreviate = T),
                                duration=as.numeric(
                                  fastPOSIXct(tpep_dropoff_datetime) - fastPOSIXct(tpep_pickup_datetime))/60)]

## Remove illogical values.
yellow_data <- yellow_data[pickup_longitude > -80 & pickup_longitude < -65 & 
                            pickup_latitude > 35 & pickup_latitude < 45 & 
                            dropoff_longitude > -80 & dropoff_longitude < -65 & 
                            dropoff_latitude > 35 & dropoff_latitude < 45 & 
                            passenger_count > 0 & duration >= 0 & fare_amount > 0]

## Aggregate data by pickup date.
yellow_data[, date := as.Date(paste0(pickup_day, "-", pickup_month, "-", pickup_year), 
                              "%d-%m-%Y")]

rides_day <- yellow_data[, .N, by=date]
rides_day <- rides_day[order(date)]

ggplot(data=rides_day, aes(x=date, y=N)) + geom_line(size=1, colour="yellow") + 
  scale_y_continuous("Taxi rides/day", expand = c(0, 0), limits = c(0, 5000)) + 
  scale_x_date("", expand=c(0,0))

## Pickup hours bar plot.
ggplot(data=yellow_data, aes(pickup_hour)) + geom_bar(aes(fill=I("yellow")))

## Weekdays bar plot.
# Order of the bars.
wd <- c("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")
ggplot(data=yellow_data, aes(weekday)) + geom_bar() + scale_x_discrete(limits=wd)

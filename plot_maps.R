### Different maps

## Load packages

library(data.table)

## Install and load spatial packages

install.packages("PBSmapping")
library(PBSmapping)

library(sp)
library(rgdal)

## Load the taxi data subset

saveRDS(yellow, file="yellow.RDS")

pickup <- data.frame(lon=yellow$pickup_longitude, 
                     lat=yellow$pickup_latitude)
pickup <- SpatialPoints(pickup)

## Import the NYC shapefile
load("nyc_spatial.RData")
plot(nyc_spatial)

points(pickup$lon, pickup$lat, col="red", cex=.4)
plot(pickup, add=T, col="red")

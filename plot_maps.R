### Different maps

## Load packages

library(data.table)
library(ggplot2)
library(broom)

## Install and load spatial packages

install.packages("PBSmapping")
library(PBSmapping)

library(sp)
library(rgdal)
library(maptools)

## Load the taxi data subset

saveRDS(yellow, file="yellow.RDS")

pickup <- data.frame(lon=yellow$pickup_longitude, 
                     lat=yellow$pickup_latitude)
pickup <- SpatialPoints(pickup)

## Import the NYC shapefile

load("nyc_spatial.RData")
plot(nyc_spatial)

## Exclude Staten Island

nyc_spatial_ex_staten <- subset(nyc_spatial, BoroName!="Staten Island")
plot(nyc_spatial_ex_staten)

## Prepare the shape file to be plotted with ggplot

nyc_shape <- nyc_spatial_ex_staten
nyc_df <- tidy(nyc_shape)

nyc_shape@data$id <- rownames(nyc_shape@data)
nyc_points <- fortify(nyc_shape, region="id")

pickup <- subset(pickup, lon!=0)
pickup <- subset(pickup, lon< -71)
pickup <- subset(pickup, lon>-78 & lat>35)

alpha_range = c(0.14, 0.75)
size_range = c(0.134, 0.173)

ggplot() + 
  geom_polygon(data=nyc_df, 
               aes(x=long, y=lat, group=group), 
               fill = "white", color="black") + 
  geom_point(data=a, 
             aes(x=lon, y=lat, color="red", alpha=paircount, size=paircount)) + 
  scale_alpha_continuous(range = alpha_range, trans = "log", limits = range(pickup$paircount)) +
  scale_size_continuous(range = size_range, trans = "log", limits = range(pickup$paircount)) +
  scale_color_manual(values = c("#ffffff", "#3f9e4d"))

pickup <- as.data.table(pickup)
a <- pickup[, list(paircount=.N), by=c("lon", "lat")]

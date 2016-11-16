library(ggplot2)
library(sp)
library(data.table)
library(ggmap)

yellow <- readRDS("yellow.RDS")
load("nyc_spatial.RData")

### Exclude Staten Island from the map.

nyc_ex_si <- subset(nyc_spatial, BoroName!="Staten Island")

nyc_df <- fortify(nyc_ex_si)

qplot(x=long, y=lat, data=nyc_df, geom="polygon", group=group, 
      colour=I("white"))

yellow <- subset(yellow, pickup_longitude!=0 & pickup_longitude< -71 & 
                 pickup_longitude>-78 & pickup_latitude>35)

### Count each lat/long pair.

pickups <- yellow[, list(paircount=.N), by=c("pickup_longitude", "pickup_latitude")]


yellow <- subset(yellow, pickup_latitude<41)
yellow <- subset(yellow, pickup_latitude>-74.1)

## Plot shapefile and each single pickup

ggplot() + 
  geom_polygon(data=nyc_df, 
               aes(x=long, y=lat, group=group, colour=I("white"))) + 
  geom_point(data=yellow, size=.1, alpha=1/50, 
             aes(x=pickup_longitude, y=pickup_latitude, colour="yellow"))

## Plot each pickup on the Manhattan Map

m <- get_map(location="New York Manhattan", color="bw", zoom=12)
p <- ggmap(m)
p <- p + geom_point(data=pickups, size=.1, colour="yellow",
                    aes(x=pickup_longitude, y=pickup_latitude)) + 
     scale_alpha_continuous(range = c(0.14, 0.75), trans = "log", limits = range(pickups$paircount)) + 
     scale_size_continuous(range = c(0.134, 0.173), trans = "log", limits = range(pickups$paircount)) + 
     scale_color_manual(values = c("#ffffff", "#3f9e4d"))
p

## Heat map of Manhattan yellow taxi pickups

m <- get_map(location="New York Manhattan", color="bw", zoom=12)
p <- ggmap(m) + stat_density_2d(bins=30, geom='polygon', size=1, data=yellow, aes(x = pickup_longitude, y = pickup_latitude, alpha=..level.., fill = ..level..))
p <- p  +  scale_fill_gradient(low = "yellow", high = "red", guide=FALSE) +  scale_alpha(range = c(0.02, 0.8), guide = FALSE) +xlab("") + ylab("")
p


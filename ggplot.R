library(ggplot2)
library(sp)
library(data.table)

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

yellow_count <- yellow[, list(paircount=.N), by=c("pickup_longitude", "pickup_latitude")]


yellow <- subset(yellow, pickup_longitude)

ggplot() + 
  geom_polygon(data=nyc_df, 
               aes(x=long, y=lat, group=group, colour=I("white"))) + 
  geom_point(data=yellow, size=.1, alpha=1/50, 
             aes(x=pickup_longitude, y=pickup_latitude, colour="yellow"))
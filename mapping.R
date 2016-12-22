library(sp)
library(maptools)

setwd("C:/Users/Matthias/Dropbox/analyzing_big_nyc")

nyc <- readShapePoly(file.choose())

lonlat <- data.frame(long = data$Start_Lon, lat = data$Start_Lat)


coordinates(lonlat) <- ~long+lat
dat <- over(lonlat, nyc[, "NTAName"])


pts_mat <- as.matrix(lonlat)

pts <- SpatialPoints(pts_mat)

dat <- over(pts, nyc)

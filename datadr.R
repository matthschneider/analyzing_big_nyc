library(datadr)
library(lubridate)
library(parallel)

nw <- list(lat = 40.917577, lon = -74.259090)
se <- list(lat = 40.477399, lon = -73.700272)


trans <- function(x) {
  # convert to POSIXct time
  #x$pickup_datetime <- fast_strptime(as.character(x$pickup_datetime), format = "%Y-%m-%d %H:%M:%S", tz = "EST")
  #x$dropoff_datetime <- fast_strptime(as.character(x$dropoff_datetime), format = "%Y-%m-%d %H:%M:%S", tz = "EST")
  
  # set coordinates outside of NYC bounding box to NA
  ind <- which(x$dropoff_longitude < nw$lon | x$dropoff_longitude > se$lon)
  x$dropoff_longitude[ind] <- NA
  ind <- which(x$pickup_longitude < nw$lon | x$pickup_longitude > se$lon)
  x$pickup_longitude[ind] <- NA
  ind <- which(x$dropoff_latitude < se$lat | x$dropoff_latitude > nw$lat)
  x$dropoff_latitude[ind] <- NA
  ind <- which(x$pickup_latitude < se$lat | x$pickup_latitude > nw$lat)
  x$pickup_latitude[ind] <- NA
  x
}

raw <- drRead.csv("C:/Users/Matthias/Desktop/yellow_tripdata_2016-01.csv", rowsPerBlock = 300000,
                  postTransFn = trans, output = localDiskConn("C:/Users/Matthias/Desktop/Connection"), control = control)

raw <- updateAttributes(raw)

stopCluster(cl)


pickup_latlon <- drHexbin("pickup_longitude", "pickup_latitude", data = raw, xbins = 100, shape = 1.4)
library(hexbin)
plot(pickup_latlon, trans = log, inv = exp, style = "centroids", xlab = "longitude", ylab = "latitude", legend = FALSE)
plot(pickup_latlon, trans = log, inv = exp, style = "colorscale", xlab = "longitude", ylab = "latitude", colramp = LinOCS)

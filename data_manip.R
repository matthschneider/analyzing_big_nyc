library(readr)
library(data.table)
library(fasttime)
library(lubridate)
library(sp)
library(maptools)


nyc <- readShapePoly("./Data/taxi_zones.shp", proj4string = CRS("+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000.0000000001 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"))
# Transform projection to long/lat.
nyc <- spTransform(nyc, "+proj=longlat +ellps=WGS84 +datum=WGS84")

## Function to load and manipulate the data

loadAndManipulate <- function(year, data_path){
  if(year==2015) {
    column_names <- c("vendor", "pickup_datetime", "dropoff_datetime", "passenger_count", 
                      "trip_distance", "pickup_lon", "pickup_lat", "rate", "store", 
                      "dropoff_lon", "dropoff_lat", "payment_type", "fare_amount", 
                      "surcharge", "mta_tax", "tip_amount", "tolls_amount", "imp_surcharge", 
                      "total_amount")
    drop_columns <- c(1, 9, 18)
  } else {
    column_names <- c("vendor", "pickup_datetime", "dropoff_datetime", "passenger_count", 
                      "trip_distance", "pickup_lon", "pickup_lat", "rate", "store", 
                      "dropoff_lon", "dropoff_lat", "payment_type", "fare_amount", 
                      "surcharge", "mta_tax", "tip_amount", "tolls_amount", "total_amount")
    drop_columns <- c(1, 9)
  }
  
  months <- c("01", "02", "03", "04", "05", "06", 
              "07", "08", "09", "10", "11", "12")
  
  credit <- c("CRD", "Cre", "CRE", "Credit", "CREDIT", 1)
  cash <- c("CSH", "CAS", "Cas", "CASH", "Cash", 2)
  
  for (i in 1:12){
    # Read monthly data
    data_yellow <- read_csv(paste0(data_path, "yellow_tripdata_", year, "-", months[i], ".csv"), 
                            col_names = column_names, n_max = 100000, skip = 1)
    
    # As data table for faster manipulation
    data_yellow <- as.data.table(data_yellow)
    
    data_yellow$pickup_datetime <- ymd_hms(as.character(data_yellow$pickup_datetime), tz = "EST")
    data_yellow$dropoff_datetime <- ymd_hms(as.character(data_yellow$dropoff_datetime), tz = "EST")
    
    data_yellow[, ':=' (pickup_date = substr(pickup_datetime, 1, 10), 
                        pickup_year = as.numeric(substr(pickup_datetime, 1, 4)), 
                        pickup_month = as.numeric(substr(pickup_datetime, 6, 7)), 
                        pickup_day = as.numeric(substr(pickup_datetime, 9, 10)), 
                        pickup_hour = as.numeric(substr(pickup_datetime, 12, 13)), 
                        weekday = wday(pickup_datetime, label = T),
                        duration = as.numeric(dropoff_datetime - pickup_datetime)/60, 
                        payment_type = ifelse(payment_type %in% credit, 1, 
                                               ifelse(payment_type %in% cash, 2, 3)), 
                        vendor = NULL,
                        pickup_datetime = NULL, 
                        dropoff_datetime = NULL, 
                        store = NULL)]
    
    if (year==2015) data_yellow[, imp_surcharge := NULL]
    
    # Update payment type to corresponding integer
    # 1 = Credit Card
    # 2 = Cash
    # 3 = Other
    
    # Remove illogical values
    data_yellow <- data_yellow[dropoff_lon != 0 & 
                               passenger_count > 0 &  
                               trip_distance > 0 &  
                               duration > 0]
    
    # Add geographic information
    # PICKUP
    # Extract longitude and latitude.
    lonlat <- data.frame(long = data_yellow$pickup_lon, lat = data_yellow$pickup_lat)
    coordinates(lonlat) <- ~long+lat
    proj4string(lonlat) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
    
    data_yellow[, pickup_locID := over(lonlat, nyc)$LocationID]
    
    # DROPOFF
    lonlat <- data.frame(long = data_yellow$dropoff_lon, lat = data_yellow$dropoff_lat)
    coordinates(lonlat) <- ~long+lat
    proj4string(lonlat) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")

    data_yellow[, dropoff_locID := over(lonlat, nyc)$LocationID]
    
    fwrite(data_yellow, paste0("E:/Daten/yellow", year, ".csv"), append = T)
  }

}

loadAndManipulate(2015, "E:/Daten/")

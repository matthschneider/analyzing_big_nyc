#########################
### Data Manipulation ###
#########################

# This code manipulates the raw taxi data, drops illogical values and adds
# external data.

# Load packages
library(data.table)
library(fasttime)

# Function to load each year.
# The working directory has to be set beforehand.

setwd()
loadRawData <- function(color, year, month) {
  if(color == "yellow") {
    
    if(year == 2015) {
      col_drop <- c(1, 9, 14, 15, 18)
    }
    
    file_name <- paste0(color, "_", "tripdata_", year, "-", month, ".csv")
    raw_data <- fread(file_name, drop = col_drop)
    
    colnames(raw_data) <- c("pickup_datetime", "dropoff_datetime", "passenger_count", 
                            "trip_distance", "pickup_longitude", "pickup_latitude", 
                            "rate", "dropoff_longitude", "dropoff_latitude", 
                            "payment_type", "fare_amount", "tip_amount", "tolls_amount", 
                            "total_amount")
    
    return(raw_data)
    
  }
}

### Hilbert rides/day

# Set path of local package library.
.libPaths(new = "/home/masch246/RLib")

# Set working directory.
setwd("/scratch_gs/masch246/data")

library(datadr)
library(parallel)

# Create 8 core cluster
options(defaultLocalDiskControl = localDiskControl(makeCluster(8, type = "FORK")))

conn <- localDiskConn("/scratch_gs/masch246/connection_single")
taxiData <- ddf(conn)

ridesDay <- drAggregate(taxiData, ~ pickup_year + pickup_month + pickup_day)

write.csv(ridesDay, "rides_day_agg.csv")
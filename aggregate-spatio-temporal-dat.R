#Aggregate spatio temporal array to make data size smaller
# CJ Brown 2021-06-24

library(terra)

r <- terra::rast("data-raw/sst_2011-2016.grd")

r2 <- aggregate(r, fact = 6)

r2

writeRaster(r2, "data-for-course/spatial-data/sst_2011-2016_v2.grd",
            overwrite = TRUE)

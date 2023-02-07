# create polygons
#CJ Brown 11 1 2020

library(raster)
library(sf)
library(readr)
dat <- read_csv("data-for-course/copepods_raw.csv")

dev.new()
plot(dat$longitude, dat$latitude)

p4 <- drawPoly()
plot(p4, add = TRUE, col = "blue")

sp1 <- st_as_sf(p1)
sp2 <- st_as_sf(p2)
sp3 <- st_as_sf(p3)
sp4 <- st_as_sf(p4)

spall <- rbind(sp1, sp2, sp3, sp4)
spall$region <- c("West", "South-East", "East", "Southern")

st_write(spall, "data-for-course/spatial-data/regions.shp", 
         delete_layer = TRUE)

spall <- st_read("data-for-course/spatial-data/regions.shp")
plot(spall)


#
# Shelf data
#
# from: https://data.gov.au/dataset/ds-aodn-e9624e55-1a14-4267-a8b1-12652e1e33b2/distribution/dist-aodn-e9624e55-1a14-4267-a8b1-12652e1e33b2-1/details?q=
library(concaveman)

shelfin <- st_read("data-raw/contour_5m/contour_5m.shp")
shelfin
range(shelfin$CONTOUR)

shelf200 <- dplyr::filter(shelfin, CONTOUR == 199.9)
plot(shelf200["LENGTH"])

plot(dplyr::filter(shelf200, XX_==1))

ushelf200 <- concaveman(shelf200)
plot(ushelf200)

ushelf200 <- st_buffer(ushelf200, 0.0)
st_write(st_zm(ushelf200), "data-for-course/spatial-data/aus_shelf.shp", 
         delete_layer = TRUE)

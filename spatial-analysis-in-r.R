## ----setup, include=FALSE----
knitr::opts_chunk$set(echo = TRUE, results ='markup', warnings = FALSE, message = FALSE, comment = '', strip.white = FALSE)


## ---- child="4_1_intro-to-spatial-analysis.Rmd"----

## ---------------------------
library(readr)
dat <- read_csv("data-for-course/copepods_raw.csv")
dat


## ---------------------------
library(ggplot2)
ggplot(dat) + 
  aes(x = longitude, y = latitude, color = richness_raw) +
  geom_point()


## ---------------------------
ggplot(dat, aes(x = latitude, y = richness_raw)) + 
  stat_smooth() + 
  geom_point()


## ---------------------------
library(sf)
sdat <- st_as_sf(dat, coords = c("longitude", "latitude"), 
                 crs = 4326)


## ---------------------------
crs4326 <- st_crs(4326)
crs4326$Name # name of the crs
crs4326$wkt # crs in well-known text format
crs4326$proj4string # crs as a proj4string


## ---------------------------
sdat


## ---------------------------
plot(sdat["richness_raw"])


## ---------------------------
library(tmap)

tm_shape(sdat) + 
  tm_dots(col = "richness_raw")


## ---------------------------
tm1 <- tm_shape(sdat) + 
  tm_dots(col = "richness_raw", 
          palette = "Blues", 
          title = "Species #")
tm1


## ----eval = FALSE-----------
## 
## tmap_save(tm1, filename = "Richness-map.png",
##           width = 600, height = 600)


## ---------------------------
aus <- st_read("data-for-course/spatial-data/Aussie/Aussie.shp")
shelf <- st_read("data-for-course/spatial-data/aus_shelf/aus_shelf.shp")


## ---------------------------
aus


## ---------------------------
tm_shape(shelf) + 
  tm_polygons()



## ---------------------------
tm_shape(shelf) + 
  tm_polygons(col = 'lightblue') +
  tm_shape(aus) + 
  tm_polygons() + 
  tm_shape(sdat) + 
  tm_dots()


## ---------------------------
tm_shape(shelf, bbox = sdat) + 
  tm_polygons()+#col = 'lightblue') +
  tm_shape(aus) + 
  tm_polygons() + 
  tm_shape(sdat) + 
  tm_dots()


## ----echo=FALSE-------------
tm_shape(shelf, bbox = sdat) + 
  tm_polygons(col = 'slategray2',
          border.col = 'slategray2')+
  tm_shape(aus) + 
  tm_polygons(col = 'wheat',
                border.col = "grey40") + 
  tm_shape(sdat) + 
  tm_symbols(col = "richness_raw", 
          palette = "YlOrRd",
          size = 0.1,
          border.lwd = NA,
          title.col = "Species \n richness", 
          alpha = 0.9) + 
  tm_layout(bg.color = "royalblue4",
            legend.position = c("left", "top"),
            legend.bg.color = "grey80") + 
  tm_compass(text.color = "white") +
  tm_credits("Chris Brown 2020. CPR data via CSIRO", 
             position = c("left", "BOTTOM"),
             col = "white")


## ----echo = FALSE, message = FALSE----
library(dplyr)


## ---------------------------
routes <- read_csv("data-for-course/Route-data.csv")


## ---------------------------
sdat_std <- inner_join(sdat, routes, by = "route")
nrow(sdat)
nrow(sdat_std)
nrow(routes)
length(unique(routes$route))



## ---------------------------
sdat_std <-  mutate(sdat_std,
              richness = richness_raw/silk_area)


## ---------------------------
sdat_std$Lat <- st_coordinates(sdat_std)[,2]


## ---------------------------
ggplot(sdat_std) +
  aes(x = Lat, y = richness, color = richness) + 
  geom_point() +
  stat_smooth() + 
  theme_bw()


## ---------------------------
save(sdat_std,file =  "data-for-course/spatial-data/copepods_standardised.rda")


## ----eval = FALSE-----------
## library(sf)
## shelfin <- st_read("data-raw/contour_5m/contour_5m.shp")
## shelfin
## range(shelfin$CONTOUR)
## shelf200 <- dplyr::filter(shelfin, CONTOUR == 199.9)
## plot(shelf200["LENGTH"])


## ---- eval = FALSE----------
## library(concaveman)
## ushelf200 <- concaveman(shelf200)
## plot(ushelf200)


## ----eval = FALSE-----------
## st_is_valid(ushelf200)


## ----eval = FALSE-----------
## ushelf200 <- st_make_valid(ushelf200)
## st_is_valid(ushelf200)
## 


## ----eval = FALSE-----------
## ushelf200 <- st_zm(ushelf200)


## ----eval = FALSE-----------
## st_write(ushelf200, "data-for-course/spatial-data/aus_shelf.shp")



## ---- child="4_2_R-as-GIS.Rmd"----

## ---------------------------
library(tidyverse)
library(sf)
library(tmap)

load("data-for-course/spatial-data/copepods_standardised.rda")
aus <- st_read("data-for-course/spatial-data/Aussie/Aussie.shp")



## ---------------------------
shelf <- st_read("data-for-course/spatial-data/aus_shelf/aus_shelf.shp")
shelf$shelf <- "Shelf"


## ----eval = FALSE-----------
## sdat_shelf <- st_join(sdat_std, shelf, join = st_intersects)


## ---------------------------
st_crs(shelf)
st_crs(sdat_std)


## ---------------------------
shelf <- st_transform(shelf, crs = st_crs(sdat_std))


## ---------------------------
sdat_shelf <- st_join(sdat_std, shelf, join = st_intersects)
names(sdat_shelf)
unique(sdat_shelf$shelf)


## ---------------------------
library(tidyr)
sdat_shelf <- mutate(sdat_shelf, 
                     shelf = replace_na(shelf, "Offshore"))
table(sdat_shelf$shelf)


## ---------------------------

tm_shape(shelf, bbox = sdat_shelf) + 
  tm_polygons(col = "grey10") + 
  tm_shape(sdat_shelf) + 
  tm_dots(col = "shelf", palette = "RdBu") +
  tm_graticules()



## ---------------------------
ggplot(sdat_shelf) + 
aes(x = Lat, y = richness, color = shelf) +
geom_point(alpha = 0.5, size = 0.2) + 
  stat_smooth() + 
  theme_bw()



## ---- message=FALSE---------
library(terra)


## ---------------------------
rsst <- rast('data-for-course/spatial-data/MeanAVHRRSST/MeanAVHRRSST.grd')
plot(rsst)


## ---------------------------

tm_shape(rsst) + 
  tm_raster(palette = "-RdBu", title = "SST")



## ---------------------------
tm_shape(rsst) + 
  tm_raster(palette = "-RdBu", title = "SST") + 
  tm_shape(sdat_std) + 
  tm_dots(col = "richness_raw", 
          palette = "Greys", 
          title = "Species #") + 
  tm_compass() 


## ---------------------------
sdat_std$sst <- terra::extract(rsst, vect(sdat_std))[,2]


## ---------------------------

ggplot(sdat_std, aes(sst, richness)) + 
  geom_point() + 
  theme_minimal()
with(sdat_std, cor.test(sst, richness))


## ---------------------------
filter(sdat_std, is.na(sst))


## ---------------------------
sdat_sst <- filter(sdat_std, !is.na(sst))


## ----message = FALSE--------
library(mgcv)
m1 <- gam(richness ~ s(sst, k=5), data = sdat_sst, family = 'poisson')
plot(m1)


## ----message = FALSE--------
sdat_sst$Region <- factor(sdat_sst$region)
m1 <- gam(richness ~ s(sst, k=5, by = Region) + Region, data = sdat_sst, family = 'poisson')


## ---------------------------
sdat_sst$pred_m1 <- predict(m1, type = "response")

ggplot(sdat_sst) +
  aes(x = sst, y = richness, color = Region)+
  geom_point(size = 0.2, alpha = 0.3) +
  geom_line(aes(y = pred_m1), size = 1) + 
  facet_grid(.~Region) + 
  theme_bw()


## ---------------------------
deviance(m1)
m1$df.residual



## ---------------------------
m2 <- gam(richness ~ s(sst, by = Region) + Region, data = sdat_sst, family = mgcv::negbin(theta = 1.99))
deviance(m2)
m2$df.residual


## ----echo=FALSE-------------
DataGLMRepeat::rootogram(sdat_sst$richness, predict(m2, type = "response"))


## ---------------------------
sdat_sst$pred_m2 <- predict(m2, type = "response")

ggplot(sdat_sst) +
  aes(x = sst, y = richness, color = Region)+
  geom_point(size = 0.2, alpha = 0.3) +
  geom_line(aes(y = pred_m2), size = 1) + 
  facet_grid(.~Region) + 
  theme_bw()


## ---------------------------
sdat_sst$x <- st_coordinates(sdat_sst)[,1]


## ---------------------------
# m_int <- gam(richness ~s(sst) + s(x, y, bs = "gp", m = c(1,1)), data = sdat_sst, family = mgcv::negbin(theta = 2.03))

# m_int <- gam(richness ~s(sst, by = x), data = sdat_sst, family = mgcv::negbin(theta = 2.03))

m_int <- gam(richness ~s(sst, x), data = sdat_sst, family = mgcv::negbin(theta = 2.03))

m_int$df.residual
deviance(m_int)


## ---------------------------
plot(m_int)


## ----eval = FALSE-----------
## sdat_sst$x <- st_coordinates(sdat_sst)[,1]
## sdat_sst$y <- st_coordinates(sdat_sst)[,2]
## 
## sdat_west <- filter(sdat_sst, (x < 120) & (y > -40))


## ----eval = FALSE-----------
## sdat_sst$group <- cut(sdat_sst$y, breaks = seq(-37, -16, by = 1.5))


## ----eval = FALSE-----------
## m4 <- gamm(richness ~ s(sst), data = sdat_sst,
##            random = list(group=~1),
##           family = mgcv::negbin(theta = 3.8))
## plot(m4$gam)
## summary(m4$lme)


## ----eval = FALSE-----------
## sdat_west2 <- st_transform(sdat_west, crs = 3577)
## sdat_west2$x <- st_coordinates(sdat_west2)[,1]
## sdat_west2$y <- st_coordinates(sdat_west2)[,2]


## ----eval = FALSE-----------
## m5 <- gam(richness ~ s(sst) + s(x, y, bs = "gp"),
##           data = sdat_west2,
##           family = mgcv::negbin(theta = 3.8))
## plot(m5)


## ---- eval=FALSE------------
## m6 <- gamm(richness ~ s(sst),
##                 #This next step includes the spatial AC
##                 # with an exponential correlation structure
##                 correlation = corExp(form = ~x + y),
##                 data = sdat_west2, family =
##                   mgcv::negbin(theta = 3.8))
## 
## plot(m6$gam)
## 
## summary(m6$lme)


## ---------------------------
sdat_sst$richness_pred <- predict(m_int, type = "response")


## ---------------------------
tm_shape(sdat_sst) +
  tm_dots(col = "richness_pred") 



## ---------------------------
rsst2 <- aggregate(rsst, 2)
par(mfrow = c(1,2))
plot(rsst)
plot(rsst2)


## ---------------------------
# icell <- cellFromXY(rsst2, st_coordinates(sdat_sst)) #alt option
icell <- 1:ncell(rsst)
pred <- data.frame(sst = rsst2[icell][,1],
                       cells = icell, 
                       x = xFromCell(rsst2, icell),
                      y = yFromCell(rsst2, icell)) 

pred <- na.omit(pred)
head(pred)


## ---------------------------
pred$richness_pred <- predict(m_int, newdata = pred, type = "response")
head(pred)


## ---------------------------
rpred <- rast(rsst2)
rpred[pred$cells] <- matrix(pred$richness_pred, ncol = 1)


## ---------------------------
tm_shape(aus, bbox = st_bbox(rpred)) +
  tm_polygons(col = "white") + 
  tm_shape(rpred) + 
  tm_raster(palette = "RdPu",
            title= "Richness", alpha = 0.8, n=10) + 
  tm_layout(bg.color = "grey20", 
            legend.position = c("left", "top"),
            legend.text.color = "white", 
            legend.title.color = "white")


## ---------------------------
ggplot(sdat_sst) + 
  aes(x = sst, y = richness_pred, color = x, alpha = 0.5) +
  geom_point() + 
    theme_bw() +
  ylab("Richness (predicted)") + 
  xlab(expression('SST ('*~degree*C*')'))


## ----echo = FALSE, message = FALSE, warning  = FALSE----
# d <- st_read(dsn ="data-raw/auscoast", "aust_cd66states")
# d$adm <- c("NSW", "Vic", "QLD","SA", "WA", "Tas", "NT", "ACT")
# d <- select(d, adm, geometry, -STE, -COUNT) %>% 
#   st_set_crs(st_crs(sf_cope))
# d <- rmapshaper::ms_simplify(input = as(d, 'Spatial')) %>%
#   st_as_sf()
#  st_write(d, dsn = "data-for-course/spatial-data", layer = "Aussie.shp", 
#           driver = "ESRI Shapefile")


## ---- warning=FALSE, message=FALSE----
tmap_mode("view")


## ---------------------------
print(object.size(sdat_sst), units = "Kb")


## ---------------------------
tm_shape(sdat_sst) +
  tm_dots() 


## ---------------------------
tm_shape(sdat_sst) +
  tm_dots(col = "richness_pred") 


## ---------------------------
tmaptools::get_proj4("robin")


## ---------------------------
robin <-  "+proj=robin +lon_0=100 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +towgs84=0,0,0"


## ---------------------------
tmap_mode("plot")
tm_shape(rsst, projection = robin) + 
  tm_raster(palette = "-RdBu", title = "SST") + 
  tm_shape(aus, projection = robin) + 
  tm_polygons(col = "wheat") + 
  tm_compass() 


## ---------------------------
tas_ext <- raster::extent(140, 155, -45, -39)
stas <- st_crop(sdat_shelf, st_bbox(tas_ext))


## ----eval = FALSE-----------
## dist <- st_distance(stas, shelf)


## ---------------------------
stas2 <- st_transform(stas, crs = 32755)
shelf2 <- st_crop(shelf, tas_ext)
shelf2 <- st_transform(shelf2, crs = 32755)

dist2 <- st_distance(stas2, shelf2)
stas2$dist <- as.numeric(dist2)/1000



## ---------------------------
tm_shape(stas2) + 
  tm_dots() + 
  tm_shape(shelf2) + 
  tm_polygons(col = "lightblue") + 
  tm_shape(stas2) + 
  tm_symbols(col = "dist", alpha = 0.5, 
             title.col = "Distance from \n shelf (km)")



## ---------------------------
tm_shape(shelf2) + 
  tm_polygons(col = "lightblue") + 
tm_shape(aus, projection = 32755) + 
  tm_polygons() + 
  tm_shape(stas2) + 
  tm_symbols(col = "dist", alpha = 0.5, 
             title.col = "Distance from \n shelf (km)")


## ---------------------------
ggplot(stas2) + 
  aes(x = dist, y = richness) + 
  geom_point() + 
  stat_smooth()



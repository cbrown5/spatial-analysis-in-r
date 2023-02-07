# Create data for R ggplot, dplyr and tidyr course
#CJ Brown 5/1/2018 
#
# What I will do is create difference silk 'areas' for each route, 
#which then need to be used to standardize richness values 
#and recover back original values
#
# Could also have vessels using different projections? 

rm(list = ls())

library(tidyr)
library(ggplot2)
library(dplyr)
library(readr)

dat <- read_csv("data-raw/copepods_sst.csv")

### Route level data

length(unique(dat$route))

areas <- rev(c(1, 2, 3, 8))
routes <- dat %>% select(route, latitude, longitude) %>% 
  group_by(route) %>%
  summarize(meanlat = mean(latitude),
            meanlong = mean(longitude))
            
routes$silk_area <- areas[cut(routes$meanlat, 3, labels = FALSE)]

routes_proj <- dat %>% select(route, project, silk_id, segment_no) %>%
  group_by(route, project) %>%
  summarize(number_segments = n()) %>%
  inner_join(routes) %>%
  mutate(region = ifelse(meanlat < -42, "Southern Ocean", 
                         ifelse(meanlong > 143, "East", "West")))

#routes with duplicated rows 

routes_proj2 <- rbind(routes_proj, routes_proj[c(5,10,13),])

### Create unstandardized richness and abundance data 

dat2 <- dat %>%
  inner_join(routes_proj) %>%
  mutate(abundance_raw = abundance * silk_area, 
         richness_raw = richness * silk_area) %>%
  select(-abundance, -richness, -number_segments, 
         -silk_area, -sst, -meanlat)

#create an error
imistakes <- which(dat2$richness_raw == 0)[c(1,20, 771)]
dat2$richness_raw[imistakes] <- -999

hist(dat2$richness_raw)

dat3 <- dat2 %>% select(-abundance_raw)

dat_abund <- dat2 %>% select(silk_id, segment_no, abundance_raw) %>%
  spread(segment_no, abundance_raw) #%>% 
#This is all just to check it works ok. 
  # gather(segment_no, abundance_raw, -silk_id, na.rm = TRUE) %>%
  # mutate(segment_no = as.numeric(segment_no), a2 = abundance_raw) %>%
  # select(-abundance_raw) %>%
  # inner_join(dat2)


plot(dat$longitude, dat2$longitude)
plot(dat$richness, dat2$richness_raw)
plot(dat2$latitude, dat2$richness_raw)

#
# Save data 
#

write_csv(dat_abund, "data-for-course/copepods_abundance.csv")
write_csv(dat3, "data-for-course/copepods_raw.csv")
write_csv(routes_proj2, "data-for-course/Route-data.csv")

  

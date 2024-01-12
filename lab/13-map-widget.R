# TODO:   Add comment
# 
# Author: Miguel Alvarez
################################################################################




source("R/map_specimens.R")

map_specimens(Spec)

library(mapview)
library(sf)
library(dplyr)
library(magrittr)
library(leaflet)






Data <- tibble(Name = c("M1", "M2", "M3"),
    Latitude = c(52L, 52L, 51L), 
    Longitude = c(50L, 50L, 50L), 
    Altitude = c(97L, 97L, 108L))

Data %>% 
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>% 
    st_jitter(factor = 0.001) %>%
    mapview

library(leaflet)

Data %>% 
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>% 
    leaflet() %>%
    addTiles() %>%
    addMarkers(
        popup = ~Name,
        clusterOptions = markerClusterOptions()
    )



x <- Spec
add_cols = c("coll_date", "leg")
coords = c("longitude", "latitude")
date_format = "%d.%m.%Y"


# TODO:   Add comment
# 
# Author: Miguel Alvarez
################################################################################

library(specimensDB)
library(RPostgreSQL)
library(sf)

conn <- connect_db(dbname = "vegetation-db")
gadm <- connect_db(dbname = "gadm_v3")



db = conn
adm = gadm
bulk = 17
schema = "specimens"
tax_schema = "plant_taxonomy"
get_coords = TRUE





ews_2009 <- read_specimens(db = conn, adm = gadm, bulk = 17)


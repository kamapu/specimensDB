# TODO:   Add comment
# 
# Author: Miguel Alvarez
################################################################################

library(backpackR)
library(specimensDB)
library(RPostgreSQL)
library(rpostgis)

db_restore("vegetation-db", "../../db-dumps/vegetation_v4/project-20240308/db-backup.backup")

conn <- connect_db(dbname = "vegetation-db")
#gadm <- connect_db(dbname = "gadm_v3")

db = conn
df = read.csv("lab/update-2.csv")
df$det_date <- as.Date(df$det_date, format = "%d.%m.%Y")
## adm = gadm
## bulk = 17
schema = "specimens"
tax_schema = "plant_taxonomy"
compare = FALSE
ask = TRUE







# TODO:   Test error messages in 'read_specimens()'
# 
# Author: Miguel Alvarez
################################################################################

## library(readODS)
## library(RPostgreSQL)
## library(vegtableDB)
library(divDB)
library(specimensDB)
## library(sf)

# Common variables
DB <- "vegetation_v3"

# Restore database
do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

conn <- connect_db(DB, user = "miguel")
adm <- connect_db("gadm_v3", user = "miguel")

# Read existing collection
db_data <- read_specimens(conn, adm, bulk = 6)
map_specimens(db_data, add_cols = c("coll_date", "leg", "taxon_name",
        "herbarium"))

# Read non-existing collection
db_data <- read_specimens(conn, adm, bulk = 7)

DBI::dbDisconnect(conn)
DBI::dbDisconnect(adm)

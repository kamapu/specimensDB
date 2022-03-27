# TODO:   Check duplicated entries
# 
# Author: Miguel Alvarez
################################################################################

# Install development versions
library(devtools)

install_github("kamapu/specimensDB", "devel")
install_github("kamapu/specimens", "devel")

# Load libraries
library(dbaccess)
library(specimensDB)
library(RPostgreSQL)
library(sf)

# Restore database
DB <- "vegetation_v3"

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

# Connect database
db <- connect_db2(DB, user = "miguel")

# see list of bulks
Bulks <- dbGetQuery(db, "select * from specimens.projects")
Bulks

# Examples
sf <- data.frame(coll_date = rep(as.Date("2022-01-05"), 2),
    longitude = c(0, 0.5), latitude = c(0, 1.5))
sf <- st_as_sf(sf, coords = c("longitude", "latitude"), crs = st_crs(4326))


# 1. No existing bulk => ERROR
new_coll(db, sf, 5)

# 2. Working fine
new_coll(db, sf, 2)

# Cross-check
SP <- read_spec(conn, bulk = 2)
tail(SP@collections)
summary(subset(SP, coll_nr %in%
            SP@collections$coll_nr[nrow(SP@collections) - c(0:2)]))

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

# 1. Existing bulk
new_coll(db, sf, "Patagonian Wetlands 2012")

# 2. Working fine
new_coll(db, sf, "A very new project")

# Cross-check
SP <- read_spec(conn, bulk = 3)
tail(SP@collections)
summary(subset(SP, coll_nr %in%
            SP@collections$coll_nr[nrow(SP@collections) - c(0:2)]))

SP <- read_spec(conn, bulk = 4)
summary(SP)



# Refresh database
do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")


db = conn
bulk = 4



Test <- new("specimens",
    collections = Coll, specimens = Spec,
    history = Det
)


Test


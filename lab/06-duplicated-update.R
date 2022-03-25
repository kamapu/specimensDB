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
library(vegtableDB)

# Restore database
DB <- "vegetation_v3"

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

# Connect database
conn <- connect_db2(DB, user = "miguel")

# Import bulk
SP <- read_spec(conn, bulk = 2)
TAX <- db2taxlist(conn, "ea_splist")

# Test duplicated in input
summary(subset(SP, coll_nr %in% SP@collections$coll_nr[1:2]))

# duplicates in input
df1 <- data.frame(
    spec_id = c(879, 954, 954),
    taxon_usage_id = rep(209403, 3),
    taxonomy = "ea_splist",
    det = rep("M. Alvarez", 3),
    det_date = rep(as.Date("2022-03-24"), 3))

df2 <- data.frame(
    spec_id = c(879, 954),
    taxon_usage_id = rep(209403, 2),
    taxonomy = "ea_splist",
    det = rep("M. Alvarez", 2),
    det_date = rep(as.Date("2011-03-15"), 2))











## object <- SP
## format = "%d.%m.%Y"
library(RPostgreSQL)
db = conn
df = df2


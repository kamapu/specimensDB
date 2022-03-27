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

# Restore database
DB <- "vegetation_v3"

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

# Connect database
db <- connect_db2(DB, user = "miguel")

# Check for an example
SP <- read_spec(db, bulk = 2)

summary(SP, 1565)

# 1: Split unexisting specimen => ERROR
split_spec(db, 100000)

# 2: Split selected specimen
split_spec(db, 970, 3, herbarium = "FB")

# Cross-check
SP <- read_spec(db, bulk = 2)
summary(SP, 1565)

subset(SP, coll_nr == 1565)@specimens

# Refresh database
do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

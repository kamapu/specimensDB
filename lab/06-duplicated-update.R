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
## library(vegtableDB)

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
## TAX <- db2taxlist(conn, "ea_splist")

# Test duplicated in input
summary(subset(SP, coll_nr %in% SP@collections$coll_nr[1:2]))

# duplicates in input
df1 <- data.frame(
    spec_id = c(879, 954, 954),
    taxon_usage_id = rep(209403, 3),
    taxonomy = "ea_splist",
    det = rep("M. Alvarez", 3),
    det_date = rep(as.Date("2022-03-24"), 3))

# duplicates with database
df2 <- data.frame(
    spec_id = c(879, 954),
    taxon_usage_id = rep(209403, 2),
    taxonomy = "ea_splist",
    det = rep("M. Alvarez", 2),
    det_date = rep(as.Date("2011-03-15"), 2))

# Case 1: duplicated inputs
new_det(conn, df1)

# Case 2: duplicated inputs but using compare
new_det(conn, df1, compare = TRUE)

# Case 3: duplicated with determinations in database
new_det(conn, df2)

# Case 4: same as before but solved in advance
new_det(conn, df2, compare = TRUE)

# Cross-check
SP <- read_spec(conn, bulk = 2)
summary(subset(SP, coll_nr %in% SP@collections$coll_nr[1:2]))

# Refesh database
do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

# Cross-check again
SP <- read_spec(conn, bulk = 2)
summary(subset(SP, coll_nr %in% SP@collections$coll_nr[1:2]))

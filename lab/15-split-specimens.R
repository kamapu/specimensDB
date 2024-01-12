# TODO:   Test
# 
# Author: Miguel Alvarez
################################################################################

## library(vegtableDB)
library(specimensDB)
## library(readODS)
## library(sf)

# Restore PostgreSQL database and connect
DB <- "vegetation_v3"
B <- 10

do_restore(
		dbname = DB,
		user = "miguel",
		filepath = file.path("../../db-dumps/00_dumps", DB)
)

conn <- connect_db(DB, user = "miguel")
adm <- connect_db("gadm_v3", user = "miguel")

# Collection Vernal Pools Chile
db_data <- read_specimens(conn, adm, bulk = B)
db_data
map_specimens(db_data)

summary(as.factor(db_data@specimens$coll_nr))
summary(as.factor(db_data@specimens$herbarium))

# Select two specimens to duplicate
split_specimens(conn, spec_id = c(8, 9), add = c(2, 5), herbarium = "VALD",
		spec_id_nr = NA, spec_id_txt = NA)

# Cross-check
db_data <- read_specimens(conn, adm, bulk = B)
db_data

summary(as.factor(db_data@specimens$coll_nr))
summary(as.factor(db_data@specimens$herbarium))

# Restore
do_restore(
		dbname = DB,
		user = "miguel",
		filepath = file.path("../../db-dumps/00_dumps", DB)
)

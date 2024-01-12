# TODO:   Write envelopes for Bryophytes
# 
# Author: Miguel Alvarez
################################################################################

remotes::install_github("kamapu/vegtableDB", "devel")
remotes::install_github("kamapu/specimensDB", "devel")

library(vegtableDB)
library(specimensDB)
library(RPostgreSQL)

# Restore PostgreSQL database and connect
DB <- "vegetation_v3"

do_restore(
    dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB)
)

conn <- connect_db(DB, user = "miguel")
adm <- connect_db("gadm_v3", user = "miguel")

# Import specimens and check for bryophytes
Spec <- read_spec(conn, adm, bulk = 3)
Spec <- subset(Spec, spec_class == "bryophyte", slot = "specimens")

write_envelopes(Spec, "lab/mosses-env")

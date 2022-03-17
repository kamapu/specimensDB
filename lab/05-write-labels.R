# TODO:   Test for writing labels
# 
# Author: Miguel Alvarez
################################################################################

## library(devtools)
## install_github("kamapu/specimens")
## install_github("kamapu/specimensDB", "devel")

## library(dbaccess)
library(specimens)
library(specimensDB)

## library(vegtableDB)
## library(readODS)
## library(RPostgreSQL)
## library(rpostgis)
## library(yamlme)

## DB <- "vegetation_v3"
## 
## do_restore(dbname = DB,
##     user = "miguel",
##     filepath = file.path("../../db-dumps/00_dumps", DB),
##     path_psql = "/usr/bin")

## conn <- connect_db2(DB, user = "miguel")
## conn2 <- connect_db2("gadm_v3", user = "miguel")

# Informations from species list
## Spp <- db2taxlist(conn, "ea_splist")

## Spec <- read_spec(db = conn, adm = conn2, bulk = 2)
## saveRDS(Spec, "lab/specimens-v0.rds")
Spec <- readRDS("lab/specimens-v0.rds")

write_labels(Spec, "lab/bonn")
write_labels(Spec, "lab/bonn2", merge = FALSE)
write_labels(Spec, "lab/bonn3", frame = TRUE)

# Format for BONN
BONN_2 <- release(Spec, "BONN")
write_ods(BONN_2, "miguel-collections/churo-survey-2011/release_table.ods")

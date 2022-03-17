# TODO:   Producing updates for specimens
# 
# Author: Miguel Alvarez
################################################################################

library(devtools)
install_github("kamapu/specimensDB", "devel")

library(dbaccess)
library(vegtableDB)
library(specimens)
library(specimensDB)
library(readODS)
library(RPostgreSQL)
library(rpostgis)

DB <- "vegetation_v3"

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

conn <- connect_db2(DB, user = "miguel")
## conn2 <- connect_db2("gadm_v3", user = "miguel")

# Informations from species list
## Spp <- db2taxlist(conn, "ea_splist")
new_dets <- read_ods("lab/update-1.ods")
new_dets$det_date <- as.Date(new_dets$det_date, "%d.%m.%Y")

## Spec <- read_spec(db = conn, adm = conn2, bulk = 2)
## saveRDS(Spec, "lab/specimens-v0.rds")
Spec <- readRDS("lab/specimens-v0.rds")

Spec <- subset(Spec, coll_nr %in% new_dets$coll_nr)
summary(Spec)

new_dets$spec_id <- with(Spec@specimens,
    spec_id[match(new_dets$coll_nr, coll_nr)])

# Some change in the database
query <- paste("alter table specimens.\"history\"",
    "alter column taxon_usage_id_trash",
    "drop not null")
dbSendQuery(conn, query)

# Update with the function
update_det(conn, new_dets)

# Cross-check
conn2 <- connect_db2("gadm_v3", user = "miguel")
Spec <- read_spec(db = conn, adm = conn2, bulk = 2)
Spec <- subset(Spec, coll_nr %in% new_dets$coll_nr)
summary(Spec)

# do the backup
do_backup(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

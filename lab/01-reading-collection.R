# TODO:   Test on function read_spec
# 
# Author: Miguel Alvarez
################################################################################

library(RPostgreSQL)
library(vegtableDB)
library(dbaccess)
library(sf)

conn1 <- connect_db2("vegetation_v3", user = "miguel")
conn2 <- connect_db2("gadm_v3", user = "miguel")

source("R/read_spec.R")

Spec <- read_spec(db = conn1, adm = conn2, tax = "swea_dataveg", bunch = 2)

saveRDS(Spec, "lab/specimens.rds")

# Arguments
db <- conn1
adm <- conn2
bunch = 2

Coll <- st_read(conn1, query = "select * from specimens.collections")







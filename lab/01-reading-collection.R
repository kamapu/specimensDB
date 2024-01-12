# TODO:   Test on function read_spec
# 
# Author: Miguel Alvarez
################################################################################

library(dbaccess)
library(specimens)
library(specimensDB)

conn1 <- connect_db2("vegetation_v3", user = "miguel")
conn2 <- connect_db2("gadm_v3", user = "miguel")

Spec <- read_specimens(db = conn1, adm = conn2, bulk = 2)

validObject(Spec)

# Import object for laboratory in specimens
saveRDS(Spec, "../specimens/lab/specimens.rds")

# TODO:   Describing a bulk
# 
# Author: Miguel Alvarez
################################################################################

library(devtools)
install_github("kamapu/specimensDB", "devel")

library(specimens)
library(specimensDB)
library(vegtableDB)

# Restore database
DB <- "vegetation_v3"

do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB))

# Connect database
db <- connect_db(DB, user = "miguel")

# Render description
description_sheet(db, bulk = 2, output_file = "lab/churo")

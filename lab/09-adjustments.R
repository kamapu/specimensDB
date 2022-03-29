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
gadm <- connect_db2("gadm_v3", user = "miguel")

# See projects
Bulks <- dbGetQuery(db, paste("select *", "from specimens.projects"))
Bulks

# Display bulks
Spec <- read_spec(db, gadm, bulk = 3)

# Add new collection
summary(Spec, 1048)
new_row <- subset(Spec@collections, coll_nr == 1048)
new_coll(db, new_row, bulk = 3)

Spec <- read_spec(db, gadm, get_coords = FALSE)

render_desc(db, 2, output_file = "lab/Test")

# Refresh database
do_restore(dbname = DB,
    user = "miguel",
    filepath = file.path("../../db-dumps/00_dumps", DB),
    path_psql = "/usr/bin")

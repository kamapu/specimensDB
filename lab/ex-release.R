# TODO:   Solving issues with release
# 
# Author: Miguel Alvarez
################################################################################

library(specimensDB)

conn <- connect_db(dbname = "vegetation-db")
gadm <- connect_db(dbname = "gadm_v3")

new_bonn <- read.table("lab/new-bonn.txt")[[1]]
ews_2009 <- read_specimens(db = conn, adm = gadm, bulk = 17)

ews_2009 <- subset(ews_2009, spec_id %in% new_bonn, slot = "specimens")
for_bonn <- release(ews_2009, herb = "BONN")

# Set arguments
x = ews_2009
herb = "BONN"
trans <- specimensDB:::translator

library(taxlist)

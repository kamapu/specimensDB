# TODO:   Producing updates for specimens
# 
# Author: Miguel Alvarez
################################################################################

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







query <- paste("alter table specimens.\"history\"",
    "alter column taxon_usage_id_trash",
    "drop not null")
dbSendQuery(conn, query)


update_det <- function(db, df, ...) {
  col_names <- c("spec_id", "taxon_usage_id", "taxonomy", "det", "det_date")
  # Cross-checks
  if (!all(col_names %in% names(df))) {
    col_names <- col_names[!col_names %in% names(df)]
    stop(paste0(
            "Following columns are missing in 'df': '",
            paste0(col_names, collapse = "' '"), "'."
        ))
  }
  if(class(df$det_date) != "Date")
    stop("Class 'Date' for 'det_date' in 'df' is mandatory.")
  # Retrieve names
  query <- paste("select taxon_usage_id,usage_name,author_name",
      "from plant_taxonomy.taxon_names",
      paste0("where taxon_usage_id in (", paste0(df$taxon_usage_id,
              collapse = ","), ")"))
  Names <- dbGetQuery(db, query)
  Names <- merge(df, Names, sort = FALSE, all = TRUE)
  cat("Updates of specimens determination:\n\n")
  print(Names[ , c("spec_id", "coll_nr", "usage_name", "author_name", "det",
              "det_date")])
  OUT <- askYesNo("Do you like to proceed?")
  if(!is.na(OUT) & OUT) {
    query <- paste("select tax_id,taxon_usage_id,taxon_concept_id",
        "from plant_taxonomy.names2concepts",
        paste0("where taxon_usage_id in (",
            paste0(Names$taxon_usage_id, collapse = ","), ")"))
    IDs <- dbGetQuery(db, query)
    query <- paste("select taxon_concept_id,top_view taxonomy",
        "from plant_taxonomy.taxon_concepts",
        paste0("where taxon_concept_id in (",
            paste0(IDs$taxon_concept_id, collapse = ","), ")"))
    IDs <- merge(IDs, dbGetQuery(db, query))
    Names$tax_id <- with(IDs,
        tax_id[match(paste(Names$taxon_usage_id, Names$taxonomy, sep = "_"),
                paste(taxon_usage_id, taxonomy, sep = "_"))])
  }
  pgInsert(db, c("specimens", "history"), Names, partial.match = TRUE)
}

update_det(conn, new_dets) 


conn2 <- connect_db2("gadm_v3", user = "miguel")
Spec <- read_spec(db = conn, adm = conn2, bulk = 2)

Spec <- subset(Spec, coll_nr %in% new_dets$coll_nr)
summary(Spec)


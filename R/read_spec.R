#' @name read_spec
#'
#' @title Import Specimen Information.
#'
#' @description
#' By convenience a single table will be imported from the database including
#' original variable names.
#' This table can be passed to a specific format required by an herbarium using
#' [release()].
#'
#' @param db,adm Connections to the main database and the database containing
#'     administrative units, respectively. Both connections have to be of class
#'     [PostgreSQLConnection-class].
#' @param tax Character value indicating the taxonomy used as reference for
#'     taxonomic information.
#' @param bunch Integer vector including the ID's of the requested bunches
#'     (bulks).
#' @param ... Further arguments passed among methods (not yet used).
#'
#' @return An S3 object of class `specimens`.
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}

#' @rdname read_spec
#'
#' @exportMethod read_spec
setGeneric(
  "read_spec",
  function(db, adm, tax, ...) {
    standardGeneric("read_spec")
  }
)

#' @rdname read_spec
#'
#' @aliases PostgreSQLConnection,PostgreSQLConnection,character-method
setMethod(
  "read_spec",
  signature(
    db = "PostgreSQLConnection",
    adm = "PostgreSQLConnection",
    tax = "character"
  ),
  function(db, adm, tax, bunch, ...) {
    # Main table
    message("Importing main table ... ", appendLF = FALSE)
    if (missing(bunch)) {
      Coll <- st_read(db, query = paste(
        "select *",
        "from specimens.miguel_collection;"
      ))
    } else {
      Coll <- st_read(db, query = paste(
        "select *",
        "from specimens.miguel_collection",
        paste0("where bunch in (", paste0(bunch, collapse = ","), ");")
      ))
    }
    # Add project name (campaign)
    if ("bunch" %in% colnames(Coll)) {
      query <- paste(
        "select *",
        "from specimens.miguel_projects",
        paste0("where bunch in (", paste0(unique(Coll$bunch),
          collapse = ","
        ), ");")
      )
      Coll <- merge(Coll, dbGetQuery(db, query), all = TRUE, sort = FALSE)
    }
    # Add voucher IDs
    query <- paste(
      "select voucher_id,coll_nr",
      "from specimens.miguel_vouchers",
      paste0("where coll_nr in (", paste0(Coll$coll_nr,
        collapse = ","
      ), ");")
    )
    Coll <- merge(Coll, dbGetQuery(db, query), all = TRUE, sort = FALSE)
    # Extract determined vouchers
    message("OK\nImporting taxonomic information ... ", appendLF = FALSE)
    Det <- dbGetQuery(db, paste(
      "select *",
      "from specimens.miguel_det",
      paste0("where voucher_id in (", paste0(Coll$voucher_id,
        collapse = ","
      ), ")"),
      "order by det_date desc;"
    ))
    Det <- Det[!duplicated(Det$voucher_id), ]
    # Add names
    suppressMessages(Tax <- db2taxlist(db, tax))
    for (i in c("TaxonName", "AuthorName", "TaxonConceptID")) {
      Det[, i] <- with(Tax@taxonNames, get(i)[match(
        Det$taxon_usage_id,
        TaxonUsageID
      )])
    }
    # Add genus and family
    Tax <- tax2traits(Tax, get_names = TRUE)
    for (i in c("genus", "family")) {
      Det[, i] <- with(Tax@taxonTraits, get(i)[match(
        Det$TaxonConceptID,
        TaxonConceptID
      )])
    }
    Coll <- merge(Coll, Det[
      ,
      c(
        "voucher_id", "TaxonName", "AuthorName", "genus", "family",
        "det_name"
      )
    ],
    all = TRUE, sort = FALSE
    )
    # Coordinates
    message("OK\nImporting geographic information ... ", appendLF = FALSE)
    n_digits <- 4
    Coords <- st_coordinates(Coll)
    c_suffix <- cbind(
      c("E", "W")[match(Coords[, 1] >= 0, c(TRUE, FALSE))],
      c("N", "S")[match(Coords[, 2] >= 0, c(TRUE, FALSE))]
    )
    Coll$coordinates <- paste(
      c_suffix[, 2], format(round(Coords[, 2],
        digits = n_digits
      ), nsmall = n_digits),
      c_suffix[, 1], format(round(Coords[, 1], digits = n_digits),
        nsmall = n_digits
      )
    )
    # Get country codes
    Countries_map <- st_read(db, query = paste(
      "select *",
      "from commons.countries_map;"
    ))
    Coll$country <- Countries_map$adm0_a3[st_nearest_feature(
      Coll,
      Countries_map
    )]
    # Import GADM
    gadm <- st_read(adm, query = paste0(
      "select name_0,name_1,name_2,geom\n",
      "from gadm\n",
      "where gid_0 in ('",
      paste0(unique(Coll$country, collapse = "','"), "');\n")
    ))
    for (i in c("name_0", "name_1", "name_2")) {
      Coll[[i]] <- gadm[[i]][st_nearest_feature(Coll, gadm)]
    }
    class(Coll) <- c("specimens", "data.frame")
    message("OK\nDONE!")
    return(Coll)
  }
)

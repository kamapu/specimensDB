#' @name new_det
#'
#' @title Add new determinations to specimens.
#'
#' @description
#' Inserting new determinations to specimens stored in the database.
#'
#' Note that more than one determination at the same date for the same specimen
#' are not allowed and this will be checked before inserting new determinations.
#' You can override this by setting `'compare = TRUE'`
#'
#' @param db Connections to the database as [PostgreSQLConnection-class].
#' @param df A data frame containing the information to be appended in the
#'     determination history of the specimen. This data frame must contain
#'     following columns: **spec_id** (identifier of specimens),
#'     **taxon_usage_id** (identifier of the taxon usage name), **taxonomy**
#'     (name of the taxonomic list applied to the update), **det** (name of the
#'     person that determined the species), and **det_date** (date of
#'     determination as [Date][as.Date]).
#' @param schema Character value indicating the name of the schema containing
#'     the specimens' information.
#' @param tax_schema Character value indicating the name of the schema containng
#'     the associated taxonomic list.
#' @param compare Logical value indicating whether the determinations to be
#'     inserted should be compared with the input data frame or not (by default,
#'     not). If determinations for the same specimen at the same date are
#'     suppossed to be inserted in the database, they will be skipped.
#'     Note that duplicates in the input data frame will not be solved by this
#'     setting.
#' @param ask A logical value, whether the function retrieves an interactive
#'     request printing the data frame to be appended or not.
#' @param ... Further arguments passed among methods (not yet used).
#'
#' @return SQL commands will be executed.
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}
#'
#' @rdname new_det
#'
#' @exportMethod new_det
setGeneric(
  "new_det",
  function(db, df, ...) {
    standardGeneric("new_det")
  }
)

#' @rdname new_det
#' @aliases new_det,PostgreSQLConnection,data.frame-method
setMethod(
  "new_det",
  signature(
    db = "PostgreSQLConnection",
    df = "data.frame"
  ),
  function(db, df, schema = "specimens", tax_schema = "plant_taxonomy",
           compare = FALSE, ask = TRUE, ...) {
    col_names <- c("spec_id", "taxon_usage_id", "taxonomy", "det", "det_date")
    # Cross-checks
    if (!all(col_names %in% names(df))) {
      col_names <- col_names[!col_names %in% names(df)]
      stop(paste0(
        "Following columns are missing in 'df': '",
        paste0(col_names, collapse = "' '"), "'."
      ))
    }
    df <- df[, col_names]
    if (!is(df$det_date, "Date")) {
      stop("Class 'Date' for 'det_date' in 'df' is mandatory.")
    }
    # Skipping duplicated entries by comparing input and database
    query <- paste(
      "select spec_id,det_date",
      paste0("from \"", schema, "\".history"),
      paste0(
        "where spec_id in (", paste0(unique(df$spec_id), collapse = ","),
        ")"
      )
    )
    in_db <- dbGetQuery(db, query)
    if (compare) {
      N <- nrow(df)
      df <- df[!with(df, paste(spec_id, det_date, sep = "_")) %in%
        with(in_db, paste(spec_id, det_date, sep = "_")), ]
      message(paste(N - nrow(df), "duplicated determinations were skipped."))
    }
    # No duplicates in input
    dupl <- df[duplicated(df[, c("spec_id", "det_date")]), ]
    if (nrow(dupl) > 0) {
      print(dupl)
      stop(paste0(
        "The displayed entry is a duplicate.\n",
        "Only one determination per day is allowed ",
        "for the same specimen."
      ))
    }
    # No duplicates considering database
    dupl <- df[with(df, paste(spec_id, det_date, sep = "_")) %in%
      with(in_db, paste(spec_id, det_date, sep = "_")), ]
    if (nrow(dupl) > 0) {
      print(dupl)
      stop(paste0(
        "The displayed entry is conflicting with a deterimantion ",
        "in the database.\n",
        "Only one determination per day is allowed ",
        "for the same specimen."
      ))
    }
    # Append collection number
    query <- paste(
      "select coll_nr,spec_id",
      paste0("from \"", schema, "\".specimens"),
      paste0(
        "where spec_id in (", paste0(unique(df$spec_id), collapse = ","),
        ")"
      )
    )
    df <- merge(df, dbGetQuery(db, query))
    # Retrieve names
    query <- paste(
      "select taxon_usage_id,usage_name,author_name",
      paste0("from \"", tax_schema, "\".taxon_names"),
      paste0("where taxon_usage_id in (", paste0(df$taxon_usage_id,
        collapse = ","
      ), ")")
    )
    Names <- dbGetQuery(db, query)
    Names <- merge(df, Names, sort = FALSE, all = TRUE)
    cat("Updates of specimens determination:\n\n")
    print(Names[, c(
      "spec_id", "coll_nr", "usage_name", "author_name", "det",
      "det_date"
    )])
    if (ask) {
      OUT <- askYesNo("Do you like to proceed?")
      if (is.na(OUT)) OUT <- FALSE
    } else {
      OUT <- TRUE
    }
    if (OUT) {
      query <- paste(
        "select tax_id,taxon_usage_id,taxon_concept_id",
        paste0("from \"", tax_schema, "\".names2concepts"),
        paste0(
          "where taxon_usage_id in (",
          paste0(Names$taxon_usage_id, collapse = ","), ")"
        )
      )
      IDs <- dbGetQuery(db, query)
      query <- paste(
        "select taxon_concept_id,top_view taxonomy",
        paste0("from \"", tax_schema, "\".taxon_concepts"),
        paste0(
          "where taxon_concept_id in (",
          paste0(IDs$taxon_concept_id, collapse = ","), ")"
        )
      )
      IDs <- merge(IDs, dbGetQuery(db, query))
      Names$tax_id <- with(
        IDs,
        tax_id[match(
          paste(Names$taxon_usage_id, Names$taxonomy, sep = "_"),
          paste(taxon_usage_id, taxonomy, sep = "_")
        )]
      )
      if (any(is.na(Names$tax_id))) {
        cat("These updates does not match any tax_id in database:\n\n")
        print(Names[is.na(Names$tax_id), c(
          "spec_id", "coll_nr", "usage_name", "author_name", "det",
          "det_date"
        )])
        stop("Possible bad combination of 'taxon_usage_id' and 'taxonomy'.")
      }
      pgWriteGeom(db, c(schema, "history"), Names, partial.match = TRUE)
      message("\nDONE!")
    } else {
      stop("This update was cancelled by the user.")
    }
  }
)

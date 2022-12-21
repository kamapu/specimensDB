#' @name split_specimens
#'
#' @title Split specimens
#'
#' @description
#' Single collections may be split into multiple specimens, either stored in the
#' same herbarium or distributed to different locations.
#' This function duplicates specimens belonging to the same collection.
#'
#' @param db Connection to the database as [PostgreSQLConnection-class].
#' @param schema Character value indicating the name of the database schema
#'     containing specimens.
#' @param spec_id Integer vector with the IDs specimens that will be duplicated.
#'     If one ID is not existing in the database, this function will retrieve an
#'     error message.
#' @param add Integer vector indicating the number of duplicates that need to be
#'     created. If the length is 1, the same amount of duplicates will be
#'     created for every specimen. For specific number of duplicates, you have
#'     to provide a vector with the same length as 'spec_id'. If the lenght is
#'     neither 1 nor matching the length of 'spec_id', an error message will be
#'     retrieved.
#' @param ... Further arguments. Parameters added here will be used to set
#'     values in the specimens table that are specific for duplicates. Such
#'     values will be recycled in the case of multiple duplicates.
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}
#'
#' @rdname split_specimens
#'
#' @export
split_specimens <- function(db, ...) {
  UseMethod("split_specimens", db)
}

#' @rdname split_specimens
#' @aliases split_specimens,PostgreSQLConnection-method
#' @method split_specimens PostgreSQLConnection
#' @export
split_specimens.PostgreSQLConnection <- function(db, spec_id, add = 1,
                                                 schema = "specimens", ...) {
  # Consistent length of argument 'add'
  if (length(add) == 1) {
    add <- rep_len(add, length(spec_id))
  } else {
    if (length(add) != length(spec_id)) {
      stop(paste(
        "Argument 'add' has to be of length 1",
        "or the same length as 'spec_id'"
      ))
    }
  }
  # Retrieve selected specimens from data base
  query <- paste(
    "select *",
    paste0("from \"", schema, "\".specimens"),
    paste0("where spec_id in (", paste0(spec_id, collapse = ","), ")")
  )
  db_spec <- dbGetQuery(db, query)
  # Check all specimens IDs
  if (any(!spec_id %in% db_spec$spec_id)) {
    no_db <- spec_id[!spec_id %in% db_spec$spec_id]
    stop(paste0(
      "Following queried specimens IDs are not in the database: '",
      paste0(no_db, collapse = "', '"), "'."
    ))
  }
  # Insert additional variables
  update_vars <- list(...)
  for (i in names(update_vars)) {
    db_spec[[i]] <- rep_len(update_vars[[i]], nrow(db_spec))
  }
  # Do duplicated
  df_dupl <- data.frame(spec_id = rep(spec_id, times = add))
  db_spec <- merge(df_dupl, db_spec)
  # Do new ids
  new_spec_id <- unlist(dbGetQuery(db, paste(
    "select max(spec_id)",
    paste0("from \"", schema, "\".specimens")
  )))
  db_spec$new_spec_id <- new_spec_id + 1:nrow(db_spec)
  # Retrieve history
  query <- paste(
    "select *",
    paste0("from \"", schema, "\".history"),
    paste0("where spec_id in (", paste0(spec_id, collapse = ","), ")")
  )
  db_hist <- dbGetQuery(db, query)
  if (nrow(db_hist) > 0) {
    db_hist <- merge(db_spec[, c("spec_id", "new_spec_id")], db_hist)
  }
  # Replace IDs
  db_spec$spec_id <- db_spec$new_spec_id
  db_hist$spec_id <- db_hist$new_spec_id
  # Append tables
  dbWriteTable(db, c(schema, "specimens"),
    db_spec[, names(db_spec) != "new_spec_id"],
    append = TRUE, row.names = FALSE
  )
  dbWriteTable(db, c(schema, "history"),
    db_hist[, names(db_hist) != "new_spec_id"],
    append = TRUE, row.names = FALSE
  )
  message("\nDONE!")
}

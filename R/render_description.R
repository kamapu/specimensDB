#' @name render_description
#'
#' @title Rendering bulk description.
#'
#' @description
#' Producing a PDF file with the description of the bulk (project) using
#' [render_rmd()].
#'
#' @param db Connection to the database as [PostgreSQLConnection-class].
#' @param bulk The identifies of the bulk (project) in the database.
#' @param output Character value or list with the output settings for the yaml
#'     head.
#' @param output_file Character value with the name and path to the ouput file.
#'     I is passed to [render_rmd()].
#' @param ... Further Arguments passed to [list2rmd_doc()].
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}
#'
#' @rdname render_description
#'
#' @export
render_description <- function(db, ...) {
  UseMethod("render_description", db)
}

#' @rdname render_description
#' @aliases render_description,PostgreSQLConnection-method
#' @method render_description PostgreSQLConnection
#' @export
render_description.PostgreSQLConnection <- function(db, bulk, output = "pdf_document",
                                                    output_file, ...) {
  query <- paste(
    "select project_name,description", "from specimens.projects",
    paste("where bulk =", bulk[1])
  )
  Descr <- dbGetQuery(db, query)
  if (nrow(Descr) == 0) {
    stop("Requested 'bulk' does not exist in the database.")
  }
  Descr <- as(list(
    title = Descr$project_name, output = output,
    body = Descr$description, ...
  ), "rmd_doc")
  render_rmd(Descr, output_file = output_file)
}

#' @name project_list
#'
#' @title Render a list of all projects' descriptions.
#'
#' @description
#' A document listing all project descriptions in an overview.
#'
#' @param db Connection to the database as [PostgreSQLConnection-class].
#' @param title Character value with the title of the document.
#' @param output character value indicating the format of the output document.
#' @param rmd_args Named list of further arguments passed to [list2rmd_doc()].
#' @param ... Further arguments passed to [render_rmd()].
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}
#'
#' @rdname project_list
#'
#' @export
project_list <- function(db, ...) {
  UseMethod("project_list", db)
}

#' @rdname project_list
#' @aliases project_list,PostgreSQLConnection-method
#' @method project_list PostgreSQLConnection
#' @export
project_list.PostgreSQLConnection <- function(
    db,
    title = "Collections List",
    output = "pdf_document",
    rmd_args = list(), ...) {
  # Main table
  Projects <- dbGetQuery(db, paste(
    "select *",
    "from specimens.projects",
    "order by bulk"
  ))
  Body <- with(Projects, paste(
    "#", bulk, project_name, "\n\n",
    description, "\n\n"
  ))
  Doc <- as(
    c(list(title = title, output = output, body = Body), rmd_args),
    "rmd_doc"
  )
  render_rmd(Doc, ...)
}

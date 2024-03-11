#' @name description_sheet
#'
#' @title Export a description sheet in PDF format.
#'
#' @description
#' Automatic rendering of an overview sheet for a specific bulk.
#'
#' @param db Connection to the database as [PostgreSQLConnection-class].
#' @param schema A character value with the names of the schema containing the
#'     table of the projects (mandatory name of this table is **projects**).
#' @param bulk Integer vector including the ID's of the requested bulks
#'     (campaigns or projects).
#' @param wd A character value indicating the path to store produced files (i.e.
#'     Figures and r-markdown files.
#' @param output_file A character value indicating the name of the rendered PDF
#'     file.
#' @param output A character value or a list included in the yaml header.
#' @param date_format A character value indicating the format of displayed
#'     collection dates.
#' @param p_tiles A character vector indicating the name of provider tiles used
#'     as background map. It is passed to [addProviderTiles()].
#' @param zoomLevelFixed An integer value passed to [addMiniMap()].
#' @param vwidth,vheight An integer value each, passed to [mapshot()].
#' @param render_args A named list with arguments passed to [render_rmd()].
#' @param ... Further arguments passed to [list2rmd_doc()].
#'
#' @return A PDF file will be written.
#'
#' @author Miguel Alvarez \email{kamapu@@posteo.com}
#'
#' @rdname description_sheet
#'
#' @export
description_sheet <- function(db, ...) {
  UseMethod("description_sheet", db)
}

#' @rdname description_sheet
#' @aliases description_sheet,PostgreSQLConnection-method
#' @method description_sheet PostgreSQLConnection
#' @export
description_sheet.PostgreSQLConnection <- function(
    db,
    schema = "specimens",
    bulk, wd = tempdir(),
    output_file,
    output = "pdf_document",
    ...,
    date_format = "%d.%m.%Y",
    p_tiles = "OpenStreetMap",
    zoomLevelFixed = 5,
    vwidth = 1200, vheight = 500,
    render_args = list()) {
  Spec <- read_specimens(db, bulk = bulk[1])
  query <- paste(
    "select *",
    paste0("from \"", schema, "\".projects"),
    paste0("where bulk = ", bulk[1])
  )
  Descr <- unlist(dbGetQuery(db, query))
  map_file <- tempfile(tmpdir = wd, fileext = ".png")
  Map <- leaflet(Spec@collections) %>%
    addProviderTiles(p_tiles) %>%
    addScaleBar(position = "topright") %>%
    addCircleMarkers(
      color = "red",
      fillColor = "yellow",
      stroke = TRUE,
      weight = 2,
      opacity = 1,
      fillOpacity = 0.5,
      radius = 6
    ) %>%
    addMiniMap(zoomLevelFixed = zoomLevelFixed)
  mapshot2(Map,
    file = map_file, vwidth = vwidth, vheight = vheight,
    remove_controls = c(
      "zoomControl", "layersControl", "homeButton",
      "drawToolbar", "easyButton"
    )
  )
  # Format collection period
  DAT <- paste0(format(
    unique(range(Spec@collections$coll_date)),
    date_format
  ), collapse = " -- ")
  # Format specimen location
  Loc <- with(Spec@specimens, summary(as.factor(herbarium[!is.na(herbarium)])))
  Loc <- paste(Loc, names(Loc), sep = " in ")
  Loc <- paste0(Loc, collapse = ", ")
  Loc <- paste0(sum(!is.na(Spec@specimens$herbarium)), " (", Loc, ")")
  Doc <- as(list(
    title = Descr["project_name"], output = output, body = txt_body(c(
      "\\sffamily",
      "",
      "# Description",
      "",
      Descr["description"],
      "",
      "# Statistics",
      "",
      paste0("**Collector(s):** ", paste0(unique(Spec@collections$leg),
        collapse = ", "
      )),
      "",
      paste0("**Collection Period:** ", DAT),
      "",
      paste0("**Collected Specimens:** ", nrow(Spec@specimens)),
      "",
      paste0("**Stored Specimens:** ", Loc),
      "",
      paste0("**Disposed Specimens:** ", sum(Spec@specimens$gone)),
      "",
      "# Geographic Distribution",
      "",
      paste0("![](", map_file, ")")
    )), ...
  ), "rmd_doc")
  if (missing(output_file)) {
    output_file <- tempfile(tmpdir = wd)
  }
  do.call(render_rmd, c(
    list(input = Doc, output_file = output_file),
    render_args
  ))
}

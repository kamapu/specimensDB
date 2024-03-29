% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/description_sheet.R
\name{description_sheet}
\alias{description_sheet}
\alias{description_sheet.PostgreSQLConnection}
\alias{description_sheet,PostgreSQLConnection-method}
\title{Export a description sheet in PDF format.}
\usage{
description_sheet(db, ...)

\method{description_sheet}{PostgreSQLConnection}(
  db,
  schema = "specimens",
  bulk,
  wd = tempdir(),
  output_file,
  output = "pdf_document",
  ...,
  date_format = "\%d.\%m.\%Y",
  p_tiles = "OpenStreetMap",
  zoomLevelFixed = 5,
  vwidth = 1200,
  vheight = 500,
  render_args = list()
)
}
\arguments{
\item{db}{Connection to the database as \linkS4class{PostgreSQLConnection}.}

\item{...}{Further arguments passed to \code{\link[=list2rmd_doc]{list2rmd_doc()}}.}

\item{schema}{A character value with the names of the schema containing the
table of the projects (mandatory name of this table is \strong{projects}).}

\item{bulk}{Integer vector including the ID's of the requested bulks
(campaigns or projects).}

\item{wd}{A character value indicating the path to store produced files (i.e.
Figures and r-markdown files.}

\item{output_file}{A character value indicating the name of the rendered PDF
file.}

\item{output}{A character value or a list included in the yaml header.}

\item{date_format}{A character value indicating the format of displayed
collection dates.}

\item{p_tiles}{A character vector indicating the name of provider tiles used
as background map. It is passed to \code{\link[=addProviderTiles]{addProviderTiles()}}.}

\item{zoomLevelFixed}{An integer value passed to \code{\link[=addMiniMap]{addMiniMap()}}.}

\item{vwidth, vheight}{An integer value each, passed to \code{\link[=mapshot]{mapshot()}}.}

\item{render_args}{A named list with arguments passed to \code{\link[=render_rmd]{render_rmd()}}.}
}
\value{
A PDF file will be written.
}
\description{
Automatic rendering of an overview sheet for a specific bulk.
}
\author{
Miguel Alvarez \email{kamapu@posteo.com}
}

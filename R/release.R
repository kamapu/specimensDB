#' @name release
#'
#' @rdname release
#'
#' @title Release a table for an herbarium
#'
#' @description
#' Processing data frame obtained by [read_spec()] to be released at a
#' respective herbarium.
#'
#' Some herbaria have a template for storage of data.
#'
#' @param x A [specimens-class] object retrieved by [read_spec()].
#' @param herb A character value containig the code of the herbarium for the
#'     release.
#' @param ... Further arguments passed among methods (not in use).
#'
#' @return
#' A data frame with columns sorted and named for release at a respective
#' herbarium.
#'
#' @export
release <- function(x, ...) {
  UseMethod("release", x)
}

#' @rdname release
#'
#' @aliases release,specimens-method
#'
#' @method release specimens
#'
#' @export
release.specimens <- function(x, herb, ...) {
  if (!herb[1] %in% names(translator)) {
    stop(paste0(
      "The herbarium '", herb[1],
      "' is not in the installed catalog."
    ))
  }
  names(x) <- with(
    translator[[herb]][!is.na(translator[[herb]]$"in"), ],
    replace_x(names(x), get("in"), get("out"))
  )
  for (i in translator[[herb]][is.na(translator[[herb]][, "in"]), "out"]) {
    x[[i]] <- rep(NA, length(x[[1]]))
  }
  x <- x[match(translator[[herb]][, "out"], names(x))]
  class(x) <- "data.frame"
  return(x)
}

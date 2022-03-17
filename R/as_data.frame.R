#' @name as_data.frame
#'
#' @rdname as_data.frame
#'
#' @title Coerce specimens to data frame objects
#'
#' @description
#' A straight-forward method to coerce objects of class [specimens-class] to
#' [data.frame]. In the case that the collection is an object of class [sf],
#' coordinate values will be extracted as **longitude** and **latitude**.
#'
#' @param x A [specimens-class].
#' @param ... Further arguments passed among methods (not used yet).
#'
#' @return
#' A [data.frame] object.
#'
#' @export
as_data.frame <- function(x, ...) {
  UseMethod("as_data.frame", x)
}

#' @rdname as_data.frame
#'
#' @aliases as_data.frame,specimens-method
#'
#' @method as_data.frame specimens
#'
#' @export
as_data.frame.specimens <- function(x, ...) {
  if (class(x@collections)[1] == "sf") {
    Coords <- st_coordinates(x@collections)
    x@collections$longitude <- Coords[, "X"]
    x@collections$latitude <- Coords[, "Y"]
    OUT <- st_drop_geometry(x@collections)
  }
  OUT <- merge(x@specimens, OUT, by = "coll_nr", all = TRUE, sort = FALSE)
  Det <- x@history[order(x@history$det_date, decreasing = TRUE), ]
  Det <- Det[!duplicated(Det$spec_id), ]
  return(merge(OUT, Det, by = "spec_id", all = TRUE, sort = FALSE))
}

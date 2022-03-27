#' @importFrom methods as new setOldClass
#' @importFrom DBI dbGetQuery
#' @importFrom sf st_coordinates st_drop_geometry st_nearest_feature st_read
#' @importFrom taxlist replace_x dissect_name
#' @importFrom utils askYesNo
#' @importFrom rpostgis pgInsert
#' @importFrom taxlist dissect_name replace_x
#' @importFrom yamlme render_rmd txt_body write_rmd
#' @importFrom specimens as_data.frame
#' @importClassesFrom specimens specimens
#' @importClassesFrom RPostgreSQL PostgreSQLConnection
#' @importClassesFrom yamlme rmd_doc
NULL

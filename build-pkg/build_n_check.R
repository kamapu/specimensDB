# TODO:   Working script for testing the package 'gisrepos'
# 
# Author: Miguel Alvarez
################################################################################

library(devtools)
library(styler)
library(rmarkdown)

# Improve coding style
style_pkg()

## source("data-raw/import-references.R")
document()

# clean built package and manual
## Folder <- tempdir()
Folder <- "build-pkg"
Files <- list.files(Folder, ".tar.gz|.pdf")
unlink(file.path(Folder, Files))

# Re-build package and manual
pkg_loc <- build(path = Folder)
build_manual(path = Folder)

# common check
check_built(path = pkg_loc)

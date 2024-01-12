# TODO:   Working script for testing the package source
# 
# Author: Miguel Alvarez
################################################################################

library(devtools)
library(styler)
library(rmarkdown)

# Improve coding style
style_pkg()

# Write system data and document
source("data-raw/create-data.R")
document()

# clean built package and manual
## Folder <- tempdir()
Folder <- "build-pkg"
Files <- list.files(Folder, ".tar.gz|.pdf")
unlink(file.path(Folder, Files))

# Build package and check
pkg_loc <- build(path = Folder)
check_built(path = pkg_loc)

# a posteriori -----------------------------------------------------------------
build_manual(path = Folder)
install()

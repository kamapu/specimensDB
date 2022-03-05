# TODO:   Writting a table for release at the herbarium
# 
# Author: Miguel Alvarez
################################################################################

library(taxlist)

x <- readRDS("lab/specimens.rds")
load("R/sysdata.rda")
source("R/classes.R")
source("R/release.R")

## herb = "FB"
new_table <- release(specimens, "BONN")

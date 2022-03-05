# TODO:   Script creating data from data-raw
#
# Author: Miguel Alvarez
################################################################################

library(readODS)

translator <- read_ods("data-raw/var_translator.ods")
translator <- split(translator[, c("in", "out")], translator$Herbarium)

save(translator, file = "R/sysdata.rda")

# TODO:   Add comment
# 
# Author: Miguel Alvarez
################################################################################

# Install development version
library(devtools)
install_github("kamapu/specimensDB", "devel")

# Load packages
library(yamlme)
library(RPostgreSQL)
library(vegtableDB)
library(specimensDB)

# Required parameters
conn <- connect_db("vegetation_v3", user = "miguel")

project_list(conn, output_file = "lab/all-projects2")

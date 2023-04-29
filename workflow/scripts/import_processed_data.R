library(utils)
library(tidyverse)
library(yaml)
library(rhdf5)
library(Matrix)
library(ape)

source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

if (!dir.exists("data")){dir.create("data")}

file.copy("~/Dropbox/MICROBIOME/imap-data-processing/data/external/external_ps_objects.rda", "data/processed_data.rda", overwrite = TRUE)

# Rmd template
if (!dir.exists("bs4_viz_books")){dir.create("bs4_viz_books")}
download.file("https://github.com/yiluheihei/microbiomeMarker/blob/master/vignettes/microbiomeMarker-vignette.Rmd", "bs4_viz_books/markers_analysis.Rmd")



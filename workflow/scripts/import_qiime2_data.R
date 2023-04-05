library(utils)

source("workflow/scripts/common.R")

if (!dir.exists("data")){
  dir.create("data")
}else{
  print("dir exists")
}

download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/table.qza", "data/feature_table.qza")
download.file("https://data.qiime2.org/2018.4/tutorials/moving-pictures/sample_metadata.tsv", "data/sample_metadata.tsv")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/taxonomy.qza", "data/taxonomy.qza")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/rooted-tree.qza", "data/rooted_tree.qza")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/core-metrics-results/shannon_vector.qza", "data/shannon_vector.qza")

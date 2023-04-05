library(qiime2R)
library(phyloseq)
library(tidyverse)

## Phyloseq object
q2_ps <- qiime2R::qza_to_phyloseq(
  features="data/feature_table.qza", 
  taxonomy = "data/taxonomy.qza", 
  tree = "data/rooted_tree.qza", 
  metadata="data/sample_metadata.tsv") 

q2_ps %>% 
  saveRDS(file = "data/q2_phyloseq.rds")



library(phyloseq)
library(tidyverse)
library(yaml)
library(rhdf5)
library(Matrix)
library(ape)

source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

## Phyloseq object using demo data
q2_ps <- qza_to_phyloseq(
  features="../imap-bioinformatics-qiime2/qiime2_process/feature-table.qza", 
  taxonomy = "../imap-bioinformatics-qiime2/qiime2_process/taxonomy.qza", 
  tree = "../imap-bioinformatics-qiime2/qiime2_process/rooted-tree.qza", 
  metadata="../imap-bioinformatics-qiime2/resources/metadata/qiime2_metadata_file.tsv")
q2_ps

q2_ps %>% 
  saveRDS(file = "data/q2_ps.rds")






## Demo phyloseq object using demo data
q2_demo_ps <- qza_to_phyloseq(
  features="resources/feature_table.qza", 
  taxonomy = "resources/taxonomy.qza", 
  tree = "resources/rooted_tree.qza", 
  metadata="resources/sample_metadata.tsv")

q2_demo_ps %>% 
  saveRDS(file = "data/q2_demo_ps.rds")

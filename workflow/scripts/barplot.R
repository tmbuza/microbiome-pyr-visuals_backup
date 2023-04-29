source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

library(tidyverse)
library(tools)
library(yaml)
library(rhdf5)
library(Matrix)

metadata<-read_q2metadata("resources/sample_metadata.tsv")
ASVs<-read_qza("resources/feature_table.qza")$data
taxonomy<-read_qza("resources/taxonomy.qza")$data %>% parse_taxonomy()

taxasums<-summarize_taxa(ASVs, taxonomy)$Genus

taxa_barplot(taxasums, metadata, "BodySite")

# ggsave("figures/barplot.pdf", height=4, width=8, device="pdf")
ggsave("figures/q2r_barplot.png", height=4, width=8, device="png")
ggsave("figures/q2r_barplot.svg", height=4, width=8, device="svg")

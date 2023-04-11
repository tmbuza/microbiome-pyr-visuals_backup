
source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

library(utils)
library(tidyverse)
library(yaml)
library(rhdf5)
library(Matrix)
library(ape)

if (!dir.exists("data")){dir.create("data")}

# Extract and process CSV qiime2 dataset

metadata <- read_q2metadata("data/sample_metadata.tsv") %>% 
  as.data.frame() %>% 
  rename(sample_id="SampleID") 
head(metadata)

metadata %>% 
  write_csv("data/metadata.csv")


features <- read_qza("data/feature_table.qza")$data %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column(., "feature")
head(features)

features %>% 
  write_csv("data/features.csv")


taxonomy <- read_qza("data/taxonomy.qza")$data %>% 
  as.data.frame() %>%
  rename(feature="Feature.ID") 
head(taxonomy)

taxonomy %>% 
  write_csv("data/taxonomy.csv")


shannon <- read_qza("data/shannon.qza")$data %>% 
  as.data.frame() %>%
  tibble::rownames_to_column(., "sample_id") %>% 
  rename(shannon="shannon_entropy") 
head(shannon)

shannon %>% 
  write_csv("data/shannon.csv")


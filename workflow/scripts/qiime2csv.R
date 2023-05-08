source("workflow/scripts/common.R")
# source("workflow/scripts/qiime2R.R")

library(qiime2R)
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


metadata %>% 
  write_csv("data/metadata.csv")


features <- read_qza("data/feature_table.qza")$data %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column(., "feature")


features %>% 
  write_csv("data/features.csv")


taxonomy <- read_qza("data/taxonomy.qza")$data %>% 
  as.data.frame() %>%
  rename(feature="Feature.ID") 


taxonomy %>% 
  write_csv("data/taxonomy.csv")


shannon <- read_qza("data/shannon_vector.qza")$data %>% 
  tibble::rownames_to_column(., "sample_id") %>% 
  as.data.frame()

shannon %>% 
  write_csv("data/shannon.csv")


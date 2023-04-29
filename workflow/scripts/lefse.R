library(ggtext)
library(glue)
library(broom)
library(tidyverse)
set.seed(110912)

metadata <- readRDS("../microbiome-part1/RDataRDS/mo_metadata.rds") %>% 
  dplyr::select(sample_id, isolate) %>% 
  drop_na(isolate)

shared_file <- read_tsv("~/Dropbox/CDILLC/GIT_REPOS/smda-end2end/data/final.tx.1.subsample.shared", show_col_types = F)


shared_design <- inner_join(shared_file, metadata, by=c("Group" = "sample_id"))
# shared_design %>% 
#   colnames() %>% 
#   tail

run_lefse <- function(x, y, tag) {
  x_y <- shared_design %>%
    filter(isolate == x | isolate == y)
  
  x_y %>% 
    dplyr::select(-isolate) %>% 
    write_tsv(glue("RDataRDS//bush_{tag}.shared"))
  
  x_y %>% 
    dplyr::select(Group, isolate) %>% 
    write_tsv(glue("RDataRDS//bush_{tag}.design"))
  
  command <- glue('mothur/mothur "#lefse(shared=bush_{tag}.shared, design=bush_{tag}.design, inputdir=RDataRDS, outputdir=RDataRDS/mothur_out)"')
  
  system(command)
  
  return(glue("bush_{tag}.1.lefse_summary"))

}


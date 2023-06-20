library(phyloseq)
library(tidyverse)



ps_df <- psmelt(readRDS("data/ps_raw.rds")) %>% 
  group_by(Sample) %>%
  mutate(total = sum(Abundance)) %>%
  dplyr::filter(total > 0) %>%
  dplyr::filter(Abundance >0) %>%
  group_by(OTU) %>%
  mutate(total = sum(Abundance)) %>%
  dplyr::filter(total != 0) %>%
  ungroup() %>%
  select(-total) %>% as.data.frame() %>% 
  group_by(Sample) %>% 
  mutate(rel_abund = Abundance/sum(Abundance)) %>% 
  ungroup() %>% 
  relocate(Abundance, .before = rel_abund) %>%
  rename_all(~ make.unique(tolower(.), sep = "_")) %>% 
  rename(sample_id = sample,
         count = abundance,
         bmi = bmi_group,
         grp = group,
         timewithingrp = timepoint.within.group) %>% 
  pivot_longer(cols = c("phylum", "family", "genus", "otu"), names_to = "level", values_to = "taxon") %>%
  mutate(taxon = str_replace(string = taxon,
                            pattern = "(.*)",
                            replacement = "*\\1*"),
        taxon = str_replace(string = taxon,
                            pattern = "\\*(.*)_unclassified\\*",
                            replacement = "Unclassified<br>*\\1*"),
        taxon = str_replace_all(taxon, "_", " "))

saveRDS(ps_df, file = "data/ps_df.rds")
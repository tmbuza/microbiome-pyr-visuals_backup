library(tidyverse)
library(phyloseq)
library(microbiome)

# Load the dietswap dataset from the microbiome package
data("dietswap", package = "microbiome")
ps <- dietswap

ps_df <- psmelt(ps)  %>%
  mutate(
    Genus = str_replace_all(Genus, " et rel.", ""),
    Genus = str_replace_all(Genus, " at rel.", ""))

otu_table <- ps_df %>% 
  pivot_wider(id_cols = "OTU", names_from = "Sample", values_from = "Abundance") %>% 
  mutate(OTU = paste0("OTU", sprintf("%03d", 1:nrow(otu_table(ps))))) %>% 
  tibble::column_to_rownames("OTU") %>% 
  otu_table(otu_table, taxa_are_rows = TRUE)


tax_table <- ps_df %>% 
  select("OTU", "Phylum", "Family", "Genus") %>%  
  distinct() %>% 
  mutate(OTU = paste0("OTU", sprintf("%03d", 1:nrow(otu_table(ps))))) %>% 
  tibble::column_to_rownames("OTU") %>% 
  as.matrix() %>% 
  tax_table(tax_table)

ps_basic<- merge_phyloseq(otu_table, tax_table, sample_data(ps))
## Add phylo tree

library(ape)
ps_tree = rtree(ntaxa(ps_basic), rooted=TRUE, tip.label=taxa_names(ps_basic))

ps_raw <- phyloseq::merge_phyloseq(ps_basic, ps_tree)

ps_rel <- phyloseq::transform_sample_counts(ps_raw, function(x){x / sum(x)})

saveRDS(ps_raw, "data/ps_raw.rds")
saveRDS(ps_rel, "data/ps_rel.rds")
save(ps_raw, ps_rel, file = "data/phyloseq_objects.rda")


library(tidyverse)
library(microViz)
library(phyloseq)
library(microbiome)
library(ComplexHeatmap)
library(viridis)


load("data/phyloseq_objects.rda")
ps <- ps_z_sample

ps %>%
  ps_mutate(nationality = as.character(nationality)) %>%
  tax_transform("log10p", add = 1, chain = TRUE) %>%
  comp_heatmap(
    taxa = tax_top(ps_raw, n = 30), grid_col = NA, name = "Log2p",
    taxon_renamer = function(x) stringr::str_remove(x, " [ae]t rel."),
    colors = heat_palette(palette = viridis::turbo(10)),
    row_names_side = "left", row_dend_side = "right", sample_side = "bottom",
    sample_anno = sampleAnnotation(
      Nationality = anno_sample_cat(
        var = "nationality", col = c(AAM = "red", AFR = "green"),
        box_col = NA, legend_title = "Nationality", size = grid::unit(4, "mm")
      )
    )
  ) +
  labs(x = "Sample", y = "Operational Taxonomic Units", title = "Heatmap using phyloseq package") 



ps_raw %>% phyloseq::plot_heatmap() +
  labs(x = "Sample", y = "Operational Taxonomic Units", title = "Heatmap using phyloseq package") +
  scale_fill_viridis(direction = -1)




## Heatmap using `microbiome` package

library(microbiome)

load("data/bray_distances.rda")
ps <- ps_log10p

# Pick data subset
ps_sub1 <- ps %>% subset_taxa(Phylum == "Bacteroidetes")


# Plot the abundances heatmap
dfm <- data.frame(psmelt(ps_sub1)) %>% 
  select(OTU, Sample, value = Abundance) %>% 
  mutate(OTU = str_remove(OTU, " et rel."),
         OTU = str_remove(OTU, " at rel."),
         value = round(value, digits = 2)) %>% 
  group_by(Sample) %>% 
  filter(value > 0) %>% 
  group_by(OTU) %>% 
  filter(value > 0) %>% 
  ungroup()

dfm %>% 
  as.data.frame() %>% 
heat("OTU", "Sample", "value") +
  theme(text=element_text(size=10), 
        axis.text.x = element_text(angle = 90, hjust = 1),
        legend.key.size = unit(1.2, "cm")) +
  # scale_fill_viridis(direction = -1)+
  labs(title = "Bacterioides taxa distribution across samples")


ps_sub2 <- ps %>% subset_taxa(Phylum == "Firmicutes")

# Plot the abundances heatmap
dfm <- data.frame(psmelt(ps_sub2)) %>% 
  select(OTU, Sample, value = Abundance) %>% 
  mutate(OTU = str_remove(OTU, " et rel."),
         OTU = str_remove(OTU, " at rel."),
         value = round(value, digits = 2)) %>% 
  group_by(Sample) %>% 
  filter(value > 0) %>% 
  group_by(OTU) %>% 
  filter(value > 0) %>% 
  ungroup()

dfm %>% 
  as.data.frame() %>% 
heat("OTU", "Sample", "value") +
  theme(text=element_text(size=10), 
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.key.size = unit(1.2, "cm")) +
  # scale_fill_viridis(direction = -1) +
  labs(title = "Firmicutes taxa distribution across samples")

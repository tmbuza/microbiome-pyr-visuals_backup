source("workflow/scripts/common.R")
# source("workflow/scripts/qiime2R.R")

library(tidyverse)
library(tools)
library(yaml)
library(rhdf5)
library(Matrix)
library(qiime2R)
library(microViz)

metadata<-read_q2metadata("data/sample_metadata.tsv")
ASVs<-read_qza("data/feature_table.qza")$data
taxonomy<-read_qza("data/taxonomy.qza")$data %>% parse_taxonomy()

taxasums<-summarize_taxa(ASVs, taxonomy)$Genus

taxa_heatmap(taxasums, metadata, "BodySite")

# ggsave("figures/heatmap.pdf", height=4, width=8, device="pdf")
ggsave("figures/q2r_heatmap.png", height=4, width=8, device="png")
ggsave("figures/q2r_heatmap.svg", height=4, width=8, device="svg")


library(tidyverse)
library(vegan)
library(phyloseq)

load("data/processed_objects.rda", verbose=TRUE)
ps <- ps_dietswap

otutable <- otu_table(ps) %>% 
  psmelt() %>% 
  group_by(Sample) %>%
  mutate(N = sum(Abundance)) %>%
  ungroup()

n=min(otutable$N)
      
otutable <- otutable %>% 
  filter(N >= n) %>%
  select(-N) %>% 
  pivot_wider(names_from="OTU", values_from="Abundance", values_fill=0) %>%
  column_to_rownames("Sample")


## Getting Bray-`Curtis` distances

bray <- avgdist(otutable, dmethod="bray", sample=1776) %>%
  as.matrix() %>%
  as_tibble(rownames = "A") %>%
  pivot_longer(-A, names_to="B", values_to="distances")

bray %>%
  ggplot(aes(x=A, y=B, fill=distances)) +
  geom_tile()

## Getting `Jaccard` distances
jaccard <- avgdist(otutable, dmethod="jaccard", sample=1776) %>%
  as.matrix() %>%
  as_tibble(rownames = "A") %>%
  pivot_longer(-A, names_to="B", values_to="distances")

jaccard %>%
  ggplot(aes(x=A, y=B, fill=distances)) +
  geom_tile()


## Some params

labels <- tibble(
  x=c(50, 190),
  y=c(190, 30),
  label=c("Bray-Curtis", "Jaccard")
)

inner_join(bray, jaccard, by=c("A", "B")) %>%
  select(A, B, bray=distances.x, jaccard=distances.y) %>%
  mutate(distances = if_else(A < B, bray, jaccard)) %>%
  ggplot(aes(x=A, y=B, fill=distances)) +
  geom_tile() +
  geom_text(data=labels, aes(x=(x), y=y, label=label), inherit.aes=FALSE,
            size=10) +
  scale_fill_gradient(low="#FF0000", high="#FFFFFF", name=NULL) +
  labs(x="", y="") +
  theme_classic() +
  theme(axis.line=element_blank(),
        # axis.ticks = element_blank(),
        axis.text.y = element_text(hjust= 0.5),
        axis.text.x = element_text(angle = 90, size = 6),
        axis.text = element_blank())


ggsave("figures/ggplot_heatmap.png", height=4, width=8, device="png")
ggsave("figures/ggplot_heatmap.svg", height=4, width=8, device="svg")


htmp <- ps_dietswap %>%
  ps_mutate(nationality = as.character(nationality)) %>%
  tax_transform("log2", add = 1, chain = TRUE) %>%
  comp_heatmap(
    taxa = tax_top(ps_dietswap, n = 30), grid_col = NA, name = "Log2p",
    taxon_renamer = function(x) stringr::str_remove(x, " [ae]t rel."),
    colors = heat_palette(palette = viridis::turbo(11)),
    row_names_side = "left", row_dend_side = "right", sample_side = "bottom",
    sample_anno = sampleAnnotation(
      Nationality = anno_sample_cat(
        var = "nationality", col = c(AAM = "red", AFR = "green"),
        box_col = NA, legend_title = "Nationality", size = grid::unit(4, "mm")
      )
    )
  )

ComplexHeatmap::draw(
  object = htmp,
  sample_anno = sampleAnnotation(
    Nationality = anno_sample_cat(
      var = "nationality", 
      col = c(AAM = "red", AFR = "green"),
      box_col = NA, 
      legend_title = "Nationality", 
      size = grid::unit(4, "mm")annotation_legend_list = attr(htmp, "AnnoLegends"),
      merge_legends = TRUE
    )
  )
)

ggsave("figures/microviz_heatmap.png", height=4, width=8, device="png")
ggsave("figures/microviz_heatmap.svg", height=4, width=8, device="svg")

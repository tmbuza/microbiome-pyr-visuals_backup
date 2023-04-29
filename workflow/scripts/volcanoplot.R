source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

library(tidyverse)
library(qiime2R)
library(ggrepel)
library(ggtree)
library(ape)

metadata<-read_q2metadata("resources/sample_metadata.tsv")
ASVs<-read_qza("resources/feature_table.qza")$data
download.file("https://library.qiime2.org/plugins/q2-aldex2/24/")
results<-read_qza("differentials.qza")$data
taxonomy<-read_qza("resources/taxonomy.qza")$data %>% parse_taxonomy()
tree<-read_qza("resources/rooted_tree.qza")$data

results %>%
  left_join(taxonomy) %>%
  mutate(Significant=if_else(we.eBH<0.1,TRUE, FALSE)) %>%
  mutate(Taxon=as.character(Taxon)) %>%
  mutate(TaxonToPrint=if_else(we.eBH<0.1, Taxon, "")) %>% #only provide a label to signifcant results
  ggplot(aes(x=diff.btw, y=-log10(we.ep), color=Significant, label=TaxonToPrint)) +
  geom_text_repel(size=1, nudge_y=0.05) +
  geom_point(alpha=0.6, shape=16) +
  theme_q2r() +
  xlab("log2(fold change)") +
  ylab("-log10(P-value)") +
  theme(legend.position="none") +
  scale_color_manual(values=c("black","red"))
ggsave("volcano.pdf", height=3, width=3, device="pdf")

# ggsave("figures/heatmap.pdf", height=4, width=8, device="pdf")
ggsave("figures/q2r_volcanoplot.png", height=4, width=8, device="png")
ggsave("figures/q2r_volcanoplot.svg", height=4, width=8, device="svg")



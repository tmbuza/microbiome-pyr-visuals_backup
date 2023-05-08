source("workflow/scripts/common.R")
# source("workflow/scripts/qiime2R.R")

library(qiime2R)
library(tidyverse)
library(tools)
library(yaml)
library(rhdf5)
library(Matrix)

download.file("https://docs.qiime2.org/2020.2/data/tutorials/moving-pictures/core-metrics-results/unweighted_unifrac_pcoa_results.qza", "data/unweighted_unifrac_pcoa.qza")

metadata<-read_q2metadata("data/sample_metadata.tsv")
uwunifrac<-read_qza("data/unweighted_unifrac_pcoa.qza")
shannon<-read_qza("data/shannon_vector.qza")$data %>% rownames_to_column("SampleID") 

uwunifrac$data$Vectors %>%
  select(SampleID, PC1, PC2) %>%
  left_join(metadata) %>%
  left_join(shannon) %>%
  ggplot(aes(x=PC1, y=PC2, color=BodySite, shape=ReportedAntibioticUsage, size=shannon)) +
  geom_point(alpha=0.5) +
  theme_bw() +
  scale_shape_manual(values=c(16,1), name="Antibiotic Usage") + 
  scale_size_continuous(name="Shannon Diversity") +
  scale_color_discrete(name="Body Site")

# ggsave("PCoA.pdf", height=4, width=5, device="pdf")
ggsave("figures/q2r_pcoa.png", height=4, width=5, device="png")
ggsave("figures/q2r_pcoa.svg", height=4, width=5, device="svg")
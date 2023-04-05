library(qiime2R)
library(phyloseq)
library(tidyverse)

source("workflow/scripts/common.R")

if (!dir.exists("data")){
  dir.create("data")
}else{
  print("dir exists")
}

download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/table.qza", "data/feature_table.qza")
download.file("https://data.qiime2.org/2018.4/tutorials/moving-pictures/sample_metadata.tsv", "data/sample_metadata.tsv")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/taxonomy.qza", "data/taxonomy.qza")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/rooted-tree.qza", "data/rooted-tree.qza")
download.file("https://docs.qiime2.org/2018.4/data/tutorials/moving-pictures/core-metrics-results/shannon_vector.qza", "data/shannon_vector.qza")

ps <- qza_to_phyloseq(
  features="data/feature_table.qza", 
  taxonomy = "data/taxonomy.qza", 
  tree = "data/rooted-tree.qza", 
  metadata="data/sample_metadata.tsv")


metadata <-
  read_tsv("data/sample_metadata.tsv", comment="#q2:types", show_col_types = FALSE) #to exclude the column denoting the variable class

read_qza("data/shannon_vector.qza")$data %>%
  as.data.frame() %>%
  rownames_to_column("#SampleID") %>% # to allow a smooth joining with the metadata
  left_join(metadata) %>%
  ggplot(aes(
      x=DaysSinceExperimentStart, 
      y=shannon, 
      group=BodySite, 
      color=BodySite)) +
  geom_line() +
  geom_point() +
  facet_wrap(~Subject) + #make a separate plot for each subject
  theme_bw()

library(tidyverse)
library(qiime2R)

download.file("https://data.qiime2.org/2020.2/tutorials/moving-pictures/sample_metadata.tsv", "data/sample_metadata.tsv")
download.file("https://docs.qiime2.org/2020.2/data/tutorials/moving-pictures/core-metrics-results/shannon_vector.qza", "data/shannon_vector.qza")

metadata<-read_q2metadata("data/sample_metadata.tsv")
shannon<-read_qza("data/shannon_vector.qza")

shannon <- shannon$data %>%
  rownames_to_column("SampleID") # this moves the sample names to a new column that matches the metadata and allows them to be merged

gplots::venn(list(metadata=metadata$SampleID, shannon=shannon$SampleID))

metadata <- metadata %>% 
  left_join(shannon)

head(metadata)


metadata %>%
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=`days-since-experiment-start`, y=shannon, color=`body-site`)) +
  stat_summary(geom="errorbar", fun.data=mean_se, width=0) +
  stat_summary(geom="line", fun.data=mean_se) +
  stat_summary(geom="point", fun.data=mean_se) +
  xlab("Days") +
  ylab("Shannon Diversity") +
  theme_q2r() + # try other themes like theme_bw() or theme_classic()
  scale_color_viridis_d(name="Body Site") # use different color scale which is color blind friendly

# ggsave("figures/Shannon_by_time.pdf", height=3, width=4, device="pdf") # save a PDF 3 inches by 4 inches
ggsave("figures/Shannon_by_time.png", height=3, width=4, device="png") # save a PDF 3 inches by 4 inches
ggsave("figures/Shannon_by_time.svg", height=3, width=4, device="svg") # save a PDF 3 inches by 4 inches


metadata %>%
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=`reported-antibiotic-usage`, y=shannon, fill=`reported-antibiotic-usage`)) +
  stat_summary(geom="bar", fun.data=mean_se, color="black") + #here black is the outline for the bars
  geom_jitter(shape=21, width=0.2, height=0) +
  coord_cartesian(ylim=c(2,7)) + # adjust y-axis
  facet_grid(~`body-site`) + # create a panel for each body site
  xlab("Antibiotic Usage") +
  ylab("Shannon Diversity") +
  theme_q2r() +
  scale_fill_manual(values=c("cornflowerblue","indianred")) + #specify custom colors
  theme(legend.position="none")


metadata %>%
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=subject, y=shannon, fill=`subject`)) +
  stat_summary(geom="bar", fun.data=mean_se, color="black") + #here black is the outline for the bars
  geom_jitter(shape=21, width=0.2, height=0) +
  coord_cartesian(ylim=c(2,7)) + # adjust y-axis
  facet_grid(~`body-site`) + # create a panel for each body site
  xlab("Antibiotic Usage") +
  ylab("Shannon Diversity") +
  theme_q2r() +
  scale_fill_manual(values=c("cornflowerblue","indianred")) + #specify custom colors
  theme(legend.position="none") #remove the legend as it isn't needed
ggsave("Shannon_by_person.pdf", height=3, width=4, device="pdf") # save a PDF 3 inches by 4 inches



download.file("https://data.qiime2.org/2020.2/tutorials/moving-pictures/sample_metadata.tsv",  "data/sample_metadata.tsv")
download.file("https://docs.qiime2.org/2020.2/data/tutorials/moving-pictures/core-metrics-results/unweighted_unifrac_pcoa_results.qza",  "data/unweighted_unifrac_pcoa_results.qz")
download.file("https://docs.qiime2.org/2020.2/data/tutorials/moving-pictures/core-metrics-results/shannon_vector.qza",  "data/shannon_vector.qza")

library(tidyverse)
library(qiime2R)

metadata<-read_q2metadata("data/sample_metadata.tsv")
uwunifrac<-read_qza("data/unweighted_unifrac_pcoa_results.qza")
shannon<-read_qza("data/shannon_vector.qza")$data %>% rownames_to_column("SampleID") 

uwunifrac$data$Vectors %>%
  select(SampleID, PC1, PC2) %>%
  left_join(metadata) %>%
  left_join(shannon) %>%
  ggplot(aes(x=PC1, y=PC2, color=`body-site`, shape=`reported-antibiotic-usage`, size=shannon)) +
  geom_point(alpha=0.5) + #alpha controls transparency and helps when points are overlapping
  theme_q2r() +
  scale_shape_manual(values=c(16,1), name="Antibiotic Usage") + #see http://www.sthda.com/sthda/RDoc/figure/graphs/r-plot-pch-symbols-points-in-r.png for numeric shape codes
  scale_size_continuous(name="Shannon Diversity") +
  scale_color_discrete(name="Body Site")

ggsave("PCoA.pdf", height=4, width=5, device="pdf") # save a PDF 3 inches by 4 inches

download.file("https://docs.qiime2.org/2020.2/data/tutorials/moving-pictures/table.qza", "data/feature_table.qza")

library(tidyverse)
library(qiime2R)

metadata<-read_q2metadata("data/sample_metadata.tsv")
SVs<-read_qza("data/feature_table.qza")$data
taxonomy<-read_qza("data/taxonomy.qza")$data %>% parse_taxonomy()

taxasums<-summarize_taxa(SVs, taxonomy)$Genus

taxa_heatmap(taxasums, metadata, "body-site")

ggsave("heatmap.pdf", height=4, width=8, device="pdf") # save a PDF 4 inches by 8 inches

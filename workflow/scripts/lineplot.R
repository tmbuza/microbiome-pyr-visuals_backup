source("workflow/scripts/common.R")
# source("workflow/scripts/qiime2R.R")

library(qiime2R)
library(tidyverse)
library(qiime2R)
library(yaml)

metadata <- read_q2metadata("data/sample_metadata.tsv") %>% 
  rename(sample_id = SampleID)
shannon <- read_qza("data/shannon_vector.qza")$data %>% 
  rownames_to_column("SampleID") %>% 
  rename(sample_id = SampleID)

# line plot
left_join(metadata, shannon, by = "sample_id") %>% 
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=DaysSinceExperimentStart, y=shannon, color=BodySite)) +
  stat_summary(geom="errorbar", fun.data=mean_se, width=0) +
  stat_summary(geom="line", fun.data=mean_se) +
  stat_summary(geom="point", fun.data=mean_se) +
  labs(x = "Days", y = "Shannon Diversity", color = "Body Site") +
  theme_bw()
  

# ggsave("figures/lineplot.pdf", height=5, width=6, device="pdf")
ggsave("figures/q2r_lineplot.png", height=5, width=6, device="png")
ggsave("figures/q2r_lineplot.svg", height=5, width=6, device="svg")

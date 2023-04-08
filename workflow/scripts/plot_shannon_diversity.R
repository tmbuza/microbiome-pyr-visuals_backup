source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

library(tidyverse)
library(yaml)

# metadata <- read_csv("data/metadata.csv", show_col_types = FALSE)
# shannon <- read_csv("data/shannon.csv", show_col_types = FALSE)

metadata <- read_q2metadata("resources/sample_metadata.tsv") %>% 
  rename(sample_id = SampleID)
shannon <- read_qza("resources/shannon_vector.qza")$data %>% 
  rownames_to_column("SampleID") %>% 
  rename(sample_id = SampleID)

# Plotting
left_join(metadata, shannon, by = "sample_id") %>% 
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=DaysSinceExperimentStart, y=shannon, color=BodySite)) +
  stat_summary(geom="errorbar", fun.data=mean_se, width=0) +
  stat_summary(geom="line", fun.data=mean_se) +
  stat_summary(geom="point", fun.data=mean_se) +
  labs(x = "Days", y = "Shannon Diversity", color = "Body Site") +
  theme_bw()
  

ggsave("figures/line_shannon_by_time.pdf", height=5, width=6, device="pdf")
ggsave("figures/line_shannon_by_time.png", height=5, width=6, device="png")
ggsave("figures/line_shannon_by_time.svg", height=5, width=6, device="svg")


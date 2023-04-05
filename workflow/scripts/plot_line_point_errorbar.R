
source("workflow/scripts/common.R")
library(tidyverse)
# library(qiime2R)
# 
# read_q2metadata("data/sample_metadata.tsv") %>% 
#   rename("sample_id"=1) %>% 
#   write_csv("data/metadata.csv")
# 
# read_qza("data/shannon_vector.qza")$data %>% 
#   tibble::rownames_to_column("sample_id") %>% 
#   write_csv("data/shannon.csv")

metadata <- read_csv("data/metadata.csv", show_col_types = FALSE)
shannon <- read_csv("data/shannon.csv", show_col_types = FALSE)

## Lines and point plots with error bars

left_join(metadata, shannon, by = "sample_id") %>%
  filter(!is.na(shannon)) %>% 
  ggplot(aes(x=DaysSinceExperimentStart, y=shannon, color=BodySite)) +
  stat_summary(geom="errorbar", fun.data=mean_se, width=0) +
  stat_summary(geom="line", fun.data=mean_se) +
  stat_summary(geom="point", fun.data=mean_se) +
  labs(x="Days", y="Shannon Diversity", color="Body Site") +
  theme_bw()

ggsave("figures/shannon_by_time.pdf", height=5, width=6, device="pdf")
ggsave("figures/shannon_by_time.png", height=5, width=6, device="png")
ggsave("figures/shannon_by_time.svg", height=5, width=6, device="svg")

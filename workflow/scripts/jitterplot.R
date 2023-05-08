source("workflow/scripts/common.R")
# source("workflow/scripts/qiime2R.R")

library(qiime2R)
library(tidyverse)
library(yaml)

metadata <- read_q2metadata("data/sample_metadata.tsv") %>% 
  rename(sample_id = SampleID)
shannon <- read_qza("data/shannon_vector.qza")$data %>% 
  rownames_to_column("SampleID") %>% 
  rename(sample_id = SampleID)

# Jitter plot
left_join(metadata, shannon, by = "sample_id") %>% 
  filter(!is.na(shannon)) %>%
  ggplot(aes(x=ReportedAntibioticUsage, y=shannon, fill=ReportedAntibioticUsage)) +
  stat_summary(geom="bar", fun.data=mean_se, color="black") +
  geom_jitter(shape=21, width=0.2, height=0) +
  coord_cartesian(ylim=c(2,7)) + 
  facet_grid(~BodySite) + 
  labs(x = "Antibiotic Usage", y = "Shannon Diversity", fill = "Body Site") +
  theme_q2r() +
  # scale_fill_manual(values=c("blue","red")) +
  theme(legend.position="right") #remove the legend as it isn't needed  

# ggsave("figures/jitterplot.pdf", height=5, width=6, device="pdf")
ggsave("figures/q2r_jitterplot.png", height=5, width=6, device="png")
ggsave("figures/q2r_jitterplot.svg", height=5, width=6, device="svg")


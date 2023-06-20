library(ggplot2)
library(dplyr)
library(plotly)
library(phyloseq)
library(ggtext)

load("data/otu_rel_abund.rda", verbose = TRUE)


taxon_rel_abund <- otu_rel_abund %>%
  filter(level=="genus",
         !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
  group_by(bmi, sample_id, taxon) %>%
  summarise(rel_abund = sum(rel_abund), .groups="drop") %>%
  group_by(bmi, taxon) %>%
  summarise(mean_rel_abund = 100*mean(rel_abund), .groups="drop") %>%
  mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
         taxon = str_replace(taxon, "^$", "*\\1*"),
         taxon = str_replace(taxon, "_", " "))

## Pool low abundance to "Others"

taxon_pool <- taxon_rel_abund %>%
  group_by(taxon) %>%
  summarise(pool = max(mean_rel_abund) < 2,
            mean = mean(mean_rel_abund), .groups="drop")

## Plotting
p <- inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
  mutate(taxon = if_else(pool, "Other", taxon)) %>%
  group_by(bmi, taxon) %>%
  summarise(mean_rel_abund = sum(mean_rel_abund),
            mean = min(mean), .groups="drop") %>%
  mutate(taxon = factor(taxon),
         taxon = fct_reorder(taxon, mean, .desc=TRUE),
         taxon = fct_shift(taxon, n=1)) %>%
  ggplot(aes(y=taxon, x = mean_rel_abund, fill= bmi)) +
  geom_col(width=0.8, position = position_dodge()) +
  labs(y = NULL, x = "Mean Relative Abundance", subtitle = "Taxa grouped by BMI category", fill = NULL) +
  theme_classic() +
  theme(axis.text.x = element_markdown(angle = 0, hjust = 1, vjust = 1),
        axis.text.y = element_markdown(),
        legend.text = element_markdown(),
        legend.key.size = unit(12, "pt"),
        panel.background = element_blank(),
        panel.grid.major.x =  element_line(colour = "lightgray", size = 0.1),
        panel.border = element_blank()) +
  guides(fill = guide_legend(ncol=1)) +
  scale_x_continuous(expand = c(0, 0))

ggplotly(p)
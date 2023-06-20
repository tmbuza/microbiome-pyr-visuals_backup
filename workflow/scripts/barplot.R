source("workflow/scripts/_common.R")
library(tidyverse)
library(magrittr)
library(dplyr)

seqcount_per_sample <- readRDS("data/ps_df.rds") %>%
  group_by(sample_id) %>% 
  summarise(nseqs = sum(count), .groups = "drop") %>% 
  arrange(-nseqs)

head_tail <- rbind(head(seqcount_per_sample, 5), tail(seqcount_per_sample, 5))

max_y <- max(head_tail$nseqs)

head_tail %>% 
  mutate(sample_id = factor(sample_id),
         sample_id = fct_reorder(sample_id, nseqs, .desc = F),
         sample_id = fct_shift(sample_id, n = 0)) %>%
ggplot(aes(x = reorder(sample_id, nseqs), y = nseqs)) +
  geom_col(position = position_stack(), fill = "steelblue") +
  labs(x = "sample ID", y = "Number of sequences", subtitle = "Phylum: Top and bottom sequence count \nwith no data labels") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
  ybreaks10

ggsave("figures/basic_barplot.png", width=5, height=4)
#---------------------------------------



# ## Taxa relative abundane bar plots
# library(tidyverse)
# library(readxl)
# library(ggtext)
# library(RColorBrewer)



# load("data/phyloseq_objects.rda")

# #####################
# otu_rel_abund <- ps_df %>% 
#   mutate(nationality = factor(nationality, 
#                       levels = c("AAM", "AFR"),
#                       labels = c("African American", "African")),
#          bmi = factor(bmi, 
#                       levels = c("lean", "overweight", "obese"),
#                       labels = c("Lean", "Overweight", "Obese")),
#          sex = factor(sex,
#                       levels =c("female", "male"),
#                       labels = c("Female", "Male")))

# resave(otu_rel_abund, file = "data/otu_rel_abund.rda")

# phylum_rel_abund <- otu_rel_abund %>%
#   filter(level=="phylum",
#          !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
#   group_by(bmi, sample_id, taxon) %>%
#   summarise(rel_abund = sum(rel_abund), .groups="drop") %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = 100*mean(rel_abund), .groups="drop") %>%
#   mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
#          taxon = str_replace(taxon, "^$", "*\\1*"),
#          taxon = str_replace(taxon, "_", " "))

# ## Pool low abundance to "Others"
# taxon_pool <- phylum_rel_abund %>%
#   group_by(taxon) %>%
#   summarise(pool = max(mean_rel_abund) < 1,
#             mean = mean(mean_rel_abund), .groups="drop")


# inner_join(phylum_rel_abund, taxon_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = sum(mean_rel_abund),
#             mean = min(mean), .groups="drop") %>%
#   mutate(taxon = factor(taxon),
#          taxon = fct_reorder(taxon, mean, .desc=TRUE),
#          taxon = fct_shift(taxon, n=1)) %>%
#   ggplot(aes(x=bmi, y=mean_rel_abund, fill=taxon)) +
#   geom_col(position = position_stack()) +
#   scale_fill_discrete(name=NULL) +
#   scale_x_discrete(breaks = c("lean", "overweight", "obese"), labels = c("Lean", "Overweight", "Obese")) +
#   scale_fill_manual(name=NULL,
#                     breaks=c("*Bacteroidetes*", "*Firmicutes*","*Proteobacteria*", "*Verrucomicrobia*", "Other"),
#                     labels = c("Bacteroidetes", "Firmicutes", "Proteobacteria", "Verrucomicrobia", "Other"),
#                     values = c(brewer.pal(4, "Dark2"), "gray")) +
#   labs(x = NULL, y = "Mean Relative Abundance", subtitle = "Phyla stacked bars filled by taxon") +
#   theme_classic() +
#   theme(axis.text.x = element_markdown(),
#         legend.text = element_markdown(),
#         legend.key.size = unit(10, "pt"))


# #####################

# taxon_rel_abund <- otu_rel_abund %>%
#   filter(level=="genus",
#          !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
#   group_by(bmi, sample_id, taxon) %>%
#   summarise(rel_abund = sum(rel_abund), .groups="drop") %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = 100*mean(rel_abund), .groups="drop") %>%
#   mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
#          taxon = str_replace(taxon, "^$", "*\\1*"),
#          taxon = str_replace(taxon, "_", " "))

# ## Pool low abundance to "Others"

# taxon_pool <- taxon_rel_abund %>%
#   group_by(taxon) %>%
#   summarise(pool = max(mean_rel_abund) < 2,
#             mean = mean(mean_rel_abund), .groups="drop")


# inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = sum(mean_rel_abund),
#             mean = min(mean), .groups="drop") %>%
#   mutate(taxon = factor(taxon),
#          taxon = fct_reorder(taxon, mean, .desc=TRUE),
#          taxon = fct_shift(taxon, n=1)) %>%
#   ggplot(aes(x=bmi, y=mean_rel_abund, fill=taxon)) +
#   geom_col(position = position_stack()) +
#   scale_fill_discrete(name=NULL) +
#   scale_x_discrete(breaks = c("lean", "overweight", "obese"), labels = c("Lean", "Overweight", "Obese")) +
#   labs(x = NULL, y = "Mean Relative Abundance", subtitle = "Taxa stacked bars filled by taxon") +
#   theme_classic() +
#   theme(axis.text.x = element_markdown(),
#         legend.text = element_markdown(),
#         legend.key.size = unit(10, "pt"))

# #####################

# phylum_rel_abund <- otu_rel_abund %>%
#   filter(level=="phylum",
#          !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
#   group_by(bmi, sample_id, taxon) %>%
#   summarise(rel_abund = sum(rel_abund), .groups="drop") %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = 100*mean(rel_abund), .groups="drop") %>%
#   mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
#          taxon = str_replace(taxon, "^$", "*\\1*"),
#          taxon = str_replace(taxon, "_", " "))

# ## Pool low abundance to "Others"
# taxon_pool <- phylum_rel_abund %>%
#   group_by(taxon) %>%
#   summarise(pool = max(mean_rel_abund) < 1,
#             mean = mean(mean_rel_abund), .groups="drop")


# inner_join(phylum_rel_abund, taxon_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = sum(mean_rel_abund),
#             mean = min(mean), .groups="drop") %>%
#   mutate(taxon = factor(taxon),
#          taxon = fct_reorder(taxon, mean, .desc=TRUE),
#          taxon = fct_shift(taxon, n=1)) %>%
#   ggplot(aes(y=taxon, x = mean_rel_abund, fill= bmi)) +
#   geom_col(width=0.8, position = position_dodge()) +
#   labs(y = NULL, x = "Mean Relative Abundance", subtitle = "Phyla grouped by BMI category", fill = NULL) +
#   theme_classic() +
#   theme(axis.text.x = element_markdown(angle = 0, hjust = 1, vjust = 1),
#         axis.text.y = element_markdown(),
#         legend.text = element_markdown(),
#         legend.key.size = unit(12, "pt"),
#         panel.background = element_blank(),
#         panel.grid.major.x =  element_line(colour = "lightgray", size = 0.1),
#         panel.border = element_blank()) +
#   guides(fill = guide_legend(ncol=1)) +
#   scale_x_continuous(expand = c(0, 0))


# #####################

# taxon_rel_abund <- otu_rel_abund %>%
#   filter(level=="genus",
#          !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
#   group_by(bmi, sample_id, taxon) %>%
#   summarise(rel_abund = sum(rel_abund), .groups="drop") %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = 100*mean(rel_abund), .groups="drop") %>%
#   mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
#          taxon = str_replace(taxon, "^$", "*\\1*"),
#          taxon = str_replace(taxon, "_", " "))

# ## Pool low abundance to "Others"

# taxon_pool <- taxon_rel_abund %>%
#   group_by(taxon) %>%
#   summarise(pool = max(mean_rel_abund) < 2,
#             mean = mean(mean_rel_abund), .groups="drop")

# ## Plotting
# inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   group_by(bmi, taxon) %>%
#   summarise(mean_rel_abund = sum(mean_rel_abund),
#             mean = min(mean), .groups="drop") %>%
#   mutate(taxon = factor(taxon),
#          taxon = fct_reorder(taxon, mean, .desc=TRUE),
#          taxon = fct_shift(taxon, n=1)) %>%
#   ggplot(aes(y=taxon, x = mean_rel_abund, fill= bmi)) +
#   geom_col(width=0.8, position = position_dodge()) +
#   labs(y = NULL, x = "Mean Relative Abundance", subtitle = "Taxa grouped by BMI category", fill = NULL) +
#   theme_classic() +
#   theme(axis.text.x = element_markdown(angle = 0, hjust = 1, vjust = 1),
#         axis.text.y = element_markdown(),
#         legend.text = element_markdown(),
#         legend.key.size = unit(12, "pt"),
#         panel.background = element_blank(),
#         panel.grid.major.x =  element_line(colour = "lightgray", size = 0.1),
#         panel.border = element_blank()) +
#   guides(fill = guide_legend(ncol=1)) +
#   scale_x_continuous(expand = c(0, 0))



# library(phyloseq)
# library(MicEco)
# library(ggtext)
# library(RColorBrewer)
# library(viridis)


# load("data/phyloseq_objects.rda")

# #-------------------------
# library(ggplot2)
# library(dplyr)
# #-------------------------
# phylum <- ps_df %>% 
#   filter(level == "phylum") 

# phylum_pool <- phylum %>%
#   group_by(taxon) %>%
#   summarise(pool = max(rel_abund) < 0.02,
#             mean = mean(rel_abund), .groups="drop")  
  
# inner_join(phylum, phylum_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   ggplot(aes(x = sample_id, y = 100*rel_abund, fill = taxon)) +
#   theme_bw() + 
#   geom_bar(stat = "identity", position = position_stack()) +
#   labs(x="Sample", y="Relative Abundance", subtitle = "Taxa Relative Abundance by MicEco package", fill = NULL) +
#   facet_grid(~ nationality, space = "free", scales = "free") +
#   theme(axis.text.x = element_blank(),
#         legend.text = element_markdown(),
#         strip.background = element_rect(colour = "lightblue", fill = "lightblue")) +
#   scale_fill_manual(name=NULL,
#                     breaks=c("*Actinobacteria*","*Bacteroidetes*", "*Firmicutes*","*Proteobacteria*", "*Verrucomicrobia*", "Other"),
#                     labels=c("*Actinobacteria*","*Bacteroidetes*", "*Firmicutes*","*Proteobacteria*", "*Verrucomicrobia*", "Other"),
#                     values = c(brewer.pal(5, "Paired"), "gray"))

  
# family <- ps_df %>% 
#   filter(level == "family") 

# family_pool <- family %>%
#   group_by(taxon) %>%
#   summarise(pool = max(rel_abund) < 0.1,
#             mean = mean(rel_abund), .groups="drop")  
  
# inner_join(family, family_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   ggplot(aes(x = sample_id, y = 100*rel_abund, fill = taxon)) +
#   theme_bw() + 
#   geom_bar(stat = "identity", position = position_stack()) +
#   labs(x="Sample", y="Relative Abundance", subtitle = "Taxa Relative Abundance by MicEco package", fill = NULL) +
#   facet_grid(~ nationality, space = "free", scales = "free") +
#   theme(axis.text.x = element_blank(),
#         legend.text = element_markdown(),
#         strip.background = element_rect(colour = "lightblue", fill = "lightblue"))

  
# genus <- ps_df %>% 
#   filter(level == "genus") 

# genus_pool <- genus %>%
#   group_by(taxon) %>%
#   summarise(pool = max(rel_abund) < 0.15,
#             mean = mean(rel_abund), .groups="drop")  
  
# inner_join(genus, genus_pool, by="taxon") %>%
#   mutate(taxon = if_else(pool, "Other", taxon)) %>%
#   ggplot(aes(x = sample_id, y = 100*rel_abund, fill = taxon)) +
#   theme_bw() + 
#   geom_bar(stat = "identity", position = position_stack()) +
#   labs(x="Sample", y="Relative Abundance", subtitle = "Taxa Relative Abundance by MicEco package", fill = NULL) +
#   facet_grid(~ nationality, space = "free", scales = "free") +
#   theme(axis.text.x = element_blank(),
#         legend.text = element_markdown(),
#         strip.background = element_rect(colour = "lightblue", fill = "lightblue"))

# #-------------------------
# library(microbial)
# #-------------------------

# plotbar(ps_rel, level="Phylum", group = "nationality", top = 10) +
#   theme(axis.text.x = element_text(angle = 0)) + 
#   labs(x="Sample", 
#        y="Relative Abundance", 
#        subtitle = "Phyla Relative Abundance by microbial package", 
#        fill = NULL)
  
# plotbar(ps_rel, level="Genus", group = "nationality", top = 10) +
#   theme(axis.text.x = element_text(angle = 0)) + 
#   labs(x="Sample", 
#        y="Relative Abundance", 
#        subtitle = "Taxa Relative Abundance by microbial package", 
#        fill = NULL)

# #-------------------------
# library(ggpubr)
# #-------------------------
# # Load data
# data("mtcars")
# dfm <- mtcars
# # Convert the cyl variable to a factor
# dfm$cyl <- as.factor(dfm$cyl)
# # Add the name colums
# dfm$name <- rownames(dfm)
# # Inspect the data
# head(dfm[, c("name", "wt", "mpg", "cyl")])

# # Ordered bar plots
# ggbarplot(dfm, x = "name", y = "mpg",
#           fill = "cyl",               # change fill color by cyl
#           color = "white",            # Set bar border colors to white
#           palette = "jco",            # jco journal color palett. see ?ggpar
#           sort.val = "desc",          # Sort the value in dscending order
#           sort.by.groups = FALSE,     # Don't sort inside each group
#           x.text.angle = 90           # Rotate vertically x axis texts
#           )

# # sorted by group
# ggbarplot(dfm, x = "name", y = "mpg",
#           fill = "cyl",               # change fill color by cyl
#           color = "white",            # Set bar border colors to white
#           palette = "jco",            # jco journal color palett. see ?ggpar
#           sort.val = "asc",           # Sort the value in dscending order
#           sort.by.groups = TRUE,      # Sort inside each group
#           x.text.angle = 90           # Rotate vertically x axis texts
#           )

# # Deviation graphs
# # Calculate the z-score of the mpg data
# dfm$mpg_z <- (dfm$mpg -mean(dfm$mpg))/sd(dfm$mpg)
# dfm$mpg_grp <- factor(ifelse(dfm$mpg_z < 0, "low", "high"), 
#                      levels = c("low", "high"))
# # Inspect the data
# head(dfm[, c("name", "wt", "mpg", "mpg_z", "mpg_grp", "cyl")])

# ggbarplot(dfm, x = "name", y = "mpg_z",
#           fill = "mpg_grp",           # change fill color by mpg_level
#           color = "white",            # Set bar border colors to white
#           palette = "jco",            # jco journal color palett. see ?ggpar
#           sort.val = "asc",           # Sort the value in ascending order
#           sort.by.groups = FALSE,     # Don't sort inside each group
#           x.text.angle = 90,          # Rotate vertically x axis texts
#           ylab = "MPG z-score",
#           xlab = FALSE,
#           legend.title = "MPG Group"
#           )

# # Rotate
# ggbarplot(dfm, x = "name", y = "mpg_z",
#           fill = "mpg_grp",           # change fill color by mpg_level
#           color = "white",            # Set bar border colors to white
#           palette = "jco",            # jco journal color palett. see ?ggpar
#           sort.val = "desc",          # Sort the value in descending order
#           sort.by.groups = FALSE,     # Don't sort inside each group
#           x.text.angle = 90,          # Rotate vertically x axis texts
#           ylab = "MPG z-score",
#           legend.title = "MPG Group",
#           rotate = TRUE,
#           ggtheme = theme_minimal()
#           )
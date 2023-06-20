set.seed(2023)
library(ggpubr)

load("data/phyloseq_objects.rda")

otu_rel_abund <- ps_df %>% 
  mutate(nationality = factor(nationality, 
                      levels = c("AAM", "AFR"),
                      labels = c("African American", "African")),
         bmi = factor(bmi, 
                      levels = c("lean", "overweight", "obese"),
                      labels = c("Lean", "Overweight", "Obese")),
         sex = factor(sex,
                      levels =c("female", "male"),
                      labels = c("Female", "Male")))
taxon_rel_abund <- otu_rel_abund %>%
  filter(level=="genus",
         !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
  group_by(nationality, sex, bmi, sample_id, taxon) %>%
  summarise(rel_abund = 100*sum(rel_abund), .groups="drop") %>%
  mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
         taxon = str_replace(taxon, "^$", "*\\1*"),
         taxon = str_replace(taxon, "_", " "))


taxon_pool <- taxon_rel_abund %>%
  group_by(nationality, taxon) %>%
  summarise(median=median(rel_abund), .groups="drop") %>%
  group_by(taxon) %>%
  summarise(pool = max(median) < 3,
            median = median(median),
            .groups="drop")

inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
  mutate(taxon = if_else(pool, "Other", taxon)) %>%
  group_by(sample_id, nationality, taxon) %>%
  summarise(rel_abund = sum(rel_abund),
            median = min(median),
            .groups="drop") %>%
  mutate(taxon = factor(taxon),
         taxon = fct_reorder(taxon, median, .desc=FALSE)) %>%
  ggviolin(
    x = "nationality",
    y = "rel_abund",
    color = "nationality", palette =c("green", "blue", "red"),
    add = "jitter") +
  theme_bw() +
  labs(subtitle = "Relative abundance by nationality")



taxon_pool <- taxon_rel_abund %>%
  group_by(sex, taxon) %>%
  summarise(median=median(rel_abund), .groups="drop") %>%
  group_by(taxon) %>%
  summarise(pool = max(median) < 3,
            median = median(median),
            .groups="drop")

inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
  mutate(taxon = if_else(pool, "Other", taxon)) %>%
  group_by(sample_id, sex, taxon) %>%
  summarise(rel_abund = sum(rel_abund),
            median = min(median),
            .groups="drop") %>%
  mutate(taxon = factor(taxon),
         taxon = fct_reorder(taxon, median, .desc=FALSE)) %>%
  ggviolin(
    x = "sex",
    y = "rel_abund",
    color = "sex", palette =c("green", "blue", "red"),
    add = "jitter") +
  theme_bw() +
  labs(subtitle = "Relative abundance by sex")



taxon_pool <- taxon_rel_abund %>%
  group_by(bmi, taxon) %>%
  summarise(median=median(rel_abund), .groups="drop") %>%
  group_by(taxon) %>%
  summarise(pool = max(median) < 3,
            median = median(median),
            .groups="drop")

inner_join(taxon_rel_abund, taxon_pool, by="taxon") %>%
  mutate(taxon = if_else(pool, "Other", taxon)) %>%
  group_by(sample_id, bmi, taxon) %>%
  summarise(rel_abund = sum(rel_abund),
            median = min(median),
            .groups="drop") %>%
  mutate(taxon = factor(taxon),
         taxon = fct_reorder(taxon, median, .desc=FALSE)) %>%
  ggviolin(
    x = "bmi",
    y = "rel_abund",
    color = "bmi", palette =c("green", "blue", "red"),
    add = "jitter",
    alpha = 0.5) +
  theme_bw() +
  labs(subtitle = "Relative abundance by sex")

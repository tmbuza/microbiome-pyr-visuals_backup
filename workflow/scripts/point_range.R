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
  group_by(nationality, sample_id, taxon) %>%
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
  ggplot(aes(y=taxon, x=rel_abund, color=nationality)) +
  stat_summary(fun.data=median_hilow, geom = "pointrange",
               fun.args=list(conf.int=0.5),
               position = position_dodge(width=0.6)) +
  labs(y=NULL, x="Relative Abundance", color = NULL, title = "Point range plot ny nationality") +
  theme_classic() +
  theme(axis.text.y = element_markdown(),
        legend.text = element_markdown(),
        legend.position = c(0.8, 0.6),
        legend.background = element_rect(color="black", fill = NA),
        legend.margin = margin(t=-5, r=3, b=3)
        )
otu_rel_abund <- ps_df %>% 
  mutate(bmi = factor(bmi, 
                      levels=c("AAM", "AFR"),
                      labels = c("African American", "African")))

taxon_rel_abund <- otu_rel_abund %>%
  filter(level=="genus",
         !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
  group_by(bmi, sample_id, taxon) %>%
  summarise(rel_abund = 100*sum(rel_abund), .groups="drop") %>%
  mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
         taxon = str_replace(taxon, "^$", "*\\1*"),
         taxon = str_replace(taxon, "_", " "))


# Sex
otu_rel_abund <- ps_df %>% 
  mutate(sex = factor(sex, 
                      levels=c("female", "male"),
                      labels = c("Female", "Male")))

taxon_rel_abund <- otu_rel_abund %>%
  filter(level=="genus",
         !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
  group_by(sex, sample_id, taxon) %>%
  summarise(rel_abund = 100*sum(rel_abund), .groups="drop") %>%
  mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
         taxon = str_replace(taxon, "^$", "*\\1*"),
         taxon = str_replace(taxon, "_", " "))


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
  ggplot(aes(y=taxon, x=rel_abund, color=sex)) +
  stat_summary(fun.data=median_hilow, geom = "pointrange",
               fun.args=list(conf.int=0.5),
               position = position_dodge(width=0.6)) +
  labs(y=NULL, x="Relative Abundance", color = NULL, title = "Point range plot by sex") +
  theme_classic() +
  theme(axis.text.y = element_markdown(),
        legend.text = element_markdown(),
        legend.position = c(0.8, 0.6),
        legend.background = element_rect(color="black", fill = NA),
        legend.margin = margin(t=-5, r=3, b=3)
        )


# BMI group
otu_rel_abund <- ps_df %>% 
  mutate(bmi = factor(bmi, 
                      levels=c("obese", "lean", "overweight"),
                      labels = c("Obese", "Lean", "Overweight")))

taxon_rel_abund <- otu_rel_abund %>%
  filter(level=="genus",
         !grepl(".*unassigned.*|.*nclassified.*|.*ncultured.*",taxon)) %>%
  group_by(bmi, sample_id, taxon) %>%
  summarise(rel_abund = 100*sum(rel_abund), .groups="drop") %>%
  mutate(taxon = str_replace(taxon, "(.*)_unclassified", "Unclassified<br>*\\1*"),
         taxon = str_replace(taxon, "^$", "*\\1*"),
         taxon = str_replace(taxon, "_", " "))


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
  ggplot(aes(y=taxon, x=rel_abund, color=bmi)) +
  stat_summary(fun.data=median_hilow, geom = "pointrange",
               fun.args=list(conf.int=0.5),
               position = position_dodge(width=0.6)) +
  labs(y=NULL, x="Relative Abundance", color = NULL, title = "Point range plot by BMI category") +
  theme_classic() +
  theme(axis.text.y = element_markdown(),
        legend.text = element_markdown(),
        legend.position = c(0.8, 0.6),
        legend.background = element_rect(color="black", fill = NA),
        legend.margin = margin(t=-5, r=3, b=3)
        )

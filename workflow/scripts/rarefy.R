rarefy <- function(x, sample){

  x <- x[x>0]
  sum(1-exp(lchoose(sum(x) - x, sample) - lchoose(sum(x), sample)))
  
}

collect <- function(data, group){
  
  data %>%
    filter(Group == group) %>%
    uncount(value) %>%
    sample_n(n()) %>%
    mutate(observation = row_number()) %>%
    arrange(name, observation) %>%
    group_by(name) %>%
    mutate(distinct = row_number() == 1) %>%
    ungroup() %>%
    arrange(observation) %>%
    mutate(s = cumsum(distinct)) %>%
    select(observation, s)
}

collect_curves <- map_dfr(1:1000, ~collect(shared, "F3D0"), .id="iteration")

rarefaction_curve <- collect_curves %>%
  group_by(observation) %>%
  summarize(r = mean(s))

math <- shared %>%
  filter(Group == "F3D0") %>%
  summarize(m = rarefy(value, 1828))

collect_curves %>%
  ggplot(aes(x=observation, y=s, group=iteration)) +
  geom_line(color="gray", alpha=0.2) +
  geom_line(data=rarefaction_curve,
            aes(x=observation, y=r), inherit.aes=FALSE,
            color="black", size=1) +
  geom_point(data=math, aes(x=1828, y=m),
             inherit.aes = FALSE,
             color="red", size=2) +
  theme_classic()

rarefaction_curve %>%
  filter(observation == 1828) %>%
  pull(r)


subsample <- function(data, sample_size){
  
  data %>%
    group_by(Group) %>%
    uncount(value) %>%
    sample_n(sample_size) %>%
    summarize(s = n_distinct(name))

}
library(tidyverse)
library(rstract)


dem_it_p <- dem_it_p %>%
  filter(region != "Trentino Alto Adige / Südtirol") %>%
  group_by(region) %>%
  mutate(tot = sum(value)) %>% # this makes total for regions
  ungroup() %>%
  mutate(perc_pop = value / tot * 100)


dem_65bin <- dem_it_p %>%
  mutate(age_bins = cut(age, breaks = c(0, 65, 100), include.lowest = TRUE, labels = c("less65", "65andMore"))) %>%
  group_by(region, age_bins, sex) %>%
  summarize(value = sum(value), perc_pop = sum(perc_pop)) %>%
  filter(age_bins == "65andMore") %>%
  ungroup()

dem_65bin_fm <-
  dem_65bin %>%
  group_by(region, sex) %>%
  summarize(over_65 = sum(perc_pop), pop_tot = sum(value)) %>%
  pivot_wider(id_cols = region, names_from = sex, values_from = over_65) %>%
  rename(female_65m = female, male_65m = male)

x <- dem_it_wider %>%
  select(region, pop_tot)

dem_65bin_fm <- inner_join(x, dem_65bin_fm, by = "region")

usethis::use_data(
  bweight_it,
  cancer_it,
  chronic_it,
  dem_65bin_fm,
  dem_it_wider,
  fl_it_2019,
  regions_area,
  smoking_it,
  dem_65bin_fm, internal = TRUE, overwrite = TRUE)

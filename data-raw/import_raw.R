library(vroom)
library(tidyverse)
library(janitor)
library(reshape2)
library(tabulizer)
library(stringr)


# Unpackit_us.zip and run the script

# xxxxxxxxxxxxxxxx-------------------
# United States #-----
# xxxxxxxxxxxxxxxx-------------------
# us_age_sex AKA us_dem  ---------

us_age_sex_all <- vroom("data-raw/it_us/us/american_comunity_survey_2018/age_sex/ACSST5Y2018.S0101_data_with_overlays_2020-04-14T063202.csv",
  skip = 1,
  col_select = c(`id`, `Geographic Area Name`, starts_with("Estimate"))
) %>%
  clean_names()


to_select_age_sex <- readxl::read_xlsx("data-raw/it_us/us/american_comunity_survey_2018/age_sex/to_select_age_sex.xlsx")

us_age_sex <- us_age_sex_all %>%
  select(!!to_select_age_sex$old_names)


names(us_age_sex) <- to_select_age_sex$new_names

us_age_sex <- us_age_sex %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  mutate(fips = as.numeric(fips))


# us_fl65 ----------
us_fl65_all <- vroom("data-raw/it_us/us/data_cms/flu_us.csv",
  col_types = cols(
    year = col_double(),
    geography = col_character(),
    measure = col_character(),
    adjustment = col_character(),
    analysis = col_character(),
    domain = col_character(),
    condition = col_character(),
    primary_sex = col_character(),
    primary_age = col_character(),
    primary_dual = col_character(),
    fips = col_double(),
    county = col_character(),
    state = col_character(),
    urban = col_character(),
    primary_race = col_character(),
    primary_denominator = col_character(),
    analysis_value = col_double()
  )
)

us_fl65 <- us_fl65_all %>%
  rename("perc_imm65" = "analysis_value") %>%
  dplyr::select(state, county, fips, perc_imm65)


# us_hospbeds  ----------
us_hospbeds_all <- vroom("data-raw/it_us/us/hospital_beds.csv",
  col_types = cols(
    X = col_double(),
    Y = col_double(),
    OBJECTID = col_double(),
    ID = col_character(),
    NAME = col_character(),
    ADDRESS = col_character(),
    CITY = col_character(),
    STATE = col_character(),
    ZIP = col_character(),
    ZIP4 = col_character(),
    TELEPHONE = col_character(),
    TYPE = col_character(),
    STATUS = col_character(),
    POPULATION = col_double(),
    COUNTY = col_character(),
    COUNTYFIPS = col_character(),
    COUNTRY = col_character(),
    LATITUDE = col_double(),
    LONGITUDE = col_double(),
    NAICS_CODE = col_double(),
    NAICS_DESC = col_character(),
    SOURCE = col_character(),
    SOURCEDATE = col_datetime(format = ""),
    VAL_METHOD = col_character(),
    VAL_DATE = col_datetime(format = ""),
    WEBSITE = col_character(),
    STATE_ID = col_character(),
    ALT_NAME = col_character(),
    ST_FIPS = col_character(),
    OWNER = col_character(),
    TTL_STAFF = col_double(),
    BEDS = col_double(),
    TRAUMA = col_character(),
    HELIPAD = col_character()
  )
) %>%
  select(STATE, CITY, COUNTYFIPS, BEDS) %>%
  clean_names() %>%
  filter(beds != -999) # "KY, 47125" # "OH, 36091"


# https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/data?page=18

# this is by city we need to go by county
us_hospbeds <- us_hospbeds_all %>%
  rename(fips = countyfips) %>%
  group_by(state, fips) %>%
  summarize(tot_beds = sum(beds, na.rm = TRUE)) %>%
  mutate(fips = as.numeric(fips)) %>%
  filter(!is.na(fips))

# us_mmd: Mapping Medicare Disparities -   ----------
to_imp <- list.files("data-raw/it_us/us/data_cms/", full.names = TRUE)
mmd_all_us <- vroom(to_imp,
  col_types = cols(
    year = col_double(),
    geography = "-",
    measure = "-",
    adjustment = "-",
    analysis = "-",
    domain = "-",
    condition = col_character(),
    primary_sex = "-",
    primary_age = "-",
    primary_dual = "-",
    fips = col_double(),
    county = col_character(),
    state = col_character(),
    urban = col_character(),
    primary_race = "-",
    primary_denominator = "-", # this could be important put it in  the documentation
    analysis_value = col_double()
  )
)

us_mmd <- mmd_all_us %>%
  mutate(
    condition =
      recode(condition,
        "Alzheimer's Disease, Related Disorders, or Senile Dementia" = "alzheimer_dementia",
        "Rheumatoid Arthritis/Osteoarthritis" = "rheumatoid_arthritis",
        "Cancer, Colorectal, Breast, Prostate, Lung" = "cancer_all",
        "Chronic obstructive pulmonary disease" = "ch_obstructive_pulm",
        "Stroke/Transient Ischemic Attack" = "stroke",
        "Schizophrenia and other psychotic disorders" = "schizophrenia_psychotic_dis",
        "1 of the claims-based conditions" = "at_least_1_chronic"
      )
  ) %>%
  # pivot_longer and spread crash as a bitch
  reshape2::dcast(... ~ condition, value.var = "analysis_value") %>%
  clean_names() %>%
  # just reordering (lin the future reorder)
  select(
    year,
    fips,
    county,
    state,
    urban,
    at_least_1_chronic,
    acute_myocardial_infarction,
    alzheimer_dementia,
    asthma,
    atrial_fibrillation,
    cancer_breast,
    cancer_colorectal,
    cancer_lung,
    cancer_all,
    ch_obstructive_pulm,
    chronic_kidney_disease,
    depression,
    diabetes,
    heart_failure,
    hypertension,
    ischemic_heart_disease,
    obesity,
    osteoporosis,
    rheumatoid_arthritis,
    schizophrenia_psychotic_dis,
    stroke,
    tobacco_use,
    urgent_admission,
    annual_wellness_visit,
    elective_admission,
    emergent_admission,
    other_admission,
    pneumococcal_vaccine
  )
  names(us_mmd) <-
  c(
    "year",
    "fips",
    "county",
    "state",
    "urban",
    "perc_at_least_1_chronic",
    "perc_acute_myocardial_infarction",
    "perc_alzheimer_dementia",
    "perc_asthma",
    "perc_atrial_fibrillation",
    "perc_cancer_breast",
    "perc_cancer_colorectal",
    "perc_cancer_lung",
    "perc_cancer_all",
    "perc_ch_obstructive_pulm",
    "perc_chronic_kidney_disease",
    "perc_depression",
    "perc_diabetes",
    "perc_heart_failure",
    "perc_hypertension",
    "perc_ischemic_heart_disease",
    "perc_obesity",
    "perc_osteoporosis",
    "perc_rheumatoid_arthritis",
    "perc_schizophrenia_psychotic_dis",
    "perc_stroke",
    "perc_tobacco_use",
    "urgent_admission",
    "annual_wellness_visit",
    "elective_admission",
    "emergent_admission",
    "other_admission",
    "perc_pneumococcal_vaccine"
  )



# AMERICAN COMUNITY SURVEY
# codes: https://www.census.gov/programs-surveys/acs/technical-documentation/code-lists.html
# us_acm_househ ----------
acm_househ_all_us <- vroom("data-raw/it_us/us/american_comunity_survey_2018/households/ACSDP5Y2018.DP02_data_with_overlays_2020-04-15T004120.csv",
  col_types = cols(.default = "c"), skip = 1
) %>%
  clean_names() %>%
  select(id, geographic_area_name, starts_with("percent_estimate"))


to_select <- readxl::read_xlsx("data-raw/it_us/us/american_comunity_survey_2018/households/to_select.xlsx")

us_acm_househ <- acm_househ_all_us %>%
  select(!!to_select$old_names)

names(us_acm_househ) <- to_select$new_names

# the id is 0500000US16001 with last 5 numbers identifing the fips
us_acm_househ <- us_acm_househ %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  mutate_at(vars(-state_county), as.numeric) %>%
  filter(fips < 72000) # no values for PuertoRico

# us_poverty -------------------
to_select_pov <- readxl::read_xlsx("data-raw/it_us/us/american_comunity_survey_2018/poverty/to_select_pov.xlsx")

poverty_all_us <- vroom("data-raw/it_us/us/american_comunity_survey_2018/poverty/ACSST5Y2018.S1701_data_with_overlays_2020-04-16T182603.csv",
  skip = 1
) %>%
  clean_names() %>%
  select(!!to_select_pov$old_names)


names(poverty_all_us) <- to_select_pov$new_names

us_poverty <- poverty_all_us %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  separate(geographic_area_name, c("county", "state"), sep = ",") %>%
  mutate_at(vars(-county, -state), as.numeric)

# state abbreviations

state_abbr <- readxl::read_xlsx("data-raw/it_us/us/state_abbr.xlsx")

# us_race ------------
to_select_race <- readxl::read_xlsx("data-raw/it_us/us/american_comunity_survey_2018/race/to_select_race.xlsx")

race_all_us <- vroom("data-raw/it_us/us/american_comunity_survey_2018/race/ACSDP5Y2018.DP05_data_with_overlays_2020-05-17T212836.csv",
  col_types = cols(.default = "c"), skip = 1
) %>%
  clean_names() %>%
  select(id, geographic_area_name, starts_with("estimate")) %>%
  select(!!to_select_race$old_names)

names(race_all_us) <- to_select_race$new_names

us_race <- race_all_us %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  separate(state_county, c("county", "state"), sep = ",") %>%
  mutate_at(vars(-county, -state), as.numeric)

# us_pm2.5 ---------------------
# Thank you  Ista Zahn and Ben Sabath for hints on the sources
# https://github.com/wxwx1993/PM_COVID/blob/master/additional_preprocessing_code/download_pm25_values.md
# The Atmospheric Composition Analysis Group at Dalhouse University
us_pm2.5 <- vroom("https://raw.githubusercontent.com/wxwx1993/PM_COVID/master/Data/county_pm25.csv",
  col_types = cols(
    fips = col_double(),
    year = col_double(),
    pm25 = col_double()
  )
)

# us_season ---------------------
# Thank you  Ista Zahn and Ben Sabath for hints on the sources
# https://github.com/wxwx1993/PM_COVID/blob/master/additional_preprocessing_code/download_pm25_values.md
# The Atmospheric Composition Analysis Group at Dalhouse University

us_season <- vroom("https://raw.githubusercontent.com/wxwx1993/PM_COVID/master/Data/temp_seasonal_county.csv",
  col_types = cols(.default = "d")
)

names(us_season) <- c("fips", "year", "summer_temp", "summer_hum", "winter_temp", "winter_hum")

# us_netinc -----
# from census
netincome_all_us <- vroom("data-raw/it_us/us/american_comunity_survey_2018/netincome/ACSST5Y2018.S1901_data_with_overlays_2020-04-29T001634.csv",
  col_types = cols(.default = "c"), skip = 1
) %>%
  clean_names() %>%
  select(id, geographic_area_name, estimate_households_median_income_dollars)

names(netincome_all_us)

us_netinc <- netincome_all_us %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  separate(geographic_area_name, c("county", "state"), sep = ",") %>%
  rename(median_income = estimate_households_median_income_dollars) %>%
  mutate_at(vars(-county, -state), as.numeric)

# xxxxxxxxxxxxxxxx-------------------
# Italy ------------------------
# xxxxxxxxxxxxxxxx-------------------
# it_bweight -----
it_bweight <- vroom("data-raw/it_us/it/bweight_it.csv", col_types = cols(
  ITTER107 = col_character(),
  Territorio = col_character(),
  TIPO_DATO_AVQ = col_character(),
  `Tipo dato` = col_character(),
  MISURA_AVQ = col_character(),
  Misura = col_character(),
  SEXISTAT1 = col_double(),
  Sesso = col_character(),
  TIME = col_double(),
  `Seleziona periodo` = col_double(),
  Value = col_double(),
  `Flag Codes` = col_logical(),
  Flags = col_logical()
)) %>%
  filter(TIME == 2018) %>%
  rename(
    region = Territorio,
    bweight_status = TIPO_DATO_AVQ,
    value = Value,
    ses = Sesso
  ) %>%
  filter(Misura == "valori in migliaia") %>%
  select(region, bweight_status, value) %>%
  mutate(region = str_replace(region, "-", " ")) %>%
  filter(!region %in% c("Trentino Alto Adige / Südtirol", "Italia")) %>%
  # make name consistent
  mutate(region = recode(region,
    "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
    "Provincia Autonoma Bolzano / Bozen" =  "P.A. Bolzano",
    "Provincia Autonoma Trento"   =  "P.A. Trento",
    "Fiuli Venezia Giulia"  = "Friuli Venezia Giulia"
  )) %>%
  mutate(bweight_status = recode(bweight_status,
    "18_BMI_SOTTO" = "bweight_under",
    "18_BMI_NORMO" = "bweight_normal",
    "18_BMI_SOVRA" = "bweight_over",
    "18_BMI_OBE" = "bweight_obese"
  )) %>%
  filter(bweight_status %in% c("bweight_under", "bweight_normal", "bweight_over", "bweight_obese")) %>%
  # values are in thousands
  mutate(value = value * 1000) %>%
  pivot_wider(names_from = bweight_status, values_from = value)

# it_cancer -----
web_page <- "http://www.registri-tumori.it/PDF/AIOM2016/I_numeri_del_cancro_2016.pdf"

area_sel <- c(
  top = 240.95886, left = 27.75322, bottom = 534.19809,
  right = 436.61248
) # got this using locate_areas()

suppressWarnings(
  cancer_tab <- extract_tables(
    web_page,
    output = "data.frame",
    pages = 35,
    area =  list(area_sel),
    guess = FALSE
  )[[1]]
  %>%
    na.omit()
)

names(cancer_tab) <-
  c(
    "region",
    paste("cancer",
      c(
        "all",
        "breast",
        "colon",
        "prostate",
        "bladder",
        "lymphoma",
        "head_neck",
        "uterus",
        "lung"
      ),
      sep = "_"
    )
  )

# clean names
it_cancer <- cancer_tab %>%
  mutate(region = recode(region,
    "Trentino Alto" = "Trentino Alto Adige",
    "Emilia" = "Emilia Romagna",
    "Friuli Venezia" = "Friuli Venezia Giulia",
    "Valle D’Aosta" = "Valle d'Aosta"
  )) %>%
  filter(region != "Trentino Alto Adige") %>%
  # in italy . used as , in numbers
  mutate_if(is.double, ~ as.numeric(str_remove(as.character(.), "[[:punct:]]")))

# no data on those  but we want to include them anyway for the join
it_cancer[20, "region"] <- "P.A. Bolzano"
it_cancer[21, "region"] <- "P.A. Trento"


# it_chronic -----
it_chronic_p <- vroom("data-raw/it_us/it/chronic_conditions.csv",
  col_types = cols(
    ITTER107 = col_character(),
    Territorio = col_character(),
    TIPO_DATO_AVQ = col_character(),
    `Tipo dato` = col_character(),
    MISURA_AVQ = col_character(),
    Misura = col_character(),
    TIME = col_double(),
    `Seleziona periodo` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_logical(),
    Flags = col_logical()
  )
) %>%
  clean_names() %>%
  filter(misura == "valori in migliaia") %>% # we keep the absolute values
  mutate(value = value * 1000) # values are in thousands


# we do some cleaning and translations
it_chronic <- it_chronic_p %>%
  rename(region = territorio, ch_condition = tipo_dato_avq) %>%
  mutate(region = str_replace(region, "-", " ")) %>%
  filter(!region %in% c("Trentino Alto Adige / Südtirol", "Italia")) %>%
  # make name consistent
  mutate(region = recode(region,
    "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
    "Provincia Autonoma Bolzano / Bozen" =  "P.A. Bolzano",
    "Provincia Autonoma Trento"   =  "P.A. Trento",
    "Fiuli Venezia Giulia"  = "Friuli Venezia Giulia"
  )) %>%
  select(region, ch_condition, value) %>%
  mutate(ch_condition = tolower(str_remove(ch_condition, "0_"))) %>%
  # we make it wilder
  pivot_wider(names_from = ch_condition, values_from = value) %>%
  rename(chronic_aleast_2cron = aleast_2cron, chronic_aleast_1cron = aleast_1cron, chronic_good_h = good_h)

# it_dem_p -----
it_dem_p <- vroom(
  "data-raw/it_us/it/pop_it.csv",
  col_types = cols(
    ITTER107 = col_character(),
    Territorio = col_character(),
    TIPO_DATO15 = col_character(),
    `Tipo di indicatore demografico` = col_character(),
    SEXISTAT1 = col_double(),
    Sesso = col_character(),
    ETA1 = col_character(),
    Età = col_character(),
    STATCIV2 = col_double(),
    `Stato civile` = col_character(),
    TIME = col_double(),
    `Seleziona periodo` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_character(),
    Flags = col_character()
  )
) %>%
  rename(
    region = Territorio,
    index = `Tipo di indicatore demografico`,
    sex = Sesso,
    age = `Età`,
    marital_status = `Stato civile`,
    year = `Seleziona periodo`,
    value = Value
  ) %>%
  select(region, index, sex, age, marital_status, year, value) %>%
  filter(age != "totale", sex != "totale", marital_status == "totale") %>%
  mutate(
    age = as.numeric(str_remove_all(age, "[[:alpha:]]")),
    sex = recode(sex, femmine = "female", maschi = "male")
  )

it_dem_p$region <- recode(
  it_dem_p$region,
  "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
  "Provincia Autonoma Bolzano / Bozen" = "P.A. Bolzano",
  "Provincia Autonoma Trento"  = "P.A. Trento",
  "Friuli-Venezia Giulia"  = "Friuli Venezia Giulia",
  "Emilia-Romagna" = "Emilia Romagna"
)

# it_dem: age continuus
it_dem <- it_dem_p %>%
  filter(region != "Trentino Alto Adige / Südtirol") %>%
  group_by(region) %>%
  mutate(tot = sum(value)) %>% # this makes total for regions
  ungroup() %>%
  mutate(perc_pop = value / tot * 100)

it_dem_bins <- it_dem %>%
  mutate(age_bins = cut(age, seq(0, 100, 10), right = FALSE, include.lowest = TRUE)) %>%
  mutate(age_bins = recode(age_bins, "[90,100]" = "[90,100+]")) %>%
  group_by_at(vars(-age, -value, -marital_status, -index, -year, -perc_pop)) %>%
  summarize(value = sum(value), perc_pop = sum(perc_pop)) %>%
  ungroup()

# it_dem_wider -----
# if we want to use caret or any package for regression we need to have a variable age-sex bins as columns
it_dem_wider <- it_dem_bins %>%
  mutate(sex_age_bin = paste0("perc_", sex, "_", age_bins)) %>% # now that we have the perc we create the new factor
  select(region, tot, perc_pop, sex_age_bin) %>%
  # now we do the magic
  pivot_wider(names_from = sex_age_bin, values_from = perc_pop) %>%
  rename(pop_tot = tot)

# it_dem_65bin_fm -----
dem_65bin_fm <-
  it_dem %>%
  mutate(age_bins = cut(age, breaks = c(0, 65, 100), include.lowest = TRUE, labels = c("less65", "65andMore"))) %>%
  group_by(region, age_bins, sex) %>%
  dplyr::summarize(pop_tot = first(tot), value = sum(value), perc_pop = sum(perc_pop)) %>%
  filter(age_bins == "65andMore") %>%
  ungroup() %>%
  select(-value, -age_bins) %>%
  pivot_wider(names_from = sex, values_from = perc_pop) %>%
  rename(female_65m = female, male_65m = male)


# it_firstaid 2018 -------------------
it_firstaid <- vroom("data-raw/it_us/it/first_aid.csv",
  col_types = cols(
    ITTER107 = col_character(),
    Territory = col_character(),
    TIPO_DATO_AVQ = col_character(),
    `Data type` = col_character(),
    MISURA_AVQ = col_character(),
    Measure = col_character(),
    TIME = col_double(),
    `Select time` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_logical(),
    Flags = col_logical()
  )
) %>%
  select(Territory, "Data type", Measure, TIME, Value) %>%
  filter(Measure == "thousands value", TIME == 2018) %>%
  mutate(int_var = recode(`Data type`,
    "persons who used the first aid in the 3 months preceding the inteview" = "first_aid",
    "persons who used the medical guard in the 3 months preceding the interview" = "medical_guard"
  )) %>%
  filter(int_var %in% c("first_aid", "medical_guard")) %>%
  select(Territory, int_var, Value) %>%
  mutate(Value = Value * 1000) %>%
  pivot_wider(names_from = int_var, values_from = Value) %>%
  rename(region = Territory) %>%
  mutate(
    region =
      recode(
        region,
        "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
        "Provincia Autonoma Bolzano / Bozen" = "P.A. Bolzano",
        "Provincia Autonoma Trento"  = "P.A. Trento",
        "Friuli-Venezia Giulia"  = "Friuli Venezia Giulia",
        "Emilia-Romagna" = "Emilia Romagna"
      )
  )

# it_fl_2019 ---------

area_sel <- c(
  top = 92.6606873324687, left = 49.819066386841, bottom = 436.401946791649,
  right = 772.17388698945
) # got this using locate_areas()

suppressWarnings(
  fl_tab <- extract_tables(
    "data-raw/it_us/it/flu_italy_to2018.pdf",
    output = "data.frame",
    pages = 1,
    area =  list(area_sel),
    guess = FALSE
  )[[1]]
)

it_fl <- fl_tab %>%
  rename(region = X) %>%
  {
    x <- .
    x <- x[3:nrow(x), ]
    names(x) <- str_remove_all(names(x), "[[:punct:]]|X")
    x
  } %>%
  mutate_all(list(~ gsub(., pattern = ",", replacement = "."))) %>%
  rename("2019" = ncol(.)) %>%
  {
    x <- .
    x[x == ""] <- NA
    x$region[x$region == "P. A. Trento"] <- "P.A. Trento"
    x <- x[!is.na(x$region), ]
    x
  }

it_fl_2019 <-
  it_fl %>%
  select(region, `2019`) %>%
  rename(perc_imm = `2019`)

area_sel2 <- c(
  top = 75.63785, left = 51.12191, bottom = 434.73870,
  right = 795.57018
) # got this using locate_areas()



suppressWarnings(
  fl65_tab <- extract_tables(
    "data-raw/it_us/it/flu_italy_to2018.pdf",
    output = "data.frame",
    pages = 3,
    area =  list(area_sel2),
    guess = FALSE
  )[[1]]
)


it_fl65 <- fl65_tab %>%
  rename(region = X) %>%
  {
    x <- .
    x <- x[3:nrow(x), ]
    names(x) <- str_remove_all(names(x), "[[:punct:]]|X")
    x
  } %>%
  mutate_all(list(~ gsub(., pattern = ",", replacement = "."))) %>%
  rename("2019" = ncol(.)) %>%
  {
    x <- .
    x[x == ""] <- NA
    x$region[x$region == "P. A. Trento"] <- "P.A. Trento"
    x <- x[!is.na(x$region), ]
    x
  }

it_fl65_2019 <- it_fl65 %>%
  rename(perc_imm65 = "2019") %>%
  mutate(perc_imm65 = as.numeric(perc_imm65)) %>%
  select(region, perc_imm65)

it_fl_2019 <- inner_join(it_fl65_2019, it_fl_2019, by = "region")


# it_house -------------------
it_house <- vroom("data-raw/it_us/it/people_household.csv", col_types = cols(
  ITTER107 = col_character(),
  Territorio = col_character(),
  TIPO_DATO8 = col_character(),
  `Tipo dato` = col_character(),
  MISURA1 = col_double(),
  Misura = col_character(),
  TIME = col_double(),
  `Seleziona periodo` = col_double(),
  Value = col_double(),
  `Flag Codes` = col_logical(),
  Flags = col_logical()
)) %>%
  select(Territorio, TIME, Value) %>%
  rename(region = Territorio, year = TIME, phouse = Value) %>%
  mutate(
    region =
      recode(
        region,
        "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
        "Provincia Autonoma Bolzano / Bozen" = "P.A. Bolzano",
        "Provincia Autonoma Trento"  = "P.A. Trento",
        "Friuli-Venezia Giulia"  = "Friuli Venezia Giulia",
        "Emilia-Romagna" = "Emilia Romagna"
      )
  )

# it_hospbed -------
# persons using first aid or medical guard in 3 months preceding (2018)
# inpatient hospital beds (2017) per 1000 people
it_hospbed <- vroom("data-raw/it_us/it/hospital_beds.csv",
  col_types = cols(
    ITTER107 = col_character(),
    Territory = col_character(),
    TIPO_DATO14 = col_double(),
    `Data type` = col_character(),
    TIPO_ATTIVITASAN = col_double(),
    `Type of clinical specialty` = col_character(),
    TIME = col_double(),
    `Select time` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_logical(),
    Flags = col_logical()
  )
) %>%
  select(Territory, `Type of clinical specialty`, Value) %>%
  rename(type = `Type of clinical specialty`) %>%
  # pivot_longer crashes miserably got to use spread
  spread(type, Value) %>%
  rename(region = Territory, bed_acute = `acute care`, bed_long = `long term care`, bed_rehab = rehabilitation, bed_tot = total) %>%
  mutate(
    region =
      recode(
        region,
        "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
        "Provincia Autonoma Bolzano / Bozen" = "P.A. Bolzano",
        "Provincia Autonoma Trento"  = "P.A. Trento",
        "Friuli-Venezia Giulia"  = "Friuli Venezia Giulia",
        "Emilia-Romagna" = "Emilia Romagna"
      )
  )

# it_netinc -------
it_netinc <- vroom("data-raw/it_us/it/netinc_it.csv",
  col_types = cols(
    IT107 = col_character(),
    Territory = col_character(),
    T_D8 = col_character(),
    `Data type` = col_character(),
    PRAF = col_double(),
    `Including or not including imputed` = col_character(),
    RDPR = col_double(),
    `Households main income source` = col_character(),
    TIME = col_double(),
    `Select time` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_character(),
    Flags = col_character()
  )
) %>%
  filter(
    `Including or not including imputed` == "including imputed rents",
    T_D8 == "REDD_MEDIANO_FAM"
  ) %>%
  select(Territory, starts_with("Households"), Value) %>%
  pivot_wider(names_from = starts_with("Households"), values_from = Value) %>%
  rename(region = Territory, netinc = total) %>%
  mutate(
    region =
      recode(
        region,
        "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
        "Provincia Autonoma Bolzano / Bozen" = "P.A. Bolzano",
        "Provincia Autonoma Trento"  = "P.A. Trento",
        "Friuli-Venezia Giulia"  = "Friuli Venezia Giulia",
        "Emilia-Romagna" = "Emilia Romagna"
      )
  )

# it_pm2.5 -----
it_pm2.5_p <- vroom(
  "data-raw/it_us/it/pm2.5_it.csv",
  col_types = cols(
    region = col_character(),
    `1990` = col_number(),
    `1995` = col_number(),
    `2000` = col_number(),
    `2005` = col_number(),
    `2010` = col_number(),
    `2015` = col_number(),
    `2017` = col_number()
  )
)
# pm2.5f_it
it_pm2.5 <-
  it_pm2.5_p %>%
  select(region, `2017`) %>%
  rename(pm2.5 = `2017`)

# it_regions ------
wiki <- xml2::read_html("https://it.wikipedia.org/wiki/Regioni_d%27Italia")


it_regions_p <- wiki %>%
  rvest::html_nodes("table") %>%
  rvest::html_table(fill = TRUE) %>%
  {
    x <- .
    x[[3]]
  }

# let's clean the names
it_regions <- it_regions_p %>%
  select(Regione, `Superficie (km²)`) %>%
  rename(region = Regione, area_km2 = `Superficie (km²)`) %>%
  mutate(region = str_replace(region, "-", " "), area_km2 = as.numeric(str_remove(area_km2, "[[:blank:]]"))) %>%
  filter(!region %in% c("Trentino Alto Adige", "Italia"))

#  we add those missing regions
it_regions <- bind_rows(it_regions, tribble(
  ~region, ~area_km2,
  "P.A. Bolzano", 7398,
  "P.A. Trento", 2397
))



# it_smoking ------
it_smoking <- vroom("data-raw/it_us/it/smoking.csv",
  col_types = cols(
    ITTER107 = col_character(),
    Territorio = col_character(),
    TIPO_DATO_AVQ = col_character(),
    `Tipo dato` = col_character(),
    MISURA_AVQ = col_character(),
    Misura = col_character(),
    TIME = col_double(),
    `Seleziona periodo` = col_double(),
    Value = col_double(),
    `Flag Codes` = col_logical(),
    Flags = col_logical()
  )
) %>%
  rename(
    region = Territorio,
    smoking_status = TIPO_DATO_AVQ,
    value = Value
  ) %>%
  filter(Misura == "valori in migliaia") %>%
  select(region, smoking_status, value) %>%
  mutate(region = str_replace(region, "-", " ")) %>%
  filter(!region %in% c("Trentino Alto Adige / Südtirol", "Italia")) %>%
  # make name consistent
  mutate(region = recode(region,
    "Valle d'Aosta / Vallée d'Aoste" = "Valle d'Aosta",
    "Provincia Autonoma Bolzano / Bozen" =  "P.A. Bolzano",
    "Provincia Autonoma Trento"   =  "P.A. Trento",
    "Fiuli Venezia Giulia"  = "Friuli Venezia Giulia"
  )) %>%
  mutate(smoking_status = recode(smoking_status,
    "14_FUMO_SI" = "smoking_current",
    "14_FUMO_EX" = "smoking_ex",
    "14_FUMO_NO" = "smoking_no"
  )) %>%
  filter(smoking_status %in% c("smoking_current", "smoking_ex", "smoking_no")) %>%
  # values are in thousands
  mutate(value = value * 1000) %>%
  pivot_wider(names_from = smoking_status, values_from = value)

# xxxxxxxxxxxxxxxx-------------------
# savedata  ------------------------
# xxxxxxxxxxxxxxxx-------------------
# external data

us_dem <- us_age_sex
usethis::use_data(
  # US data
  us_acm_househ,
  us_dem,
  us_fl65,
  us_hospbeds,
  us_mmd,
  us_poverty,
  # state_abbr,
  # italy
  it_bweight,
  it_cancer,
  it_chronic,
  # dem_65bin_fm,
  it_dem,
  it_firstaid,
  it_fl,
  it_fl65,
  it_hospbed,
  it_house,
  it_netinc,
  us_netinc,
  it_pm2.5,
  us_pm2.5,
  us_race,
  it_regions,
  it_smoking,
  us_season,
  # internal = TRUE,
  overwrite = TRUE
)
#





# they take the mean of all the different years, we do the same -----
us_pm2.5 <-
  us_pm2.5 %>%
  group_by(fips) %>%
  summarize(pm2.5 = mean(pm25, na.rm = TRUE)) %>%
  ungroup()

us_season <-
  us_season %>%
  group_by(fips) %>%
  # easy summarization of each variable...
  summarize_at(
    vars(summer_temp:winter_hum), mean,
    na.rm = TRUE
  ) %>%
  ungroup()


# # internal data
usethis::use_data(
  # US data
  us_acm_househ,
  us_age_sex,
  us_fl65,
  us_hospbeds,
  us_mmd,
  us_poverty,
  state_abbr,
  # italy
  it_bweight,
  it_cancer,
  it_chronic,
  dem_65bin_fm,
  it_dem,
  it_firstaid,
  it_fl,
  it_fl_2019,
  it_hospbed,
  it_house,
  it_netinc,
  us_netinc,
  it_pm2.5,
  us_pm2.5,
  us_race,
  it_regions,
  it_smoking,
  us_season,
  internal = TRUE,
  overwrite = TRUE
)

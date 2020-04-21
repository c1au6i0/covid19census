library(vroom)
library(tidyverse)
library(janitor)
library(reshape2)


# United States #-----

# age and sex- age_sex_us ---------

age_sex_all_us <- vroom("data-raw/us/american_comunity_survey_2018/age_sex/ACSST5Y2018.S0101_data_with_overlays_2020-04-14T063202.csv",
                        skip = 1,
                        col_select = c(`id`, `Geographic Area Name`, starts_with("Estimate"))
) %>%
  clean_names()


to_select_age_sex <- readxl::read_xlsx("data-raw/us/american_comunity_survey_2018/age_sex/to_select_age_sex.xlsx")

age_sex_us <- age_sex_all_us %>%
  select(!!to_select_age_sex$old_names)


names(age_sex_us) <- to_select_age_sex$new_names

age_sex_us <- age_sex_us %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  mutate(fips = as.numeric(fips))


# flu vax - fl65_us  ----------
fl65_all_us <- vroom("data-raw/us/flu_us.csv",
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

fl65_us <- fl65_all_us %>%
  rename("imm65" = "analysis_value") %>%
  dplyr::select(state, county, fips, imm65)

# hospital beds - hospbeds_us  ----------
hospbeds_all_us <- vroom("data-raw/us/hospital_beds.csv",
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
  filter(beds != -999)  # "KY, 47125" # "OH, 36091"


# https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/data?page=18

# this is by city we need to go by county
hospbeds_us <- hospbeds_all_us %>%
  rename(fips = countyfips) %>%
  group_by(state, fips) %>%
  summarize(tot_beds = sum(beds, na.rm = TRUE)) %>%
  mutate(fips = as.numeric(fips)) %>%
  filter(!is.na(fips))

# Mapping Medicare Disparities - mmd_us  ----------
to_imp <- list.files("data-raw/us/data_cms/", full.names = TRUE)
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

mmd_us <- mmd_all_us %>%
  mutate(
    condition =
      recode(condition,
        "Alzheimer's Disease, Related Disorders, or Senile Dementia" = "alzheimer_dementia",
        "Rheumatoid Arthritis/Osteoarthritis" = "rheumatoid_arthritis",
        "Cancer, Colorectal, Breast, Prostate, Lung" = "cancer_all",
        "Chronic obstructive pulmonary disease" = "ch_obstructive_pulm",
        "Stroke/Transient Ischemic Attack" = "stroke",
        "Schizophrenia and other psychotic disorders" = "schizophrenia_psychotic_dis"
      )
  ) %>%
  # pivot_longer and spread crash as a bitch
  reshape2::dcast(... ~ condition, value.var = "analysis_value") %>%
  clean_names() %>%
  # just reordering (lin the future reorder)
  select( year, fips, county, state, urban, acute_myocardial_infarction,
  alzheimer_dementia, asthma, atrial_fibrillation,
  cancer_breast, cancer_colorectal, cancer_lung, cancer_all,
  ch_obstructive_pulm, chronic_kidney_disease, depression,
  diabetes,  heart_failure, hypertension, ischemic_heart_disease, obesity, osteoporosis,
  rheumatoid_arthritis, schizophrenia_psychotic_dis, stroke, tobacco_use, urgent_admission,annual_wellness_visit,
  elective_admission, emergent_admission, other_admission, pneumococcal_vaccine)



# AMERICAN COMUNITY SURVEY
# codes: https://www.census.gov/programs-surveys/acs/technical-documentation/code-lists.html
# households - acm_househ_us ----------
acm_househ_all_us <- vroom("data-raw/us/american_comunity_survey_2018/households/ACSDP5Y2018.DP02_data_with_overlays_2020-04-15T004120.csv",
  col_types = cols(.default = "c"), skip = 1
) %>%
  clean_names() %>%
  select(id, geographic_area_name, starts_with("percent_estimate"))


to_select <- readxl::read_xlsx("data-raw/us/american_comunity_survey_2018/households/to_select.xlsx")

acm_househ_us <- acm_househ_all_us %>%
  select(!!to_select$old_names)

names(acm_househ_us) <- to_select$new_names

# the id is 0500000US16001 with last 5 numbers identifing the fips
acm_househ_us <- acm_househ_us  %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  mutate_at(vars(-state_county), as.numeric) %>%
  filter(fips < 72000 ) # no values for PuertoRico

# poverty_us -------------------
to_select_pov <- readxl::read_xlsx("data-raw/us/american_comunity_survey_2018/poverty/to_select_pov.xlsx")

poverty_all_us <- vroom("data-raw/us/american_comunity_survey_2018/poverty/ACSST5Y2018.S1701_data_with_overlays_2020-04-16T182603.csv",
                         skip = 1
) %>%
  clean_names() %>%
  select(!!to_select_pov$old_names)


names(poverty_all_us) <- to_select_pov$new_names

poverty_us <- poverty_all_us %>%
  separate(id, into = c("us_id", "fips"), sep = 9) %>%
  select(-us_id) %>%
  separate(geographic_area_name, c("county", "state"), sep = ",") %>%
  mutate_at(vars(-county, -state), as.numeric)

# state abbreviations

state_abbr <- vroom("data-raw/us/state_abbr.csv", col_types = cols(.default = "c"))


# usethis::use_data(acm_househ_us,
#                   age_sex_us,
#                   fl65_us,
#                   hospbeds_us,
#                   mmd_us,
#                   poverty_us,
#                   # state_abbr,
#                   # internal = TRUE,
#                   overwrite = TRUE)




















































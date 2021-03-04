#' get COVID-19 from JHU
#'
#' extracts time series from the git repository of the \href{ https://github.com/CSSEGISandData }{JHU}
#'
#' @return a dataframe
#' @import vroom
#' @details `cases` represents the number of confirmed cases, while `cmr` the case-mortality rate (deaths / confirmed_case * 100).
#' A good description of pitfalls and caveats associated with the use of case-mortality rate metric has been made on
#' \href{ https://ourworldindata.org/covid-mortality-risk }{Our World in Data}.
#' @keywords internal
getus_covid_jhu <- function() {
  url_base <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_"
  metric_files <- list("confirmed", "deaths")

  message("Retriving data...please wait!")

  # JHU has 2 files with date in long format (confirmed and deaths)...whatever
  dat_l <- lapply(metric_files, function(x) {
    url_full <- paste0(url_base, x, "_US.csv")

    if (RCurl::url.exists(url_full) == FALSE) {
      stop("Something wrong with the repository or your internet connection!")
    }

    dat <- vroom(url_full, col_types = c(.default = "?"), progress = FALSE)

    col_to_long <- grep("[0-9]{1,}/", names(dat), value = TRUE, perl = TRUE)

    dat_long <- reshape2::melt(dat, measure.vars = col_to_long,
                     variable.name = "date",
                     value.name = "value")

    dat_long <- janitor::clean_names(dat_long)

    dat_long_filt <- dat_long[dat_long$country_region == "US",
                              c("date", "combined_key", "fips", "value")]

    dat_long_filt$fips <- as.numeric(dat_long_filt$fips)

    dat_long_filt[, "county_state"] <- gsub(",(.)?US$", "", dat_long_filt$combined_key, perl = TRUE)

    dat_long_filt$state <- ifelse(
      grepl(",", dat_long_filt$county_state) == FALSE,
      dat_long_filt$county_state,
      gsub(".*,(\\s)?", "", dat_long_filt$county_state, perl = TRUE)
    )

    dat_long_filt$county <- ifelse(
      grepl(",", dat_long_filt$county_state) == FALSE,
      NA,
      gsub(",.*", "", dat_long_filt$county_state, perl = TRUE)
    )

    dat_long_filt <- dat_long_filt[!is.na(dat_long_filt$county) &
                    !is.na(dat_long_filt$fips) &
                    dat_long_filt$state != "Puerto Rico",]

    dat_long_filt <- dat_long_filt[, names(dat_long_filt) != "county_state"]

    # JHU has unincorporated U.S territories and the cruises data
    # that ends up to be NA because they have not counties in the dataframe
    # dplyr::filter(!is.na(.data$county), !is.na(.data$fips)) %>%
    #   dplyr::filter(.data$state != "Puerto Rico") %>%
    #   dplyr::select(-.data$county_state)

    names(dat_long_filt)[names(dat_long_filt) == "value"] <- x

    dat_long_filt

  })

  names(dat_l) <- metric_files
  dat_l <- lapply(dat_l, data.table::as.data.table)


  # funny things is that there are unassigned county (confirmed 90049),
  # that in the same file have a county

  dat_w <- dat_l$confirmed[, c("date", "fips", "confirmed")]

  dat_w_j <- data.table::merge.data.table(dat_w, dat_l$deaths, by = c("date", "fips"))

  names(dat_w_j)[names(dat_w_j) == "confirmed"] <- "cases"

  dat_w_j$date <-  as.Date(dat_w_j$date, format = "%m/%d/%y")
  dat_w_j$cmr <- dat_w_j$deaths / dat_w_j$cases * 100

  dat_out <- dat_w_j[, c("date", "county", "state", "fips", "cases", "deaths", "cmr")]

  message(paste0("US COVID-19 data up to ", max(dat_out$date), " successfully retrived from JHU repository!"))

  as.data.frame(dat_out)
}


#' get COVID-19 from NYT
#'
#' extracts time series from the git repository of the \href{ https://github.com/nytimes/covid-19-data }{NYT}
#'
#' @return a dataframe
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @import vroom
#' @details `cases` represents the number of confirmed cases, while `cmr` the case-mortality rate (deaths / confirmed_case * 100).
#' A good description of pitfalls and caveats associated with the use of case-mortality rate metric has been made on
#' \href{ https://ourworldindata.org/covid-mortality-risk }{Our World in Data}.
#' @keywords internal
getus_covid_nyt <- function() {
  url_data <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"

  message("Retriving data...please wait...!")

  if (RCurl::url.exists(url_data) == FALSE) {
    stop("Something wrong with the repository or your internet connection!")
  }


  dat <- vroom(url_data,
    col_types = cols(
      date = col_date(format = ""),
      county = col_character(),
      state = col_character(),
      fips = col_double(),
      cases = col_double(),
      deaths = col_double()
    )
  ) %>%
    dplyr::mutate(cmr = .data$deaths / .data$cases * 100) %>%
    dplyr::filter(.data$state %in% state_abbr$state)

  dat$fips[is.na(dat$fips)] <- 00000

  message(paste0("US COVID-19 data up to ", max(dat$date), " successfully retrived from NYT repository!"))

  dat
}

#' get COVID-19
#'
#' extracts time series from the git repository of the  \href{ https://github.com/nytimes/covid-19-data }{NYT} or of the
#' \href{ https://github.com/CSSEGISandData }{JHU}
#'
#' @param repo repository of COVID-19 data, one of `c("nyt", "jhu")`
#' @return a dataframe
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @import vroom
#' @details `cases` represents the number of confirmed cases, while `cmr` the case-mortality rate (deaths / confirmed_case * 100).
#' A good description of pitfalls and caveats associated with the use of case-mortality rate metric has been made on
#' \href{ https://ourworldindata.org/covid-mortality-risk }{Our World in Data}.
#' @examples
#' dat <- getus_covid(repo = "jhu")
#' @export
#'
getus_covid <- function(repo = "jhu") {
  if (!repo %in% c("nyt", "jhu")) {
    stop("The argument repo can be only nyt or jhu")
  }
  if (repo == "nyt") {
    dat <- getus_covid_nyt()
  } else {
    dat <- getus_covid_jhu()
  }

  as.data.frame(dat)
}


#' get device-exposure indexes (DEX)
#'
#' extracts DEX from the git repository of the
#' \href{https://github.com/COVIDExposureIndices/COVIDExposureIndices}{COVID-19 exposure indeces}
#'
#' @return a dataframe
#' @details main metric is `dex_a`. In the \href{https://github.com/COVIDExposureIndices/COVIDExposureIndices}{repository}, they
#' explains: \cite{In the context of the ongoing pandemic, the DEX measure may be biased if devices sheltering-in-place
#' are not in the sample due to lack of movement. We report adjusted DEX values to help address this selection bias.
#' DEX-adjusted is computed assuming that the number of devices has not declined since the early-2020 peak
#' and that unobserved devices did not visit any commercial venues.} Datataset is updated by the mantainers every weekend.
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @import vroom
#' @export
getus_dex <- function() {
  url_data <- "https://raw.githubusercontent.com/COVIDExposureIndices/COVIDExposureIndices/master/dex_data/county_dex.csv"

  if (RCurl::url.exists(url_data) == FALSE) {
    stop("Something wrong with the repository or your internet connection!")
  }


  dat <- vroom(url_data,
    skip = 1,
    col_names = c(
      "fips",
      "date",
      "dex",
      "num_devices",
      "dex_a",
      "num_devices_a"
    ),

    col_types = cols(
      fips = col_double(),
      date = col_date(format = "%F"),
      dex = col_double(),
      num_devices = col_double(),
      dex_a = col_double(),
      num_devices_a = col_double(),
      .delim = ","
    )
  )

  message(paste0("US mobility data up to ", max(dat$date), " successfully retrived!"))

  dat
}

#' get number of tests and  hospitalizations
#'
#' extracts information on tests, hospitalizations and other metrics at the \strong{State level} maintained by the
#' \href{https://covidtracking.com/api}{the COVID Tracking Project}
#' @return a dataframe with 15 variables
#' @details a description of the variable can be found in the \href{https://covidtracking.com/api}{the COVID Tracking Project} and when possible
#' was used verbatim for the description below
#' \describe{
#'     \item{date}{in `ISO 8601` format}
#'     \item{state}{state name}
#'     \item{abbr}{abbreviation}
#'     \item{positive}{total cumulative positive test results}
#'     \item{negative}{total cumulative negative test results}
#'     \item{pending}{tests that have been submitted to a lab but no results have been reported yet}
#'     \item{hospitalized_curr}{current people hospitalized}
#'     \item{hospitalized_cumul}{cumulative people hospitalized}
#'     \item{icu_curr}{current people in ICU}
#'     \item{icu_cumul}{cumulative people in ICU}
#'     \item{ventilator_curr}{current people using ventilator}
#'     \item{ventilator_cumul}{cumulative people using ventilator}
#'     \item{recovered}{total people recoverd}
#'     \item{hash}{unique ID changed every time the data updates}
#'     \item{date_checked}{date of the time we last visited their website}
#'     \item{death}{number of deaths}
#'     \item{death_increase}{increase in deaths from day before}
#'     \item{hospitalized_increase}{increase in hospitalization from day before}
#'     \item{negative_increase}{increase in negative results from day before}
#'     \item{positive_increase}{increase in positive results from day before}
#'     \item{total_test_increase}{increase from the day before}
#' }
#' Other details regarding the score system used are reported in the \href{https://covidtracking.com/about-data}{maintainers webpage}.\cr
#' \strong{Note for the use of some of some this variables by covidtracking authors:} \cr
#' \emph{States are currently reporting two fundamentally unlike statistics: current hospital/ICU admissions and cumulative hospitalizations/ICU admissions.
#' Across the country, this reporting is also sparse.
#' In short: it is impossible to assemble anything resembling the real statistics for hospitalizations,
#' ICU admissions, or ventilator usage across the United States. As a result, we will no longer provide
#' national-level summary hospitalizations, ICU admissions, or ventilator usage statistics on our site.}
#' @import vroom
#' @export
getus_tests <- function() {
  url_data <- "https://covidtracking.com/api/v1/states/daily.csv"

  # if (RCurl::url.exists(url_data) == FALSE) {
  #   stop("Something wrong with the repository or your internet connection!")
  # }


  dat <- vroom::vroom(url_data,
    col_types = cols(
      date = col_date(format = "%Y%m%d"),
      state = col_character(),
      positive = col_double(),
      negative = col_double(),
      pending = col_double(),
      hospitalizedCurrently = col_double(),
      hospitalizedCumulative = col_double(),
      inIcuCurrently = col_double(),
      inIcuCumulative = col_double(),
      onVentilatorCurrently = col_double(),
      onVentilatorCumulative = col_double(),
      recovered = col_double(),
      hash = col_character(),
      dateChecked = col_skip(),
      death = col_double(),
      hospitalized = col_double(),
      total = col_double(),
      totalTestResults = col_double(),
      posNeg = col_double(),
      fips = col_character(),
      deathIncrease = col_double(),
      hospitalizedIncrease = col_double(),
      negativeIncrease = col_double(),
      positiveIncrease = col_double(),
      totalTestResultsIncrease = col_double()
    )
  ) %>%
    janitor::clean_names()

  colnames(dat)[colnames(dat) == "state"] <- "abbr"

  message(paste0("US test data up to ", max(dat$date, na.rm = TRUE), " successfully retrived!"))

  # we don't have unincorporated territories in getus_all()
  dat2 <- dat[dat$abbr %in% state_abbr$abbr, ]

  # we use the function recode_col from the current package to recode the state abbr to state names
  # that are exactly the same of those generate by getus_all()
  dat2$state <- recode_col(dat2$abbr, state_abbr$state)

  dat2 <- dat2[, c(
    "date", "state", "abbr", "positive", "negative", "pending", "hospitalized_currently",
    "hospitalized_cumulative", "in_icu_currently", "in_icu_cumulative",
    "on_ventilator_currently", "on_ventilator_cumulative", "recovered",
    "hash", "death", "fips", "death_increase", "hospitalized_increase",
    "negative_increase", "positive_increase", "total_test_results_increase"
  )]

  names(dat2) <- c(
    "date", "state", "abbr", "positive", "negative", "pending", "hospitalized_curr",
    "hospitalized_cumul", "icu_curr", "icu_cumul",
    "ventilator_curr", "ventilator_cumul", "recovered",
    "hash", "death", "fips", "death_increase", "hospitalized_increase",
    "negative_increase", "positive_increase", "total_test_increase"
  )
  dat2
}

#' get COVID-19 and other metrics
#'
#' extracts/joins COVID-19 info with other demographic metrics at the county level and tests and hospitalizations from
#' \href{https://covidtracking.com/api}{the COVID Tracking Project}
#'
#' @source \href{https://www.cms.gov/About-CMS/Agency-Information/OMH/Downloads/Mapping-Technical-Documentation.pdf}{Center for Medicare and Medicaid Services},
#'  \href{https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/data?page=18}{Homeland Infrastructure Foundation-Level Data},
#'  \href{https://data.census.gov/cedsci/table?q=United%20States}{American Community Survey tables},
#'  \href{https://data.cms.gov/mapping-medicare-disparities}{Mapping Medicare Disparities},
#'  \href{https://github.com/COVIDExposureIndices/COVIDExposureIndices}{COVIDExposureIndices},
#'  \href{http://fizz.phys.dal.ca/~atmos/martin/?page_id=140#V4.NA.02.MAPLE}{Atmoshpheric Composition Analysis Group}
#' @param repo repository of COVID-19 data, one of `c("nyt", "jhu")`
#' @return A dataframe. Data regarding the household composition, population sex, age, race, ancestry and poverty levels,
#'  were scraped from the 2018 American Community Survey (ACS). Poverty was defined at the family level and not the household level in
#'  the ACS. Medical conditions, tobacco use, cancer and, data relative to the number of medical and emergency visits
#'  was obtained from the 2017 Mapping Medicare Disparities. From relative documentation listed in the source: "Prevalence rates are calculated
#'  by searching for certain diagnosis codes in \strong{Medicare beneficiaries’ claims}. The admission rate by admission type is the frequency of
#'  a specific type of inpatient admission per 1,000 inpatient admissions in a year."
#'  The number of hospital beds per county was calculated from data of the2020 Homeland Infrastructure Foundation.
#'  Emissions of particulate 2.5 in micro g/m3 (2000-2016) and seasonal temperature (2000-2016) were reported by \href{http://fizz.phys.dal.ca/~atmos/martin/?page_id=140#V4.NA.02.MAPLE}{Atmoshpheric Composition Analysis Group} and
#'  aggregate by \href{https://github.com/wxwx1993/PM_COVID/blob/master/additional_preprocessing_code/download_pm25_values.md}{Ista Zahn and Ben Sabath}. \cr
#'  The following list of variables is divided in sections \emph{COVID-19 VARS, HOUSEHOLDS MARITAL STATUS AND COMPOSITION, HOUSEHOLDS EDUCATION DEGREES,
#'  ANCESTRY, COMPUTER OR INTERNET, POPULATION AND SEX, POPULATION AND RACE, MEDICAL AND VACCINES, POVERTY, ACTIVITY, POLLUTIONS AND TEMPERATURE, STATE LEVEL TESTS AND HOSPITALIZATIONS}. \cr
#'  \strong{Note that data on test and hospitalizations are at the state level!}
#'  \describe{
#'     \item{date}{formatted `ISO 8601`}
#'     \item{county}{county}
#'     \item{state}{state}
#'     \item{fips}{federal information processing standard, a unique numeric identifier of a county.
#'         Unknown fips are coded as 00000. \strong{Note that in the nyt repository a lot of deaths
#'         and confirmed cases are no categorized
#'         at the county level}}
#'     \item{urban}{urban or rural (see \href{https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html}{cenus})}
#'     \item{\strong{COVID-19 VARS}}{---------------}
#'     \item{cases}{confirmed COVID-19 cases (cumulates with date)}
#'     \item{deaths}{number of deaths attributed to COVID-19}
#'     \item{cmr}{case-mortality rate (deaths / confirmed cases * 100)}
#'     \item{\strong{HOUSEHOLDS MARITAL STATUS AND COMPOSITION}}{---------------}
#'     \item{total_households}{total number of households (occupy a housing unit) in that county. People not living in households are classified as living in group quarters}
#'     \item{perc_families}{percent of households that are defined as family. A family consists of a householder and one or more other people living in the same household who are related to the householder by birth, marriage, or adoption}
#'     \item{perc_families_18childereen}{percent families with at least a child <= 18 years old}
#'     \item{perc_married_couples}{percent families consisting of married couples}
#'     \item{perc_married_couples_u18ychildreen}{percent families consisting of married couples at least a child 18 years old or less}
#'     \item{perc_families_only_male}{percent of family with a male householder and no spouse of householder present}
#'     \item{perc_families_only_male_18ychildreen}{percent families with male householder and no spouse of householder present and with at least a child under 18 years old}
#'     \item{perc_families_only_female}{percent families with female householder}
#'     \item{perc_families_only_female_18ychildreen}{percent families with female householder with at least a child under 18 years old}
#'     \item{perc_non_families}{percent of non-family households. A family consists of a householder and one or more other people living in the same household who are related to the householder by birth, marriage, or adoption}
#'     \item{perc_non_families_alone}{percent of non-family households with householder living alone}
#'     \item{perc_non_families_alone65y}{percent of non-family households with householder living alone, age 65 years and older}
#'     \item{perc_non_families_u18y}{percent of non-family households with one or more people under 18 years}
#'     \item{perc_non_families_65y}{percent of non-family households with with one or more people 65 years and older}
#'     \item{total_relationship_in_households}{total number of people that responded to the question regarding relationship}
#'     \item{perc_relationship_spouse}{households including person married to and living with the householder}
#'     \item{perc_relationship_child}{households including a son or daughter by birth, a stepchild, or adopted child of the householder}
#'     \item{perc_relationship_other_relatives}{percent households including other relatives}
#'     \item{perc_relationship_other_nonrelatives}{percent households including foster children, not related to the householder by birth, marriage, or adoption}
#'     \item{perc_relationship_other_unmaried_part}{percent households containing members other than a “married-couple household” that includes a householder and an “unmarried partner.” }
#'     \item{total_marital_status_male}{total males that responded to the marital status question}
#'     \item{perc_marital_status_male_nevermaried}{percent males never married}
#'     \item{perc_marital_status_male_maried}{percent males married}
#'     \item{perc_marital_status_male_separated}{percent of males separate}
#'     \item{perc_marital_status_male_}{percent of males widowed}
#'     \item{perc_marital_status_male_divorced}{percent of males divorced}
#'     \item{perc_marital_status_female_nevermaried}{perent of female never married}
#'     \item{perc_marital_status_female_maried}{perent of female married}
#'     \item{perc_marital_status_female_separated}{perent of female separated}
#'     \item{perc_marital_status_female_widowed}{perent of female widowed}
#'     \item{perc_marital_status_female_divorced}{perent of female divorced}
#'     \item{\strong{HOUSEHOLDS EDUCATION DEGREES}}{---------------}
#'     \item{total_enrolled_school}{total people enrolled in school}
#'     \item{perc_enrolled_preschool}{percent in preschool}
#'     \item{perc_enrolled_kindergarden}{percent in kindergarden}
#'     \item{perc_enrolled_elementary}{percent in elementary}
#'     \item{perc_enrolled_highschool}{percent in highschool}
#'     \item{perc_enrolled_college}{percent college}
#'     \item{total_edu}{total number of people 25 years old or more that responded to the question regarding education (?)}
#'     \item{perc_edu_9grade}{percent that went up to 9th grade}
#'     \item{perc_edu_nodiploma}{percent that went up to 9th grade}
#'     \item{perc_edu_highschool}{percent with highschool}
#'     \item{perc_edu_somecollege}{percent with some college}
#'     \item{perc_edu_associate}{percent that obtaibed an associate degree}
#'     \item{perc_edu_bachelor}{percent with bachelor}
#'     \item{perc_edu_gradprofess}{percent that graduated or with a professional degree}
#'     \item{perc_edu_bachelor_higher}{percent with bachelor or higher}
#'     \item{\strong{ANCESTRY}}{---------------}
#'     \item{total_ancestry}{total population}
#'     \item{perc_ \emph{anchestry}}{percent estimated specific ancestry (27)}
#'     \item{\strong{COMPUTER OR INTERNET}}{---------------}
#'     \item{total_withcomputer}{total that own or use a computer}
#'     \item{perc_withcomputer}{percent that owns or use computer}
#'     \item{perc_withinternet}{percet that has acces to internet}
#'     \item{\strong{POPULATION AND SEX}}{---------------}
#'     \item{total_pop}{total population}
#'     \item{total_male}{total male}
#'     \item{total_female}{total female}
#'     \item{total_ \emph{age_sex}}{total population by age bin and sex}
#'     \item{perc_ \emph{age_sex}}{percent population by age bin and sex}
#'     \item{median_age}{median age in years}
#'     \item{median_age_male}{median age in years of males}
#'     \item{median_age_female}{median age in years of females}
#'     \item{sex_ratio}{males per 100 females}
#'     \item{age_dependency}{the age dependency ratio is derived by dividing the combined under
#'         18  and 65-more year populations by the 18-to-64 population and multiplying the result by 100}
#'     \item{old_age_dependency}{the old-age dependency ratio is derived by dividing the population 65 years and over by the 18-to-64 population and multiplying by 100}
#'     \item{child_dependency}{the child dependency ratio is calculated dividing the population under 18 years by the 18-to-64 population, and multiplying the result by 100}
#'     \item{\strong{POPULATION AND RACE}}{---------------}
#'     \item{total_white}{total white}
#'     \item{total_black}{total black or afroamerican}
#'     \item{total_native}{total native}
#'     \item{total_asian}{total asian}
#'     \item{total_pacific_islander}{total hawaian and pacific islander}
#'     \item{total_other_race}{other races}
#'     \item{total_two_more_races}{two or more races}
#'     \item{total_latino}{total hispanic or latino}
#'     \item{\strong{MEDICAL AND VACCINES}}{---------------}
#'     \item{perc_imm65}{percentage of fee-for-service (FFS) Medicare enrollees that had an annual flu vaccination.}
#'     \item{total_beds}{total number of hospital beds}
#'     \item{perc_at_least_1_chronic}{percent medicare with at least a chronic condition}
#'     \item{perc_acute_myocardial_infarction}{percent medicare with acute myocardial infarction}
#'     \item{perc_alzheimer_dementia}{percent medicare with Alzheimer’s Disease, Related Disorders, or Senile Dementia}
#'     \item{perc_asthma}{percent medicare with asthma}
#'     \item{perc_atrial_fibrillation}{percent medicare with Atrial Fibrillation}
#'     \item{perc_cancer_breast}{percent medicare with Breast Cancer}
#'     \item{perc_cancer_colorectal}{percent medicare with Colorectal Cancer}
#'     \item{perc_cancer_lung}{percent medicare withLung Cancer}
#'     \item{perc_cancer_all}{percent medicare with Cancer (breast, colorectal, lung, and/or prostate)}
#'     \item{perc_ch_obstructive_pulm}{percent medicare with Chronic Obstructive Pulmonary Disease (COPD)}
#'     \item{perc_chronic_kidney_disease}{percent medicare with Chronic Kidney Disease}
#'     \item{perc_depression}{percent medicare with Depression}
#'     \item{perc_diabetes}{percent  medicare beneficiaries with Diabetes}
#'     \item{perc_hypertension}{percent  medicare beneficiaries with Hypertension}
#'     \item{perc_ischemic_heart_disease}{percent  medicare beneficiaries with Ischemic Heart Disease}
#'     \item{perc_obesity}{percent  medicare beneficiaries with Obesity}
#'     \item{perc_osteoporosis}{percent  medicare beneficiaries with Osteoporosis}
#'     \item{perc_rheumatoid_arthritis}{percent  medicare beneficiaries with Rheumatoid Arthritis}
#'     \item{perc_schizophrenia_psychotic_dis}{percent  medicare beneficiaries with Schizophrenia/Other Psychotic Disorders}
#'     \item{perc_stroke}{percent  medicare beneficiaries with Stroke Transient Ischemic Attack }
#'     \item{perc_tobacco_use}{}
#'     \item{urgent_admission}{urgent care admission rate}
#'     \item{annual_wellness_visit}{number of annual wellness visits}
#'     \item{elective_admission}{elective admission rate}
#'     \item{emergent_admission}{ER admission rate}
#'     \item{other_admission}{other admission rates}
#'     \item{perc_pneumococcal_vaccine}{percent pneumococcal vaccine }
#'     \item{\strong{POVERTY}}{---------------}
#'     \item{total_poverty_determination}{number of people evaluated for poverty}
#'     \item{total_poverty}{total people that met the definition of below poverty level}
#'     \item{perc_poverty}{percent people that met the definition of below poverty level}
#'     \item{total_determination \emph{age}}{total people evaluated in that age bin}
#'     \item{total_poverty \emph{age}}{total people that met the definition of below poverty level in that age bin}
#'     \item{perc_poverty \emph{age}}{percent people that met the definition of below poverty level in that age bin}
#'     \item{total_determination \emph{sex}}{total people evaluated for poverty in that sex}
#'     \item{total_poverty \emph{sex}}{total people that met the definition of below poverty level in that sex}
#'     \item{perc_poverty \emph{sex}}{perc people that met the definition of below poverty level in that sex}
#'     \item{total_determination \emph{race}}{total people evaluated for poverty in that race}
#'     \item{total_poverty \emph{race}}{total people that met the definition of below poverty level in that race}
#'     \item{perc_poverty \emph{race}}{perc people that met the definition of below poverty level in that race}
#'     \item{median_income)}{median household income}
#'     \item{\strong{ACTIVITY}}{---------------}
#'     \item{dex_a}{activity index}
#'     \item{\strong{POLLUTIONS AND TEMPERATURE}}{---------------}
#'     \item{pm2.5}{pm2.5 in  micro g per m3}
#'     \item{summer_temp}{mean temperature in summer, %}
#'     \item{summer_hum}{mean humity in summer, mixing ratio}
#'     \item{winter_temp}{mean temperature in winter, K}
#'     \item{winter_hum}{mean humity in winter, %}
#'     \item{\strong{STATE LEVEL TESTS AND HOSPITALIZATIONS}}{---------------}
#'     \item{positive}{total cumulative positive test results}
#'     \item{negative}{total cumulative negative test results}
#'     \item{pending}{tests that have been submitted to a lab but no results have been reported yet}
#'     \item{hospitalized_curr}{current people hospitalized}
#'     \item{hospitalized_cumul}{cumulative people hospitalized}
#'     \item{icu_curr}{current people in ICU}
#'     \item{icu_cumul}{cumulative people in ICU}
#'     \item{ventilator_curr}{current people using ventilator}
#'     \item{ventilator_cumul}{cumulativepeople using ventilator}
#'     \item{recovered}{total people recoverd}
#'     \item{death_increase}{increase in deaths from day before}
#'     \item{hospitalized_increase}{increase in hospitalization from day before}
#'     \item{negative_increase}{increase in negative results from day before}
#'     \item{positive_increase}{increase in positive results from day before}
#'     \item{total_test_increase}{increase from the day before}
#' }
#' @details For details regarding some specific datasets refer to: \href{https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2018_ACSSubjectDefinitions.pdf?#}{Subject Definitions of the American Community Survey},
#'  \href{https://www.cms.gov/About-CMS/Agency-Information/OMH/Downloads/Mapping-Technical-Documentation.pdf}{Medicare and Medicaid Medical Services Technical Documentation},
#'  \href{https://github.com/COVIDExposureIndices/COVIDExposureIndices}{COVIDExposureIndices}
#' @import vroom
#' @seealso \code{\link{getus_covid}},\code{\link{getus_tests}}, \code{\link{getus_dex}},
#' @export
getus_all <- function(repo = "jhu") {
  covid19_us <- getus_covid(repo = repo)
  dex_us <- getus_dex()
  dex_us_sel <- dex_us[, c("fips", "date", "dex_a")]


  tests_us <- getus_tests()
  tests_us_sel <-  tests_us[, !names(tests_us) %in% c("death", "death_increase", "abbr", "hash", "fips")]

  list_dat <-  list(us_acm_househ,
                    us_age_sex,
                    us_race,
                    us_fl65,
                    us_hospbeds,
                    us_mmd,
                    us_poverty,
                    us_netinc,
                    us_pm2.5,
                    us_season)

  # we keep only fips and vars
  to_join <- lapply(list_dat, function(x) {
    data.table::as.data.table(x[, !names(x) %in% c("state_county", "county", "state", "year", "abbr")])
  })

  dem_metrics <- Reduce(function(x, y) data.table::merge.data.table(x = x, y = y, by = "fips", all = TRUE),
         to_join)



  dat <- data.table::merge.data.table(covid19_us, dem_metrics, by = "fips", all.x = TRUE)
  dat2 <- data.table::merge.data.table(dat, dex_us_sel, by = c("fips", "date"), all.x = TRUE)
  dat_all <- data.table::merge.data.table(dat2, tests_us_sel, by = c("state", "date"), all.x = TRUE)

  names(dat_all) <- stringr::str_replace(names(dat_all), "tot_", "total_")

  as.data.frame(dat_all)
}









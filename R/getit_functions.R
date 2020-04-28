#' get COVID-19 updated cases
#'
#' extracts and translates time series form the git repository of the \href{https://github.com/pcm-dpc/COVID-19}{protezione civile}
#'
#' @return a dataframe with following 19 variables:
#' \describe{
#'      \item{date}{in `ISO 8601` format}
#'      \item{state}{state}
#'      \item{region_code}{region abbreviation}
#'      \item{region}{full name of region}
#'      \item{lat}{lat}
#'      \item{long}{long}
#'      \item{cmr}{case-mortality rate for that region and that date (deaths/total_cases * 100)}
#'      \item{total_cases}{number of COVID-19 positive cases detected}
#'      \item{deaths}{number of deaths}
#'      \item{tests}{number of tests performed}
#'      \item{hospitalized_with_symptoms}{number of people hospitalized with symptoms, that day}
#'      \item{intensive_care_unit}{number of people in intensive care units, that day}
#'      \item{total_hospitalized}{hospitalized_with_symptoms + intensive_care_unit}
#'      \item{home_quarantine}{number of people COVID-19 positive in home quarantine, that day}
#'      \item{total_positives}{total currently positives: hospitalized_with_symptoms + intensive_care_unit + home_quarantine}
#'      \item{change_positives}{change in the number of positive cases: total_positives that day - total_positives preceding day}
#'      \item{new_positives}{number of new positive cases: total_cases that day - total_cases preceding day}
#'      \item{recovered_released}{recovered - released from hospital}
#'      \item{people_tested}{number of people tested}
#' }
#' @details caveats and problems related the calculation by the Protezione Civile of some variables  were rised by
#' \href{https://www.gimbe.org/pagine/341/it/comunicati-stampa?pagina=2}{GIMBE fFoundation}. Unfortunately the page is in Italian...
#' \emph{ buona lettura! }
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @import vroom
#' @export
getit_covid <- function() {
  url_data <- "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv"

  if (RCurl::url.exists(url_data) == FALSE) {
    stop("Something wrong with the repository or your internet connection!")
  }

  dat <- vroom(
    file = url_data,
    skip = 1,
    col_names = c(
      "date",
      "state",
      "region_cod",
      "region",
      "lat",
      "long",
      "hospitalized_with_symptoms",
      "intensive_care_unit",
      "total_hospitalized",
      "home_quarantine",
      "total_positives",
      "change_positives",
      "new_positives",
      "recovered_released",
      "deaths",
      "total_cases",
      "tests",
      "people_tested",
      "note_it",
      "note_eng"
    ),
    col_types = cols(
      date = col_datetime(format = ""),
      state = col_character(),
      region_cod = col_character(),
      region = col_character(),
      lat = col_double(),
      long = col_double(),
      hospitalized_with_symptoms = col_double(),
      intensive_care_unit = col_double(),
      total_hospitalized = col_double(),
      home_quarantine = col_double(),
      total_positives = col_double(),
      change_positives = col_double(),
      new_positives = col_double(),
      recovered_released = col_double(),
      deaths = col_double(),
      total_cases = col_double(),
      tests = col_double(),
      people_tested = col_double(),
      note_it = "_",
      note_eng = "_"
    )
  ) %>%
    dplyr::mutate(
      cmr = .data$deaths / .data$total_cases * 100
    ) %>%
    dplyr::mutate(region = stringr::str_replace(.data$region, "-", " "))

  # just reorder
  dat <- dat[
    ,
    c(
      "date",
      "state",
      "region_cod",
      "region",
      "lat",
      "long",
      "cmr",
      "total_cases",
      "deaths",
      "tests",
      "hospitalized_with_symptoms",
      "intensive_care_unit",
      "total_hospitalized",
      "home_quarantine",
      "total_positives",
      "change_positives",
      "new_positives",
      "recovered_released",
      "people_tested"
    )
  ]

  message(paste0("Italy COVID-19 data up to ", max(dat$date), " successfully retrived!"))

  dat
}


#' get COVID-19 cases and other statistics
#'
#' extracts and translates time series form the git repository of the \href{https://github.com/pcm-dpc/COVID-19}{protezione civile} and
#' combines them with other statistics related to italian population.
#'
#' @return a dataframe with following 64 variables:
#' \describe{
#'      \item{date}{date of data}
#'      \item{state}{state}
#'      \item{region_code}{region abbreviation}
#'      \item{region}{full name of region}
#'      \item{lat}{lat}
#'      \item{long}{long}
#'      \item{imm}{influenza vaccination coverage in the general population}
#'      \item{imm65}{influenza vaccination coverage in people age 65 or older}
#'      \item{cmr}{case-mortality rate for that region and that date (deaths/total_cases * 100)}
#'      \item{total_cases}{number of COVID-19 positive cases detected}
#'      \item{deaths}{number of deaths}
#'      \item{tests}{number of tests performed}
#'      \item{hospitalized_with_symptoms}{number of people hospitalized with symptoms, that day}
#'      \item{intensive_care_unit}{number of people in intensive care units, that day}
#'      \item{total_hospitalized}{hospitalized_with_symptoms + intensive_care_unit}
#'      \item{home_quarantine}{number of people COVID-19 positive in home quarantine, that day}
#'      \item{total_positives}{total currently positives: hospitalized_with_symptoms + intensive_care_unit + home_quarantine}
#'      \item{change_positives}{change in the number of positive cases: total_positives that day - total_positives preceding day}
#'      \item{new_positives}{number of new positive cases: total_cases that day - total_cases preceding day}
#'      \item{recovered_released}{recovered - released from hospital}
#'      \item{people_tested}{number of people tested}
#'      \item{p_house}{number of people per squared meter living in the same house}
#'      \item{pop_tot}{total population}
#'      \item{area_km2}{household crowding index (number of components of household per square meter)}
#'      \item{pop_km2}{density of population per squared kilometer}
#'      \item{female_65m}{percent of females age 65 years old or more}
#'      \item{male_65m}{percent of males age 65 years old or more}
#'      \item{chronic_ \emph{type}}{percent of population with that chronic condistion}
#'      \item{cancer_\emph{type}}{percent of population with that type of cancer}
#'      \item{bweight_\emph{type}}{percent of people underweight, normalweight, overweight or obese}
#'      \item{first_aid}{number of peple using first aid in 3 months preceding the survey}
#'      \item{medical_guard}{number of people using medical guard in 3 months preceding the survey}
#'      \item{bed_acute}{inpatient hospital beds per 1000 people in acure care}
#'      \item{bed_long}{inpatient hospital beds per 1000 people in long care}
#'      \item{bed_rehab}{inpatient hospital beds per 1000 people in rehabilitation}
#'      \item{bed_tot}{inpatient hospital beds per 1000 people, total}
#'      \item{netinc}{median net annual households income, in euros}
#'      \item{pm2.5}{emission of pm2.5 in tons per region, 2017}
#' }
#' @details Data regarding COVID-19 comes form the repository of the \href{https://github.com/pcm-dpc/COVID-19}{protezione civile} and it is updated daily.
#' Age and sex of the population (2019),  first aid and medical guard visits (2018), smoking status (2018),  prevalence of chronic conditions (2018), annual-household income (2017)
#' household crowding index (2018) and body-mass index were dataset collect by  \href{http://dati.istat.it/?lang=en}{ISTAT}.
#' Prevalence of types of cancer patients (2016), influenza-vaccination coverage (2019) and the number of hospital beds per 1000 people (2017) were obtained from
#' \href{http://www.dati.salute.gov.it/}{Ministero della Salute}. Note that cancer patients prevalence was calculated using
#'  region population esitmates of 2019. Data of particulate 2.5 (2017) comes from the
#' \href{https://annuario.isprambiente.it/pon/basic/14}{Istituto Superiore Per La protezione Ambientale}.
#' @source  \href{https://github.com/pcm-dpc/COVID-19}{protezione civile}, \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @importFrom dplyr vars
#' @importFrom stats na.omit
#' @export
#' @seealso for details regarding  the methodology of specific datasets check  \code{\link{bweight_it}}, \code{\link{cancer_it}},
#' \code{\link{chronic_it}}, \code{\link{dem_it}}, \code{\link{firstaid_it}}, \code{\link{fl_it}}, \code{\link{fl65_it}},\code{\link{fl_it}},
#' \code{\link{hospbed_it}}, \code{\link{house_it}}, \code{\link{pm2.5_it}}
getit_all <- function() {
  cmr_it <- getit_covid()

  house_it <- house_it %>%
    dplyr::filter(.data$year == 2018) %>%
    dplyr::select(.data$region, .data$phouse) %>%
    dplyr::rename("p_house" = "phouse")

  # get data and combine it together
  dat1 <- plyr::join_all(list(cmr_it, house_it, fl_it_2019, dem_65bin_fm, regions_area), by = "region", type = "inner") %>%
    dplyr::mutate_at(vars("perc_imm65", "perc_imm"), as.numeric) %>%
    dplyr::mutate(pop_km2 = .data$pop_tot / .data$area_km2)

  # reorder col, yes this is not elegant maybe use reorder when dplyr1.0.0

  col_order <- c(
    "date",
    "state",
    "region_cod",
    "region",
    "lat",
    "long",
    "perc_imm",
    "perc_imm65",
    "cmr",
    "total_cases",
    "deaths",
    "tests",
    "hospitalized_with_symptoms",
    "intensive_care_unit",
    "total_hospitalized",
    "home_quarantine",
    "total_positives",
    "change_positives",
    "new_positives",
    "recovered_released",
    "people_tested",
    "p_house", "pop_tot", "area_km2", "pop_km2",
    "female_65m", "male_65m"
  )

  # inner join the rest
  dat2 <- plyr::join_all(list(dat1[, col_order], chronic_it, cancer_it, smoking_it, bweight_it, firstaid_it, hospbed_it, netinc_it, pm2.5_it), by = "region", type = "inner")

  # make cancer and health as percentage
  suppressWarnings(
    all_dat <- dat2 %>%
      dplyr::mutate_at(vars(.data$chronic_osteo:.data$bweight_obese), list(~ (. / .data$pop_tot * 100))) %>%
      dplyr::mutate(date = as.Date(.data$date, "%Y-%m-%d"))
  )


  # all data but phouse are as percentage so we remove the perc_ from names
  names(all_dat) <- stringr::str_remove(names(all_dat), "perc_")

  all_dat
}

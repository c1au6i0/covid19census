#' get COVID-19 updated cases
#'
#' extracts and translates time series form the git repository of the \href{https://github.com/pcm-dpc/COVID-19}{protezione civile}
#'
#' @return a tibble with following columns:
#' \describe{
#'      \item{\strong{date}}{date of data}
#'      \item{\strong{state}}{state}
#'      \item{\strong{region_code}}{region abbreviation}
#'      \item{\strong{region}}{full name of region}
#'      \item{\strong{lat}}{lat}
#'      \item{\strong{long}}{long}
#'      \item{\strong{COVID19_var}}{
#'          \itemize{
#'             \item cmr: case-mortality rate for that region and that date (deaths/total_cases * 100)
#'             \item hospitalized_with_symptoms: number of people hospitalized with symptoms
#'             \item intensive_care_unit: number of people in intensive care units
#'             \item home_quarantine: number of people COVID-19 positive in home quarantine
#'             \item deaths: number of deaths
#'             \item total_cases: number of COVID-19 positive cases detected
#'             \item tests: number of tests performed
#'          }
#'      }
#'      \item{\strong{value}}{value relative to COVID19_var}
#'
#' }
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#' @import vroom
#' @export
getit_covid <- function() {
  dat <- vroom(
    file = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv",
    col_types = cols(
      data = col_datetime(format = ""),
      stato = col_character(),
      codice_regione = col_double(),
      denominazione_regione = col_character(),
      lat = col_double(),
      long = col_double(),
      ricoverati_con_sintomi = col_double(),
      terapia_intensiva = col_double(),
      totale_ospedalizzati = col_double(),
      isolamento_domiciliare = col_double(),
      totale_positivi = col_double(),
      variazione_totale_positivi = col_double(),
      nuovi_positivi = col_double(),
      dimessi_guariti = col_double(),
      deceduti = col_double(),
      totale_casi = col_double(),
      tamponi = col_double(),
      note_it = col_character(),
      note_en = col_character()
    )
  ) %>%
    dplyr::rename(region = .data$denominazione_regione) %>%
    dplyr::mutate(region = stringr::str_replace(.data$region, "-", " ")) %>%
    dplyr::select(-.data$totale_positivi, -.data$variazione_totale_positivi, -.data$nuovi_positivi) %>%
    dplyr::rename(
      date = .data$data,
      state = .data$stato,
      region_cod = .data$codice_regione,
      hospitalized_with_symptoms = .data$ricoverati_con_sintomi,
      intensive_care_unit = .data$terapia_intensiva,
      total_hospitalized = .data$totale_ospedalizzati,
      home_quarantine = .data$isolamento_domiciliare,
      deaths = .data$deceduti,
      tests = .data$tamponi,
      recovered_released = .data$dimessi_guariti,
      total_cases = .data$totale_casi
    ) %>%
    dplyr::mutate(
      cmr = .data$deaths / .data$total_cases * 100
    ) %>%
    tidyr::pivot_longer(cols = c("cmr", "hospitalized_with_symptoms", "intensive_care_unit", "total_hospitalized", "home_quarantine", "deaths", "total_cases", "recovered_released", "tests"), names_to = "COVID19_var", values_to = "value")


  message(paste0("Data till ", max(dat$date), " successfully extracted!"))

  dat
}


#' get COVID-19 cases and other statistics
#'
#' extracts and translates time series form the git repository of the \href{https://github.com/pcm-dpc/COVID-19}{protezione civile} and
#' combines them with other statistics related to italian population
#'
#' @return a tibble with following columns:
#' \describe{
#'      \item{date}{date of data}
#'      \item{state}{state}
#'      \item{region_code}{region abbreviation}
#'      \item{region}{full name of region}
#'      \item{lat}{lat}
#'      \item{long}{long}
#'      \item{COVID19_var}{
#'          \itemize{
#'             \item cmr: case-mortality rate for that region and that date (deaths/total_cases * 100)
#'             \item hospitalized_with_symptoms: number of people hospitalized with symptoms that day
#'             \item intensive_care_unit: number of people in intensive care units that day
#'             \item home_quarantine: number of people COVID-19 positive in home quarantine
#'             \item deaths: number of deaths
#'             \item total_cases: number of COVID-19 positive cases detected
#'             \item recovered_released: recovered/released from hospital (\href{https://www.infodata.ilsole24ore.com/2020/04/10/la-regione-lombardia-sovrastima-guariti-covid-19-laccusa-della-fondazione-gimbe/}{caveates})
#'             \item tests: number of tests performed
#'          }
#'      }
#'      \item{value}{value relative to COVID19_var}
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
#' \href{https://annuario.isprambiente.it/pon/basic/14}{Istituto Superiore Per La protexione Ambientale}.
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
  cmr_it <- get_covid()

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
    "date", "state", "region_cod", "region", "lat", "long",
    "perc_imm", "perc_imm65", "COVID19_var", "value", "p_house", "pop_tot", "area_km2", "pop_km2",
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

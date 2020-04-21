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
get_covid <- function() {
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

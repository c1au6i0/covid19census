#' influenza vaccination coverage, general population, time series
#'
#' Influenza vaccination coverage in Italy in the \strong{general population} from 1999 to 2019. Data are percent of region population
#' @docType data
#' @source \href{http://www.salute.gov.it/imgs/C_17_tavole_19_allegati_iitemAllegati_0_fileAllegati_itemFile_3_file.pdf}{Ministero della Salute}
#' @usage data(it_fl)
"it_fl"

#' influenza vaccination coverage 2019
#'
#' Influenza vaccination coverage in Italy for 2018-2019 season for population age 65 or more from 1999 to 2019. Data are percent of region population
#' @docType data
#' @source \href{http://www.salute.gov.it/imgs/C_17_tavole_19_allegati_iitemAllegati_0_fileAllegati_itemFile_3_file.pdf}{Ministero della Salute}
#' @usage data(it_fl65)
#' @return a tibble with following columns:
#' \describe{
#'      \item{region}{region}
#'      \item{perc_imm65}{percent of population age 65 or more that received influenza vaccination}
#'      \item{perc}{percent of general population that received influenza vaccination}
#'      }
"it_fl65"

#' body-mass index
#'
#' Body mass index in regions of Italy, in the general population.
#' Data were collected in 2018 and indicate absolute number of people underweight, normalweight, overweight or obese.
#' @docType data
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=0058000&refresh=true&language=EN}{methodology}
#' @usage data(it_bweight)
"it_bweight"

#' cancer patients
#'
#' Number of cancer patients in each region by type.
#' Data were collected in 2016 and indicate absolute number of people diagnosed with cancer. Data for P.A. Trento and
#' P.A. Bolzano are missing (but we have Trentino Alto Adige)
#' @docType data
#' @source \href{http://www.registri-tumori.it/PDF/AIOM2016/I_numeri_del_cancro_2016.pdf}{Istituto Superiore Sanita'}
#' @usage data(it_cancer)
#' @return a tibble
"it_cancer"

#' smoking status
#'
#' Number of people age 14 years and over that self-refer as smoker, non smoker, or past smoker by region and type.
#' Data were collected in 2018 and are absolute number of people.
#' @docType data
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=0058000&refresh=true&language=EN}{methodology}
#' @usage data(it_smoking)
#' @return a tibble
"it_smoking"

#' chronic conditions
#'
#' Number of people suffering of chronic conditions by region and type.
#' Data were collected in 2018 and indicate absolute number of people.
#' @docType data
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=0058000&refresh=true&language=EN}{methodology}
#' @usage data(it_chronic)
#' @return a tibble
"it_chronic"


#' Percent of population by region, sex and age. Data were collected in 2019 and indicate absolute number of people. Long format,
#  age by year.
#' @docType data
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=0019900&refresh=true&language=EN}{methodology}
#' The Istituto Superiore Sanita' provides biweekly info regarding the mortality in different age groups fro patients positive for COVID-19 in this
#' \href{https://www.epicentro.iss.it/coronavirus/sars-cov-2-decessi-italia}{link}
#' @usage data(it_dem)
#' @return a tibble
"it_dem"

#' regions area
#'
#' Area in square meters of each region. Used to calculate density per region. Scraped from old good wikipedia.
#' @docType data
#' @usage data(it_regions)
#' @return a tibble
"it_regions"

#' housing crowding
#'
#' Household crowding index from 2014 to 2018 in each region
#' @docType data
#' @usage data(it_house)
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=5000170&refresh=true&language=EN}{methodology}
#' @return a tibble in which `phouse` is number of components of household per square meter
"it_house"


#' first aid
#'
#' Number of people using first aid or medical guard in 3 months preceding the survey. Collected in 2018
#' @docType data
#' @usage data(it_firstaid)
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/lang.do?language=UK}{methodology}
#' @return a tibble
"it_firstaid"


#' hospital beds
#'
#' Inpatient hospital beds per 1000 people. Collected in 2017
#' @docType data
#' @usage data(it_hospbed)
#' @source \href{http://www.dati.salute.gov.it/}{Ministero della Salute}
#' @details \href{http://www.dati.salute.gov.it/dati/dettaglioDataset.jsp?menu=dati&idPag=18}{methodology}
#' @return a tibble in wide format in which `bed_acute`, `bed_long`, `bed_rehab`, `bed_tot` refers to acute care, long term care,
#' rehabilitation and total beds, respectivelly
"it_hospbed"

#' Net income
#'
#' Median net annual households income (including imputed rents, in euros). Collected in 2017
#' @docType data
#' @usage data(it_netinc)
#' @source \href{http://dati.istat.it/?lang=en}{ISTAT}
#' @details \href{http://siqual.istat.it/SIQual/visualizza.do?id=5000170&refresh=true&language=EN}{methodology}
#' @return a tibble
"it_netinc"


#' particulate 2.5 italy
#'
#' Emission of pm2.5 in tons per region from 1990 to 2017
#' @docType data
#' @usage data("it_pm2.5")
#' @source \href{https://annuario.isprambiente.it/pon/basic/14}{Istituto Superiore Per La protezione Ambientale}
#' @details \href{https://annuario.isprambiente.it/pon/basic/14}{methodology}
#' @return a tibble
"it_pm2.5"

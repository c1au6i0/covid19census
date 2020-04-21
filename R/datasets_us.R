#' influenza vaccination 65 or older
#'
#' Percentage of fee-for-service (FFS) Medicare enrollees that had an annual flu vaccination. Collected in 2017.
#' @docType data
#' @source \href{https://data.cms.gov/mapping-medicare-disparities}{Data.CMS.gov}
#' @details \href{https://www.cms.gov/About-CMS/Agency-Information/OMH/Downloads/Mapping-Technical-Documentation.pdf}{Center for Medicare and Medicaid Services} and NORC at the University of Chicago.
#' @return  tibble wotj `fl_65` indicating the percentage of fee-for-service (FFS) Medicare enrollees that had an annual flu vaccination
#' @usage data(fl65_us)
"fl65_us"
#' hospital beds
#'
#' beds of each hospital by county.
#' @docType data
#' @source \href{https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/data?page=18}{Homeland Infrastructure Foundation-Level Data}
#' @return  a tibble
#' @usage data(hospbeds_us)
"hospbeds_us"



#' household composition
#'
#' Several metrics regarding household composition from the American Community Survey of 2018
#' @docType data
#' @source \href{https://data.census.gov/cedsci/table?q=United%20States}{American Community Survey tables}
#' @details \href{https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2018_ACSSubjectDefinitions.pdf?#}{Subject Definitions}
#' @return  a tibble
#' @usage data(acm_househ_us)
"acm_househ_us"

#' age and sex
#'
#' Sex and age composition of the county population from the American Community Survey of 2018
#' @docType data
#' @source \href{https://data.census.gov/cedsci/table?q=United%20States}{American Community Survey tables}
#' @return  a tibble
#' @usage data(age_sex_us)
"age_sex_us"

#' poverty
#'
#' Household living below the poverty level, divided by age and race and calculate as absolute value or percentage. American Community Survey of 2018
#' @docType data
#' @source \href{https://data.census.gov/cedsci/table?q=United%20States}{American Community Survey tables}
#' @details \href{https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2018_ACSSubjectDefinitions.pdf?#}{Subject Definitions of the American Community Survey}
#' @return  a tibble
#' @usage data(poverty_us)
"poverty_us"


#' mapping medicare disparities
#'
#' Prevalence of many  medical and chronic conditions, 2017. From relative documentation listed below: "Prevalence rates are calculated by searching for certain diagnosis codes in Medicare
#' beneficiaries’ claims. The prevalence rate of a condition for a specific sub-population
#' (e.g., all beneficiaries in a county) is the proportion of beneficiaries who are found to have the condition. The admission rate by admission type is the frequency of a specific type of inpatient admission
#' per 1,000 inpatient admissions in a year."
#' @docType data
#' @source \href{https://data.cms.gov/mapping-medicare-disparities}{Mapping Medicare Disparities}
#' @return  a tibble
#' @details Details regarding the use of the webtool can be found in the relative
#' \href{https://www.cms.gov/About-CMS/Agency-Information/OMH/Downloads/Mapping-Technical-Documentation.pdf}{documentation}. It includes prevalence of
#' \itemize{
#'   \item Alzheimer
#'   \item chronic kidney
#'   \item obesity,
#'   \item depression
#'   \item obstructive pulmonary
#'   \item disease
#'   \item arthritis
#'   \item diabetes
#'   \item osteoporosis
#'   \item asthma
#'   \item atrial
#'   \item fibrillation
#'   \item ischemic hearth,
#'   \item myocardial infarction
#'   \item hypertension
#'   \item several type of cancer
#'   \item emergency,  medical admissions, annual visits
#'   \item pneumoccocal vaccine
#'   \item tabacco use
#' }
#' @usage data(mmd_us)
#' @seealso \code{\link{getus_all}} for more details regarding the variables
"mmd_us"

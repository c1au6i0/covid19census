
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covid19census

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The package `covid19census` provides functions to extract COVID-19
cases, deaths, hospitalizations and test of U.S. and Italy at the county
and regional level, respectively, and then combine them with other
population metric (age, sex, prevalence of chronic conditions, income
indexes, access to health services and many others.)

## Installation

Download the package in a local folder and the run the following code.

``` r
devtools::install_local("path_to_package")
```

Alternatively, you can install it directly from github.

``` r
# the repo at the moment private so you need to be authorized 
# don't share the token
library(devtools)

devtools::install_github("c1au6i0/covid19census", auth_token = "355580fb57d57b58228b4617c14c3f8234741715")
```

## Usage

A dataset that includes COVID-19 data and **all the other demographic
variables** can be obtained executing `getus_all` (get-U.S-all) and
`getit_all` (get-Italy-all)

``` r
library(covid19census)

# to retrive u.s data
all_us <- getus_all()

# to retrive italy data
all_it <- getit_all()
```

## U.S. Datasets and Sources

The function `get all` executes

`get covid` and joins the resulting `tibble` with datasets from the
[Homeland Infrastructure
Foundation](https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/data?page=18),
the [Census](https://data.census.gov/cedsci/table?q=United%20States),
[Mapping Medicare
Disparities](https://data.cms.gov/mapping-medicare-disparities), and
[activity
indexes](https://github.com/COVIDExposureIndices/COVIDExposureIndices)
calculated by Victor Couture, Jonathan Dingel, Allison Green, Jessie
Handbury, and Kevin Williams based on smartphone movement data provided
by PlaceIQ.

In particular, this is a list of datasets included:

  - `act_ind`: county-level device exposure index (DEX), an index of
    activity.

  - `acm_househ`: several metric regarding household composition (2018).

  - `age_sex`: age and sex distribution (2018).

  - `fl65`: percentage of fee-for-service (FFS) Medicare enrollees that
    had an annual flu vaccination (2017)

  - `hospbeds`: total hospital beds in each county (2019).

  - `mmd`: data of 2017 regarding the prevalence found in medicare
    beneficiaries of
    
      - many medical and chronic conditions (Alzheimer, chronic kidney,
        obesity, depression, obstructive pulmonary, disease, arthritis,
        diabetes, osteoporosis, asthma, atrial fibrillation, ischemic
        hearth, myocardial infarction, hypertension).
      - several type of cancer.
      - emergency, medical admissions and annual visits.
      - pneumoccocal vaccine.
      - tabacco use.

*Note that* info for some counties are missing in some datasets. For
example, `hospbeds` contains info on 2545 counties, `fl65` has 3224
counties, whereas datasets from the Census have 3220 counties.

## Italy: Datasets and Sources

The function `get_all` executes `get_covid` and aggregates the resulting
`tibble` with some of the datasets below and, normalizes some of the
variables:

  - `act_it`: Change in retail and recreation activity as reported by
    google \[not joined with `get_all()` but accessible\].
  - `bweight_it`: Body mass index in regions of Italy, in the general
    population.
  - `cancer_it`: Number of cancer patients in each region by type.
  - `chronic_it`: Number of people suffering of chronic conditions by
    region and type.
  - `dem_it`: Number of people by region, sex, age.
  - `firstaid_it`: Number of people using first aid or medical guard (3
    months).
  - `fl_it`: Influenza vaccination coverage in Italy for 2009-2019
    season for general population and aged 65 and more.
  - `fl_it_2019`: Influenza vaccination coverage in Italy for 2018-2019
    season for general population and 65 and more.
  - `hospbed_it`: Inpatient hospital beds per 1000 people.
  - `house_it`: household crowding index from 2014 to 2018 in each
    region.
  - `netinc_it`: median net annual households income (including imputed
    rents, in euros).
  - `pm2.5_it`: emission of particulate 2.5 in tons per region.
  - `regions_area`: Area in square meters of each region. Used to
    calculate density per region.
  - `smoking_it`: Number of people aged 14 years and over that
    self-refered as smoker, non smoker, or past smoker by region.

## Raw Data and other scripts

Raw data and the code used to import it can be found in the
[data-raw](https://github.com/c1au6i0/convid19census/tree/master/data-raw)
folder.

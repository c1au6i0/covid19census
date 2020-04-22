library(stringr)

# getit_covid --------------------
test_that("getit_covid executes", {
  expect_error(getit_covid(), NA)
})

x <- getit_covid()

# we take only the last year
house_it <- house_it %>%
  dplyr::filter(.data$year == 2018) %>%
  dplyr::select(.data$region, .data$phouse) %>%
  dplyr::rename("p_house" = "phouse")

# check the datasets that we are merging-----
t_data <- lapply(list(
  x,
  cancer_it,
  chronic_it,
  dem_65bin_fm,
  bweight_it,
  firstaid_it,
  hospbed_it,
  house_it,
  netinc_it,
  pm2.5_it,
  regions_area,
  smoking_it
), function(x) {
  unique(x$region) %in% unique(dem_65bin_fm$region)
})


test_that("all datasets and function have same regions", {
  expect_equal(sum(unlist(lapply(t_data, sum))), 252)
})


test_that("get_all executes", {
  expect_error(getit_all(), NA)
})

y <- getit_all()

test_that("get_all returns regions_21", {
  expect_equal(length(unique(y$region)), 21)
})


test_that("sum smoking is < 100 ", {
  expect_equal(
    sum(!unique(
      apply(
        y[, names(y)[str_detect(names(y), "smoking")]],
        1, sum
      )
    ) <= 100),
    0
  )
})


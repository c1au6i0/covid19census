library(dplyr)

test_that("get_all executes", {
  expect_error(getus_all(), NA)
})

test_that("get_covid executes", {
  expect_error(getus_covid(), NA)
})

y <- getus_all()

x <- getus_covid()

test_that("get_all and get_covid have same fips", {
  expect_equal(length(unique(y$fips)), length(unique(x$fips)))
})


###################################

test_that("get_dex executes", {
  expect_error(getus_dex(), NA)
})

##################################


expected_states <- structure(list(state = c(
  "Alaska", "Alabama", "Arizona", "Arkansas",
  "California", "Colorado", "Connecticut", "District of Columbia",
  "Delaware", "Florida", "Georgia", "Hawaii", "Iowa", "Idaho",
  "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts",
  "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi",
  "Montana", "North Carolina", "North Dakota", "Nebraska", "New Hampshire",
  "New Jersey", "New Mexico", "Nevada", "New York", "Ohio", "Oklahoma",
  "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
  "Tennessee", "Texas", "Utah", "Virginia", "Vermont", "Washington",
  "Wisconsin", "West Virginia", "Wyomin"
), abbr = c(
  "AK", "AL",
  "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA",
  "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN",
  "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY",
  "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA",
  "VT", "WA", "WI", "WV", "WY"
)), class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -51L))

test_that("get_test executes", {
  expect_error(getus_tests(), NA)
})

tests <- getus_tests() %>%
  select(state, abbr) %>%
  distinct()

test_that("getus_tests states abbr ", {
  expect_equal(tests, expected_states)
})

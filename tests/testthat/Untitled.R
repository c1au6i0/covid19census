library(dplyr)

y_nyt <- getus_all(repo = "nyt")
y_jhu <- getus_all(repo = "jhu")
#
x_nyt <- getus_covid(repo = "nyt")
x_jhu <- getus_covid(repo = "jhu")

test_that("get_all_jhu and get_covid have same fips", {
  expect_equal(length(unique(y_jhu$fips)), length(unique(x_jhu$fips)))
})

test_that("get_all_nyc and get_covid have same fips", {
  expect_equal(length(unique(y_nyt$fips)), length(unique(x_nyt$fips)))
})

###################################

test_that("get_dex executes", {
  expect_error(getus_dex(), NA)
})

##################################

#
# expected_states <- structure(list(state = c(
#   "Alaska", "Alabama", "Arizona", "Arkansas",
#   "California", "Colorado", "Connecticut", "District of Columbia",
#   "Delaware", "Florida", "Georgia", "Hawaii", "Iowa", "Idaho",
#   "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts",
#   "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi",
#   "Montana", "North Carolina", "North Dakota", "Nebraska", "New Hampshire",
#   "New Jersey", "New Mexico", "Nevada", "New York", "Ohio", "Oklahoma",
#   "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
#   "Tennessee", "Texas", "Utah", "Virginia", "Vermont", "Washington",
#   "Wisconsin", "West Virginia", "Wyoming"
# ), abbr = c(
#   "AK", "AL",
#   "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA",
#   "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN",
#   "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY",
#   "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA",
#   "VT", "WA", "WI", "WV", "WY"
# )), class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -51L))
#
# test_that("getus_test executes", {
#   expect_error(getus_tests(), NA)
# })
#
# tests <- getus_tests() %>%
#   select(state, abbr) %>%
#   distinct()
#
# test_that("getus_tests states abbr ", {
#   expect_equal(tests, expected_states)
# })

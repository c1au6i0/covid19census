# library(dplyr)
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
# )), class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -51L)) %>%
#   arrange(state)
#
#
# y_nyt <- getus_all(repo = "nyt")
#
# x_nyt <- getus_covid(repo = "nyt")
#
#
# test_that("get_all and get_covid have same fips", {
#   expect_equal(length(unique(y_nyt$fips)), length(unique(x_nyt$fips)))
# })
#
# test_that("getus_jhu states abbr ", {
#   expect_equal(sort(unique(y_nyt$state)), expected_states$state)
# })

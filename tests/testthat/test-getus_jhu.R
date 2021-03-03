# library(dplyr)
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
# )), class = c("data.frame"), row.names = c(NA, -51L))
#
# expected_states <- sort(expected_states$state)
# #
# #
# # y_jhu <- getus_all()
# #
# #
# x_jhu <- getus_covid(repo = "jhu")
# # #
# # #
# # # test_that("get_all_jhu and get_covid have same fips", {
# # #   expect_equal(length(unique(y_jhu$fips)), length(unique(x_jhu$fips)))
# # # })
# # # #
# #
# test_that("getus_jhu states abbr ", {
#   expect_equal(sort(unique(x_jhu$state)), expected_states )
# })

# # ##################################

# test_that("getus_test executes", {
#   expect_error(getus_tests(), NA)
# })
#
# tests <- getus_tests() %>%
#   select(state, abbr) %>%
#   distinct() %>%
#   arrange(state) %>%
#   pull(state)
#
# test_that("getus_tests states abbr ", {
#     expect_equal(tests, expected_states)
# })

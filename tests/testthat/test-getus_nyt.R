library(dplyr)

y_nyt <- getus_all(repo = "nyt")

x_nyt <- getus_covid(repo = "nyt")


test_that("get_all and get_covid have same fips", {
  expect_equal(length(unique(y_nyt$fips)), length(unique(x_nyt$fips)))
})


% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilis.R
\name{recode_col}
\alias{recode_col}
\title{recode column.}
\usage{
recode_col(x, repl)
}
\arguments{
\item{x}{vector to recode.}

\item{repl}{vector containing unique codes.}
}
\value{
a vector of same length of x.
}
\description{
recode_col recodes a vector with codes provided in another vector. The unique values of
the 2 vectors need to be of same length. Codes are assigned matching unique values by position. Used internally.
}
\keyword{internal}

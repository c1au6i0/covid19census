#' recode column.
#'
#' recode_col recodes a vector with codes provided in another vector. The unique values of
#' the 2 vectors need to be of same length. Codes are assigned matching unique values by position. Used internally.
#' @param x vectore to recode.
#' @param repl vector containing unique codes.
#' @return a vector of same length of x.
recode_col <- function(x, repl) {
  intv_id <- as.character(unique(x))
  id_recode <- repl[seq_along(intv_id)]
  newnames <- stats::setNames(id_recode, intv_id)
  as.vector(newnames[x])
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_split_table_keys.R
\name{.get_all_split_keys}
\alias{.get_all_split_keys}
\title{Retrieve the customer table keys which can be used to split table on.}
\usage{
.get_all_split_keys(
  tbls_to_split,
  customer_tables,
  split_key_field = "display_name"
)
}
\arguments{
\item{tbls_to_split}{character vector corresponding to a table within \code{customer_tables}
from which the keys will be obtained.}

\item{customer_tables}{a list of data.frames where each element corresponds to a
specific customer table, based on their field list information}

\item{split_key_field}{the filed within a customer table from which the keys will be retrieved.}
}
\value{
character vector of keys which will be used to split a dictionary table
}
\description{
Retrieve the customer table keys which can be used to split table on.
}

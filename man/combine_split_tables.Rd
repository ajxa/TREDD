% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/combine_split_tables.R
\name{combine_split_tables}
\alias{combine_split_tables}
\title{Combines any split tables back into one table}
\usage{
combine_split_tables(dictionary_tables, split_lookups)
}
\arguments{
\item{dictionary_tables}{a list of data.frames where each element corresponds
to a specific data dictionary table}

\item{split_lookups}{list of split lookup values generated by \code{get_all_split_keys}
which will be split}
}
\value{
a list of dictionary tables
}
\description{
For a given data dictionary table this function will combine any
tables that were previously split, using the split_lookups
}

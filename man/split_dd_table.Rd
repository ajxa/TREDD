% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/split_and_combine_tables.R
\name{split_dd_table}
\alias{split_dd_table}
\title{Split a dictionary table into many smaller tables}
\usage{
split_dd_table(dictionary_tables, split_table_name, customer_tables, dataset)
}
\arguments{
\item{dictionary_tables}{a list of data.frames containing the table to be split into multiple tables}

\item{split_table_name}{a character vector for the dictionary table to be split}

\item{customer_tables}{a list of data.frames containing the fields which will
make up the each of the split tables}

\item{dataset}{a character vector of the dataset to be split (currently this is only the mental health dataset)}
}
\value{
a list of data.frames or NULL
}
\description{
Split a dictionary table into many smaller tables
}

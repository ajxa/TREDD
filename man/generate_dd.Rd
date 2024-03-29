% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_dd.R
\name{generate_dd}
\alias{generate_dd}
\title{Generate a formatted data dictionary}
\usage{
generate_dd(
  customer_name,
  customer_fields_path,
  unformatted_dict_path,
  output_hometab_filepath,
  output_filepath = getwd(),
  overwrite_output = TRUE,
  tell_fortune = FALSE
)
}
\arguments{
\item{customer_name}{a character vector corresponding to one of the approved users}

\item{customer_fields_path}{a file path corresponding to a csv file which lists
all the fields present in the selected customers agreement}

\item{unformatted_dict_path}{a file path to an excel workbook containing one unformatted dictionary table per sheet}

\item{output_hometab_filepath}{the file path to the output home and reference tab}

\item{output_filepath}{the file path where you wish to save formatted excel workbook}

\item{overwrite_output}{logical should the outputfile be overwritten, if it exists (default:TRUE)}

\item{tell_fortune}{logical should a R-based fortune be printed to the console (default:FALSE)}
}
\value{
A list of length 4: unformatted_dd = a list of the unformatted dictionary tables before cleaning;
customer_info = a list of 3 comprising customer information and agreement specific fields;
cleaned_dd = a list of cleaned cleaned dictionary tables;checks = a list of checks
completed against each of the cleaned dictionary tables.
}
\description{
Generate a formatted data dictionary
}

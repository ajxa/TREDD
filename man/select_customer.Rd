% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/select_customer.R
\name{select_customer}
\alias{select_customer}
\title{Select a customer agreement}
\usage{
select_customer(
  customer_name,
  customer_fields,
  customer_list = customer_lookup
)
}
\arguments{
\item{customer_name}{Character vector corresponding to one of the approved users}

\item{customer_fields}{file path corresponding to a csv file which lists
all the fields present in the selected customers agreement}

\item{customer_list}{Lookup list of current customers and their specific agreement ids.
This list is apart of the package and can be accessed by the user, but
can also easily be modied by the user to include new customers.}
}
\value{
list of length 3 comprising:

\if{html}{\out{<div class="sourceCode">}}\preformatted{    customer_name = customer's name
    agreement_id = customer's agreement id
    fields = all fields present in the customer's agreement
}\if{html}{\out{</div>}}
}
\description{
For a given customer returns the customers name, agreement id and a list of the
fields present in their data sharing agreement
}

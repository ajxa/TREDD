# Lookup of expected variables for fields, variable_types and data_types
expected = list(

    fields = c("path", "table", "display_name", "display_name_label",
               "field_description", "variable_type", "data_type", "units",
               "values", "notes", "links" ),

    variable_types = c("Categorical", "Continuous"),

    data_types= c("String", "Character", "Integer", "Float", "Boolean", "Date",
                  "Time", "Datetime", "Timestamp")
)


# Lookup of tables which need to split up into multiple tables
split_tables_lookup = list(
    nat_cancer_reg = c("^cancer_?reg", "^national_?cancer_?reg"),
    rapid_cancer_reg = c("^(proxy|rapid)(_cancer)?_?reg", "^(proxy|rapid)(_cancer)?_?reg"),
    sact = c("^sact","^sact"),
    rtds = c("^rtds","^rtds"),
    rdc = c("^rdc", "^rdc"),
    mental_health = c("(?i)^mhs","(?i)^mhs"),
    maternity = c("(?i)^msds", "(?i)^msds-?v2")
)

split_tables_lookup = lapply(split_tables_lookup, \(x){
    names(x) = c("customer", "dd")
    return(x)
})



# Customer list with agreement ids
customer_lookup = list(
    bhf = "391419_j3w9t",
    dhsc = "484452_h8s1l",
    datacan = "402417_n9z5w",
    ncie = "610798_n0g8z",
    az = "445543_w0d4n",
    nhse = "411785_z6x7m",
    evidera = "561357_x0f3n"
)


usethis::use_data(expected, split_tables_lookup, customer_lookup,
                  overwrite = TRUE, internal = TRUE)

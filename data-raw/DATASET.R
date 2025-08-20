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
    mental_health = c("(?i)^mhsds_v6","(?i)^mhsds_v6"),
    maternity_v2 = c("(?i)^msds_v2", "(?i)^msds_?v2")
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
    nice = "610798_n0g8z",
    az = "445543_w0d4n",
    nhse = "411785_z6x7m",
    evidera = "561357_x0f3n",
    neohealth = "692602_q6p4f",
    oxford = "714765_g1p5s",
    newcastle = "726177_r0h8v",
    birmingham = "717428_m3s8h",
    manchester = "739822_q8r6y",
    hull = "682532_b4b5l",
    lcp = "683842_m6s8n",
    ucl = "727610_s2v3n",
    oxfordsaid = "712819_x8g2j",
    eviderasanofi = "717485_f8l6h",
    lancaster = "690385_r5d4b",
    methods = "744993_z8k2k",
    queenmary = "749612_d9m1v",
    harveywalsh = "596002_v3n9j",
    neqos = "10328_s0h5j",
    imperialesc = "754175_w2z4t",
    imperialpelvic = "776195_h7w4d",
    londontropical = "779433_q9r8n"
)


usethis::use_data(expected, split_tables_lookup, customer_lookup,
                  overwrite = TRUE, internal = TRUE)

#' Select a customer agreement
#'
#' For a given customer returns the customers name, agreement id and a list of the
#' fields present in their data sharing agreement
#'
#' @param customer_name Character vector corresponding to one of the approved users
#' @param customer_fields file path corresponding to a csv file which lists
#'                        all the fields present in the selected customers agreement
#' @return list of length 3 comprising:
#'
#'         user = customer's name
#'         agreement_id = customer's agreement id
#'         fields = all fields present in the customer's agreement
#' @export
select_customer <- function(customer_name, customer_fields){

    if(missing(customer_name)) stop("customer_name is missing!")
    if(missing(customer_fields)) stop("customer_fields_path is missing!")
    if(tools::file_ext(customer_fields) != "csv") stop("customer_fields is not a csv")


    matched_id <-  match.arg(tolower(customer_name),
                             choices = c("bhf","dhsc","datacan",
                                         "nice","az", "nhsei", "evidera"),
                             several.ok = FALSE)

    agreement_id <- switch(matched_id,
                           "bhf" = "391419_j3w9t",
                           "dhsc" = "484452_h8s1l",
                           "datacan" = "402417_n9z5w",
                           "nice" = "610798_n0g8z",
                           "az" = "445543_w0d4n",
                           "nhsei" = "411785_z6x7m",
                           "evidera" = "561357_x0f3n")


    environment_fields <- readr::read_csv(customer_fields,
                                          col_types = readr::cols())

    environment_fields <- clean_environment_fields(environment_fields)


    cli::cat_line(outputheader("Customer information"))

    cli::cat_line(cli::symbol$tick,
                  cli::col_grey(" Set Customer Name:\t"),
                  cli::col_green({toupper(matched_id)}),
                  col = "green")


    cli::cat_line(cli::symbol$tick,
                  cli::col_grey(" Set Agreement ID:\t"),
                  cli::col_green({toupper(agreement_id)}),
                  col = "green")


    cli::cat_line(cli::col_yellow(cli::symbol$info)," ",
                  cli::col_grey("Customer tables:\t"),
                  cli::col_br_blue({length(environment_fields)})
                  )

    return(

        list(user = matched_id,
            agreement_id = agreement_id,
            fields = environment_fields)

        )

}




#' Clean environment fields
#'
#' This function cleans the table of fields present in a customer's agreement
#'
#' @param fields a data.frame of fields present in a customer's agreement
#' @return list of fields present in a customers agreement split by table name
#' @importFrom rlang .data
clean_environment_fields <- function(fields){

    if(!inherits(fields, "data.frame")) stop("fields is not a data.frame")

    if(!any(colnames(fields) %in% "path")) stop("path not detected in fields")

    fields %>%
        tidyr::separate(col = "path", into = c("database","table"),
                        sep = "\\.", remove = TRUE) %>%
        dplyr::mutate("table_stripped" = stringr::str_remove_all(table, paste0("_",unique(.data$database)))) %>%
        dplyr::relocate("table_stripped", .before = .data$database) %>%
        dplyr::mutate(dplyr::across("table_stripped", ~stringr::str_replace_all(.x, "_\\d{4}$", "_{fyear}"))) %>%
        dplyr::mutate(dplyr::across("table_stripped", ~stringr::str_replace_all(.x, "_\\[fyear\\]$", "_{fyear}"))) %>%
        split(~table_stripped)
}

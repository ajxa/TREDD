#' Select a customer agreement
#'
#' For a given customer returns the customers name, agreement id and a list of the
#' fields present in their data sharing agreement
#'
#' @param customer_name Character vector corresponding to one of the approved users
#' @param customer_fields file path corresponding to a csv file which lists
#'                        all the fields present in the selected customers agreement
#' @param customer_lookup Data.frame lookup of customers and their specific agreement ids
#' @return list of length 3 comprising:
#'
#'         customer_name = customer's name
#'         agreement_id = customer's agreement id
#'         fields = all fields present in the customer's agreement
#' @export
select_customer <- function(customer_name, customer_fields, customer_list=customer_lookup){

    if(length(customer_name) > 1) stop("customer_name must be a single string")
    if(missing(customer_name)) stop("customer_name is missing!")
    if(missing(customer_fields)) stop("customer_fields_path is missing!")
    if(tools::file_ext(customer_fields) != "csv") stop("customer_fields is not a csv")

    matched_id = tolower(customer_name)
    found_customer = matched_id %in% names(customer_list)

    if(length(found_customer) == 0) stop("Customer not found in the supplied lookup table")
    if(length(found_customer) > 1) stop("Multiple customers found in the supplied lookup table")

    agreement_id = unlist(customer_list[matched_id], use.names = FALSE)

    environment_fields = readr::read_csv(customer_fields, col_types = readr::cols())

    environment_fields = clean_environment_fields(environment_fields)

    # Standardise long excel field names if they are present
    cwt_present = grep("(?i)^cwt_?", names(environment_fields))
    if(length(cwt_present) == 1) names(environment_fields)[cwt_present] = "cancer_wait_times"

    cli::cat_line(cli::col_grey("Customer Name:\t\t"),
                  cli::col_green({toupper(matched_id)}))


    cli::cat_line(cli::col_grey("Customer Agreement ID:\t"),
                  cli::col_green({toupper(agreement_id)}))


    cli::cat_line(cli::col_grey("Customer Tables:\t"),
                  cli::col_green({length(environment_fields)})
                  )

    return(

        list(
          customer_name = matched_id,
          agreement_id = agreement_id,
          fields = environment_fields
        )

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
        dplyr::mutate("table_stripped" = stringr::str_remove_all(table, paste0("_",unique(database)))) %>%
        dplyr::relocate("table_stripped", .before = database) %>%
        dplyr::mutate(dplyr::across("table_stripped", ~stringr::str_replace_all(.x, "_\\d{4}$", "_{fyear}"))) %>%
        dplyr::mutate(dplyr::across("table_stripped", ~stringr::str_replace_all(.x, "_\\[fyear\\]$", "_{fyear}"))) %>%
        split(~table_stripped)

}

#' Search a list of customer tables using a split table lookup list and identify
#' if any tables that require splitting into multiple tables are present. The
#' default split table lookup list is defined in `split_tables_lookup`, but can
#' be editing and overwritten by the user and then passed to the function.
#' @param dictionary_tables a list of data.frames where each element corresponds
#'                          to a specific data dictionary table found within the
#'                          unformatted data dictionary excel file.
#' @param customer_tables a list of data.frames where each element corresponds to a
#'                        specific table that is provisioned for a customer. This table
#'                        will also comprise a list of fields that are present within
#'                        the table.
#' @param split_tables_lookup a list of character vectors (length = 2) where each
#'                            element corresponds to a table that is to be
#'                            split into multiple tables. the first element
#'                            contains a regular expression that is used to identify
#'                            tables that are to be split. The second element contains
#'                            a regular expression that identifies the data dictionary
#'                            table that is to be split.
#' @details The cancer dataset currently, comprises of the following tables:
#' - National Cancer Registrations (NCR)
#' - Rapid Cancer Registration (RCR)
#' - Systemic Anti-Cancer Therapy (SACT)
#' - Rapid Diagnostic Centre (RDC)
#' - Radiotherapy Dataset (RTDS)
#'
#' @return
#'
#' \item{NULL}{If no cancer datasets were found}
#'
#' OR
#'
#' List where each element corresponds to a cancer datasets table and has the following elements:
#'
#' \item{customer}{character vector of customer tables (length >=1)}
#' \item{dd}{A character vector of the data dictionary table (length == 1)}
#'
#' @export
find_tables_to_split = function(
        customer_tables,
        dictionary_tables,
        split_tables_lookup = split_tables_lookup
        ){

    # The split tables lookup
    for (table in seq_along(split_tables_lookup)){

        found_tables = grep(split_tables_lookup[[table]][["customer"]],
                            names(customer_tables), value = T, ignore.case = T)

        if(length(found_tables) > 1){

            split_tables_lookup[[table]][["customer"]] = list(found_tables)

        }else if(length(found_tables) == 0){

            split_tables_lookup[[table]][["customer"]] = NA

        } else split_tables_lookup[[table]][["customer"]] = found_tables

    }

    split_datasets_found = purrr::map_lgl(split_tables_lookup, ~!is.na(.x[["customer"]]))

    if(!any(split_datasets_found)) return(NULL) else{

        # remove tables that do not need to be split from the lookup list
        split_tables_lookup = split_tables_lookup %>% purrr::keep(~!is.na(.x[["customer"]]))


        split_tables_lookup = purrr::map(split_tables_lookup, ~{

            found = grep(.x[["dd"]], names(dictionary_tables), value = T, ignore.case = T)

            .x[["dd"]] = found

            return(.x)

        })

        if(any(purrr::map_lgl(split_tables_lookup, ~length(.x[["dd"]]) == 0))) stop("Some dictionary tables were not found")

        if(any(purrr::map_lgl(split_tables_lookup, ~length(.x[["dd"]]) > 1))) stop("More than one dictionary table found for some datasets")

    }



    return(lapply(split_tables_lookup, purrr::flatten))

}






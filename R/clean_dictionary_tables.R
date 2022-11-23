#' Clean data dictionary
#'
#' This function cleans the unformatted list of data dictionary tables and also
#' tests various table columns to ensure they meet each a pre-defined criteria.
#'
#' @param dictionary a list tables corresponding to individual data dictionary tables
#' @param agreement_id a character representing the customer's agreement id
#' @param expected_fields a character vector of expected field names
#' @return list comprising of cleaned data dictionary tables and information about
#'         various column level checks
#'
#' @export
clean_dictionary_tables <- function(dictionary,
                                    agreement_id,
                                    expected_fields = expected$fields
                                    ){

    if(missing(dictionary)) stop("dictionary is missing!")
    if(!is.list(dictionary)) stop("dictionary is not a list")
    if(length(dictionary) <1) stop("dictionary is not of length >= 1")
    if(is.null(names(dictionary))) stop("dictionary table names not detected")
    if(length(unique(lengths(dictionary))) != 1) stop("dictionary table columns are not of equal length")

    if(missing(agreement_id)) stop("agreement_id is missing")
    if(length(agreement_id) != 1) stop("agreement_id not of length == 1")
    if(!is.character(agreement_id)) stop("agreement_id is not a character")


    fields_present(dictionary = dictionary, expected = expected_fields)


    cleaned_dict <-  dictionary %>%

        purrr::imap(
            ~clean_table(dd_table = .x,
                         table_name = .y,
                         col_order = expected_fields,
                         agreement = agreement_id
                         )
            )


    return(cleaned_dict)

}


# expected <- list(
#
#     fields = c("path","table","display_name", "display_name_label",
#                "field_description", "variable_type", "data_type", "units",
#                "values", "notes", "links"),
#
#     variable_types = c("Categorical","Continuous"),
#
#     data_types = c("String","Character", "Integer", "Float","Boolean", "Date",
#                    "Time", "Datetime","Timestamp")
#     )
#
# usethis::use_data(expected, internal = TRUE)



#' Test for expected fields
#'
#' This function tests if all expected fields are present in each of the the
#' dictionary table
#'
#' @param dictionary a list of dictionary tables
#' @param expected a character vector of expected field names
#' @return logical if all fields are present
fields_present <- function(dictionary, expected){

    not_present <- lapply(dictionary, function(x) all(!colnames(x) %in% expected)) %>%
        unlist() %>%
        which()

    if(length(not_present) == 0) return(TRUE) else{

        rlang::abort(
            message = c(crayon::yellow$italic("Expected fields not detected in:"),
                        names(not_present))
            )
    }

}



#' Clean an individual dictionary table
#'
#' This function applies a number of formatting options to an individual
#' dictionary table. These include:
#' 1.) Sorting the column order;
#' 2.) Converting variable and data types to title case;
#' 3.) Adding dataset/agreement specific path and table names;
#' 4.) Adding a new line return after each "value" key-value pair.
#'
#' @param dd_table a data.frame corresponding to a specific dictionary dataset table
#' @param col_order a character vector detailing the order of the columns
#' @param agreement a character representing the customer's agreement id
#' @param table_name a character representing the specific table name
#' @return a cleaned data.frame
clean_table <- function(dd_table, col_order, agreement, table_name){

    db_name <- paste("dars_nic", agreement, sep = "_")

    tbl_name <- paste(table_name, db_name, sep = "_")

    dd_table %>%

        dplyr::select(dplyr::all_of(col_order)) %>%

        dplyr::mutate(

            dplyr::across(.data$variable_type, ~tools::toTitleCase(tolower(.x))),

            dplyr::across(.data$data_type, ~tools::toTitleCase(tolower(.x)))

            ) %>%

        dplyr::mutate(dplyr::across(.data$path, ~ db_name)) %>%

        dplyr::mutate(dplyr::across(.data$table, ~ tbl_name)) %>%

        dplyr::mutate(dplyr::across(.data$values, ~stringr::str_replace_all(.x, ";","\n")))

}



#' Check data dictionary
#'
#' This function completes a number of checks on the dictionary and highlights
#' rows which invalidate any checks.
#'
#' @param dictionary a list tables corresponding to individual data dictionary tables
#' @param reference a list of data.frame containing a column of reference values to
#'                  compare against the dictionary tables
#' @param min_nchars the minimum number length of characters required (default = 2)
#'                   for the display_name, display_name_label and field_description
#'                   fields
#' @return list comprising of cleaned data dictionary tables and information about
#'         various column level checks
#' @export
check_dictionary <- function(dictionary, reference, min_nchars = 2){

    checks <- list()

    checks$data_type <- purrr::map(
        .x = dictionary,
        ~check_for_expected_vals(.x, data_type, expected$data_types))


    checks$variable_type <- purrr::map(
        .x = dictionary,
        ~check_for_expected_vals(.x, variable_type, expected$variable_types))


    checks$display_name_len <- purrr::map(
        .x = dictionary, ~check_min_nchar(.x, display_name, nchars = min_nchars))


    checks$display_label_len <- purrr::map(
        .x = dictionary, ~check_min_nchar(.x, display_name_label, nchars = min_nchars))


    checks$display_field_desc_len <- purrr::map(
        .x = dictionary, ~check_min_nchar(.x, field_description, nchars = min_nchars))


    checks$values <- purrr::map(
        .x = dictionary, ~check_value_lengths(.x, values))


    # summarise the checks and flag problematic tables
    checks <- purrr::imap(checks, ~{

        flagged_check <- which(unlist(.x))

        tabs  <- switch(.y,
                        data_type = paste(rep("\t",3),collapse =""),
                        variable_type = paste(rep("\t",3),collapse =""),
                        display_name_len = paste(rep("\t",2),collapse =""),
                        display_label_len = paste(rep("\t",2),collapse =""),
                        display_field_desc_len = paste(rep("\t",2),collapse =""),
                        values = paste(rep("\t",4),collapse ="")
                        )


        if(length(flagged_check) == 0){

            cat(glue::glue(crayon::blue$bold("\n{.y}{tabs}PASS")))
            return(TRUE)

            }else{

                cat(glue::glue(crayon::red$bold("\n{.y}{tabs}FAIL")))
                return(names(.x[flagged_check]))
            }

    })


    checks$unique_units <- purrr::map(
        .x = dictionary, ~get_all_unique_units(.x, units))


    checks$all_unique_units <- unique(unlist(checks$unique_units))


    checks$missing_fields <- check_missing_fields(dictionary = dictionary,
                                                  reference = reference)

    return(checks)


}



#' Check a field against a vector of specified values
#'
#' @param dictionary a data.frame corresponding to an individual data dictionary table
#' @param field the name of the field to search
#' @param expected_vals a character vector of values to search against
#' @return logical
check_for_expected_vals <- function(dictionary, field, expected_vals){

   actual_vals <- dictionary %>%
        dplyr::select({{field}}) %>%
        tidyr::drop_na() %>%
        dplyr::distinct() %>%
        dplyr::pull()

    if(!all(actual_vals %in% expected_vals)) TRUE else FALSE

}




#' Check if a field contains a minimum chars
#'
#' @param dictionary a data.frame corresponding to an individual data dictionary table
#' @param field the name of the field to search
#' @param nchars the minimum number length of characters required (default = 2)
#' @return logical
check_min_nchar <- function(dictionary, field, nchars = 2){

    dictionary %>%
        dplyr::select({{field}}) %>%
        dplyr::mutate(row_nchar = nchar({{field}}, type = "width") <= nchars) %>%
        dplyr::pull(.data$row_nchar) %>%
        any()

}


#' Return all unique units
#'
#' @param dictionary a data.frame corresponding to an individual data dictionary table
#' @param field the name of the field containing the units
#' @return character of unique unit values
get_all_unique_units <- function(dictionary, field){

    dictionary %>%
        dplyr::select({{field}}) %>%
        tidyr::drop_na() %>%
        dplyr::distinct() %>%
        dplyr::pull()

}


#' Check if all values are the same length
#'
#' @param dictionary a data.frame corresponding to an individual data dictionary table
#' @param field the name of the field containing the values
#' @return logical
check_value_lengths <- function(dictionary, field){

    dictionary %>%
        dplyr::select({{field}}) %>%
        tidyr::drop_na() %>%
        dplyr::mutate(val_len = lengths({{field}}) != 1) %>%
        dplyr::pull(.data$val_len) %>%
        any()

}



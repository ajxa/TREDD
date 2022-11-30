#' Check missing fields
#'
#' Compare the dictionary fields against a reference to identify fields which are
#' missing in the dictionary
#'
#' @param dictionary a list of data.frames corresponding to an individual data dictionary tables
#' @param reference a list of character vectors corresponding to field names
#'                  which will be compared with those in each dictionary table
#' @return either a logical when no missing fields were detected or a list characters
#'         corresponding to fields missing per each specific table
check_missing_fields <- function(dictionary, reference){

    stopifnot("dictionary is not a list" = is.list(dictionary))
    stopifnot("dictionary is not of length >= 1" = length(dictionary) >= 1)
    stopifnot("dictionary table names not detected"  =!is.null(names(dictionary)))
    stopifnot("reference is not a list" = is.list(reference))
    stopifnot("reference is not of length >= 1" = length(reference) >= 1)
    stopifnot("reference table names not detected" = !is.null(names(reference)))
    stopifnot("dictionary and refernce have different lengthst" = length(dictionary) == length(reference))
    stopifnot("dictionary table names differ from those in the refernce" = all(names(reference) %in% names(dictionary)))


    # Ensure the order of both lists is the same
    reference <- reference[match(names(dictionary), names(reference))]

    outlist <- purrr::map2(.x = dictionary, .y = reference,
                           ~identify_missing_tbl_fields (.x, .y, display_name))

    outlist <- purrr::compact(outlist)

    if(length(outlist) == 0){

        cli::cat_line(cli::col_green(cli::symbol$tick),
                      cli::col_grey(" checking missing fields"),
                      cli::col_white(" ...")
                      )

        return(TRUE)

        }else{

            cli::cat_line(cli::col_red(cli::symbol$cross),
                          cli::col_grey(" checking missing fields"),
                          cli::col_white(" ...")
                          )

            return(outlist)

    }

}


#' Get common fields
#'
#' Compare two lists of data.frames and subset based on the common values for
#' a given field which is present in both data.frames.
#'
#' @param dictionary a list of data.frames corresponding to individual data dictionary tables
#' @param reference a list of character vectors corresponding to field names
#'                  which will be compared with those in each dictionary table
#' @param field the name of the field to search
#' @return A list of subset data.frames
get_common_fields <- function(dictionary, reference, field){

    stopifnot("dictionary is not a list" = is.list(dictionary))
    stopifnot("dictionary is not of length >= 1" = length(dictionary) >= 1)
    stopifnot("dictionary table names not detected"  =!is.null(names(dictionary)))
    stopifnot("reference is not a list" = is.list(reference))
    stopifnot("reference is not of length >= 1" = length(reference) >= 1)
    stopifnot("reference table names not detected" = !is.null(names(reference)))
    stopifnot("dictionary and refernce have different lengthst" = length(dictionary) == length(reference))
    stopifnot("dictionary table names differ from those in the refernce" = all(names(reference) %in% names(dictionary)))

    # Ensure the order of both lists is the same
    reference <- reference[match(names(dictionary), names(reference))]

    common_fields <- purrr::map2(dictionary, reference, ~{

        identify_missing_tbl_fields(dictionary_tbl = .x,
                                    reference_tbl = .y,
                                    field =  {{field}},
                                    return_common = TRUE)
    })

    clean_dictionary <- purrr::map2(dictionary, common_fields, ~{

        .x %>%
            dplyr::mutate(display_name_lower = tolower({{field}})) %>%
            dplyr::filter(display_name_lower %in% .y) %>%
            dplyr::select(-display_name_lower)
    })


    return(clean_dictionary)

}





#' Compare fields values against a reference
#'
#' Compare a fields values against a set of reference values to identify which are
#' missing or in common between the two.
#'
#' @param dictionary_tbl a data.frame corresponding containing a field which you want to compare against a reference
#' @param reference_tbl a data.frame containing a reference field which you wish to compare
#' @param field the name of the field to compare in both the reference and dictionary table
#' @param return_common if TRUE (default: FALSE) returns the common fields between the dictionary and the reference
#' @return logical or a list of characters corresponding to field names (either the difference or intersect)
identify_missing_tbl_fields <- function(dictionary_tbl,
                                        reference_tbl,
                                        field,
                                        return_common = FALSE){

    dictionary_unique_fields <-  dictionary_tbl %>%
        dplyr::select({{field}}) %>%
        tidyr::drop_na() %>%
        dplyr::distinct() %>%
        dplyr::mutate(dplyr::across({{field}}, tolower)) %>%
        dplyr::pull()

    reference_unique_fields <- reference_tbl %>%
        dplyr::select({{field}}) %>%
        tidyr::drop_na() %>%
        dplyr::distinct() %>%
        dplyr::mutate(dplyr::across({{field}}, tolower)) %>%
        dplyr::pull()

    if(return_common){

       return(intersect(dictionary_unique_fields, reference_unique_fields))

    }

    missing_fields <- setdiff(reference_unique_fields, dictionary_unique_fields)

    if(length(missing_fields) > 0) missing_fields else NULL

}



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
                           ~missing_tbl_fields(.x, .y, display_name))

    outlist <- purrr::compact(outlist)

    if(length(outlist) == 0){

        cli::cat_line(cli::col_green(cli::symbol$tick),
                 cli::col_grey("  checking missing fields"),
                 cli::col_white(" ...")
        )

        return(TRUE)

        }else{

            cli::cat_line(cli::col_red(cli::symbol$cross),
                     cli::col_grey("  checking missing fields"),
                     cli::col_white(" ...")
            )

            return(outlist)

    }

}



#' Compare fields with against a reference
#'
#' Compare fields against a reference to identify  fields which are
#' missing in the dictionary table
#'
#' @param dictionary_tbl a data.frame corresponding to an individual data dictionary table
#' @param reference_tbl a data.frame containing a column of reference values to compare against
#' @param field the name of the field to compare in both the reference and dictionary
#' @return logical
missing_tbl_fields <- function(dictionary_tbl, reference_tbl, field){

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


    missing_feilds <- !reference_unique_fields %in% dictionary_unique_fields

    if(any(missing_feilds)) reference_unique_fields[which(missing_feilds)] else NULL

}



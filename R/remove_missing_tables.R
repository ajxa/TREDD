#' Remove missing table
#'
#' This function removes any tables (from the data dictionary) that are not
#' present within the list of fields for a given customers data sharing agreement.
#'
#' @param dictionary a list of data dictionary tables returned by [TREDD::clean_table_names()]
#' @param fields a list of fields present in a users agreement, returned from [select_customer()]
#' @return list of dictionary and field tables
#' @export
remove_missing_tables <- function(dictionary, fields){

    if(missing(dictionary)) stop("dictionary is missing!")
    if(missing(fields)) stop("fields are missing!")

    # All the field tables present
    if(all(names(fields) %in% names(dictionary))){

        fields <- fields[names(fields)]

        dictionary <- dictionary[names(fields)]

        return(
            list(dictionary = dictionary, fields = fields)
        )

    }

    # No field tables present
    if(all(!names(fields) %in% names(dictionary))){

        stop("no field tables present in dictionary")
    }



    found <- names(fields)[names(fields) %in% names(dictionary)]
    not_found <- names(fields)[!names(fields) %in% names(dictionary)]


    fields <- fields[found]
    dictionary <- dictionary[found]

    message(crayon::yellow$bold("The following tables were not found..."))

    warning_message <-  paste0("\n\t", not_found, collapse = "")

    message(crayon::red$bold(warning_message))

    return(
        list(dictionary = dictionary, fields = fields)
    )

    #
    # # some environment tables missing in the data dictionary
    # found <- purrr::imap(dictionary, ~{
    #
    #     lookup_pattern <- stringr::str_replace_all(.y, "[{]","\\\\{") %>%
    #
    #         stringr::str_replace_all("[}]","\\\\}") %>%
    #
    #         paste0("^",.,"$")
    #
    #     grep(lookup_pattern, names(fields), value = T)
    #
    # })
    #
    # # Where names have been found in the environment table names (len(n) == 1)
    # # alter the names of the dictionary to account for excel max length cuttoffs
    #
    # names(dictionary)[lengths(found) == 1] <- unlist(found[lengths(found) == 1],
    #                                                  use.names = F)
    #
    # not_found <- names(dictionary)[lengths(found) == 0 | lengths(found) > 1]
    #
    # found <- names(dictionary)[lengths(found) == 1]
    #
    # warning_message <-  paste0("Warning: datasets not found!",
    #                            paste0("\n", not_found, collapse = ""))
    #
    # if(length(not_found) >= 1) message(crayon::yellow(warning_message))
    #
    # fields <- fields[found]
    #
    # dictionary <- dictionary[found]
    #
    #
    #
    #
    # return(
    #     list(dictionary = dictionary, fields = fields)
    # )
}

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

        fields = fields[names(fields)]

        dictionary = dictionary[names(fields)]

        cli::cat_line(cli::symbol$tick,
                      cli::col_grey(" All customer dictionaries found"),
                      col = "green")

        return(
            list(dictionary = dictionary, fields = fields)
        )

    }

    # No field tables present
    if(all(!names(fields) %in% names(dictionary))){

        stop("no field tables present in dictionary")
    }

    found = names(fields)[names(fields) %in% names(dictionary)]
    not_found = which(!names(fields) %in% names(dictionary))

    # Some fields are not present
    if(length(not_found) > 0){

        # Account for the fact that the dictionary names may be limited by
        # the max excel sheet name which max(length) = 31
        to_find =  stringr::str_remove_all(names(fields)[not_found], "_\\{fyear\\}$") %>%
        stringr::str_sub(start =  1, end = 31) %>%
        paste0("_{fyear}")

        names(to_find) = names(fields)[not_found]

        second_try_found = to_find[to_find %in% names(dictionary)]
        second_try_not_found = to_find[!to_find %in% names(dictionary)]

        names(fields)[names(fields) %in% names(second_try_found)] = second_try_found

        found = names(fields)[names(fields) %in% names(dictionary)]
        not_found = which(!names(fields) %in% names(dictionary))


    }

    fields = fields[found]
    dictionary = dictionary[found]


    if(length(not_found) > 0){

        cli::cat_bullet(
            cli::col_silver({length(not_found)}),
            cli::col_silver(" dictionaries not found:"),
            bullet = "info",
            bullet_col = "yellow")

        stringr::str_remove_all(not_found, "_\\{fyear\\}$") %>%
            purrr::walk(~{cli::cat_line("\t",
                                        cli::symbol$record, " ",
                                        cli::col_grey(.x),
                                        col = "red")})

    }else  cli::cat_line(cli::symbol$tick,
                          cli::col_grey(" All customer dictionaries found"),
                          col = "green")

    return(list(dictionary = dictionary, fields = fields))
}

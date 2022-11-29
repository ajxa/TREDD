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

    cli::cat_line(outputheader("Subset dictionary"))

    # All the field tables present
    if(all(names(fields) %in% names(dictionary))){

        fields <- fields[names(fields)]

        dictionary <- dictionary[names(fields)]

        cli::cat_line(cli::symbol$tick,
                      cli::col_white(" All tables found"),
                      col = "green")

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


    cli::cat_bullet(
        cli::col_white({length(not_found)}),
        cli::col_white(" tables not found in dictionary..."),
               bullet = "info",
               bullet_col = "yellow")

    stringr::str_remove_all(not_found, "_\\{fyear\\}$") %>%
        purrr::walk(~{cli::cat_line("\t",
                               cli::symbol$record, " ",
                               cli::col_grey(.x),
                               col = "blue")})


    return(
        list(dictionary = dictionary, fields = fields)
    )

}

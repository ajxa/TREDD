#' Split a dictionary table into many smaller tables
#' @param dictionary_tables a list of data.frames containing the table to be split into multiple tables
#' @param split_table_name a character vector for the dictionary table to be split
#' @param customer_tables a list of data.frames containing the fields which will
#'                        make up the each of the split tables
#' @param dataset a character vector of the dataset to be split (currently this is only the mental health dataset)
#' @return a list of data.frames or NULL
split_dd_table <- function(dictionary_tables, split_table_name,
                           customer_tables, dataset){

    if(missing(dictionary_tables)) stop("dictionary is missing!")
    if(missing(split_table_name)) stop("split_table_name is missing!")
    if(missing(customer_tables)) stop("reference is missing!")
    if(missing(dataset)) stop("dataset is missing!")
    if(!split_table_name %in% names(dictionary_tables)) stop("split_table_name not found in dictionary tables!")


    matched_dataset<-  match.arg(tolower(dataset),
                             choices = c("mental_health", "maternity"),
                             several.ok = FALSE)

    split_pattern <- switch(matched_dataset,
                            "mental_health" = "(?i)^mhs",
                            "maternity" = "(?i)^msds")

    split_tables <- grep(split_pattern, names(customer_tables), value = T)

    if(length(split_tables) > 1){

        split_data <- list(data_dictionary = dictionary_tables[[split_table_name]],
                           environment_fields = customer_tables[split_tables]
                           )

        split_data$data_dictionary <- split_data$data_dictionary %>%
            dplyr::mutate(dplyr::across(.data$display_name, tolower))


        split_data$environment_fields <- purrr::map(split_data$environment_fields, ~{

            .x %>% dplyr::mutate(dplyr::across(.data$display_name, tolower))

        })


        split_dict_table <- purrr::imap(split_data$environment_fields, ~{

            fields_to_find <- .x$display_name

            split_data$data_dictionary %>%
                dplyr::filter(.data$display_name %in% dplyr::all_of(fields_to_find))
            })

        return(split_dict_table)

        } else NULL

}


#' combine dictionary tables into one table
#' @param dictionary a list of data.frames containing the tables to be combined
#' @param dataset a character vector of the dataset to be split (currently this is only the mental health dataset)
#' @return a list of data.frames or NULL
combine_split_tables <- function(dictionary, dataset){

    matched_dataset<-  match.arg(tolower(dataset),
                                 choices = c("mental_health", "maternity"),
                                 several.ok = FALSE)

    combine_info <- switch(matched_dataset,
                           "mental_health" = list(name = "mhsds",
                                                   pattern = "(?i)^mhs"),
                           "maternity" = list(name = "msds",
                                              pattern = "(?i)^msds")
                            )

    combine_tables <- grep(combine_info$pattern, names(dictionary))


    if(length(combine_tables) > 1){

        combined_tables <- dplyr::bind_rows(dictionary[combine_tables])

        combined_tables <- list(combined_tables) %>% purrr::set_names(combine_info$name)

        dictionary <- dictionary[-combine_tables]

        return(c(dictionary, combined_tables))

    } else NULL

}




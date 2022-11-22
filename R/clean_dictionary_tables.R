#' Clean data dictionary
#'
#' This function cleans the unformatted list of data dictionary tables and also
#' tests various table columns to ensure they meet each a pre-defined criteria.
#'
#' @param dictionary a list tables corresponding to individual data dictionary tables
#' @param agreement_id a character representing the customer's agreement id
#' @return list comprising of cleaned data dictionary tables and information about
#'         various column level checks
#'
#' @export
clean_dictionary_tables <- function(dictionary, agreement_id){

    # CLEANING/CHECKING FUNCTIONS START ----

    check_dd_fields <- function(data_dictionary, expected_fields){

        check_fields_are_present <- function(x, expected){

            if(all(colnames(x) %in% expected)) return(TRUE) else return(FALSE)

        }

        all_expected_fields_present <- data_dictionary %>%
            lapply(check_fields_are_present, expected = expected_fields) %>%
            unlist()


        # all_expected_fields_present <- lapply(data_dictionary, function(x){
        #
        #     if(all(colnames(x) %in% expected_fields)) return(TRUE) else return(FALSE)
        #
        # }) %>% unlist()

        if(all(all_expected_fields_present)) return(TRUE) else{

            fields_not_present <- names(which(!all_expected_fields_present))

            fields_not_present <- paste0(fields_not_present,collapse = "\n")

            rlang::abort(glue::glue("expected fields not detected in:\n {fields_not_present}"))

        }

    }


    reformat_dd_tabls <- function(dd_table, col_order){

        dd_table %>%

            select(all_of(col_order)) %>%

            mutate(

                across(variable_type, ~tools::toTitleCase(tolower(.x))),

                across(data_type, ~tools::toTitleCase(tolower(.x))),

            )

    }


    add_db_and_tbl_names <- function(dd_table,
                                     agreemnt_id = NULL,
                                     table_name = NULL){

        db_name <- paste("dars_nic", agreemnt_id, sep = "_")

        tbl_name <- paste(table_name, db_name, sep = "_")

        dd_table %>%
            mutate(across("path", ~ db_name)) %>%
            mutate(across("table", ~ tbl_name))

    }


    check_field_types <- function(cleaned_data_dict_tbl, valid_types){

        stopifnot(exprs = {

            is.list(valid_types);

            length(valid_types) == 2;

            all(names(valid_types) == c("variable_type","data_type"));

        })

        checked <- imap(valid_types, ~{

            unique_types <- cleaned_data_dict_tbl[[.y]] %>%
                na.omit() %>%
                unique()

            if(all(unique_types %in% .x)) return(TRUE) else return(FALSE)

        }) %>% unlist()

        return(checked)
    }


    check_display_name_labels <- function(cleaned_data_dict_tbl){

        zero_length_labels <- nchar(cleaned_data_dict_tbl[["display_name_label"]], type = "width") <= 2

        if(any(zero_length_labels)) return(which(zero_length_labels)) else return(TRUE)

    }


    check_field_descriptions <- function(cleaned_data_dict_tbl){

        zero_length_labels <- nchar(cleaned_data_dict_tbl[["field_description"]],type = "width") <= 2

        if(any(zero_length_labels)) return(which(zero_length_labels)) else return(TRUE)

    }


    check_units <- function(cleaned_data_dict_tbl){

        unique_units <- unique(cleaned_data_dict_tbl[["units"]]) %>%
            na.omit() %>%
            as.character()

        if(length(unique_units) == 0) return(TRUE) else return(unique_units)

    }


    check_values <- function(cleaned_data_dict_tbl){

        single_length_values <- lengths(cleaned_data_dict_tbl[["values"]]) != 1

        if(any(single_length_values)) return(which(single_length_values)) else return(TRUE)

    }


    make_values_readable <- function(cleaned_data_dict_tbl){

        cleaned_data_dict_tbl %>%
            mutate(across(values, ~str_replace_all(.x, ";","\n")))
    }


    # CLEANING/CHECKING FUNCTIONS END ----

    stopifnot(exprs = {

        !missing(agreement_id);

        is.list(dictionary);

        length(dictionary) >= 1;

        # The list must have names corresponding to the table names
        !is.null(names(dictionary));

        # Do all the table have the same number of fields
        length(unique(lengths(dictionary))) == 1;

    })

    expected_fields <- c("path","table","display_name",
                         "display_name_label", "field_description",
                         "variable_type", "data_type", "units","values",
                         "notes", "links")

    check_dd_fields(dictionary, expected_fields = expected_fields)

    cleaned_data_dict <-  dictionary %>%

        map(reformat_dd_tabls, col_order = expected_fields) %>%

        imap(., ~ add_db_and_tbl_names(dd_table = .x,
                                       table_name = .y,
                                       agreemnt_id = agreement_id)) %>%

        map(., ~ make_values_readable(cleaned_data_dict_tbl = .x))

    checks <- list()

    valid_types <- list(variable_type = c("Categorical","Continuous"),
                        data_type = c("String","Character",
                                      "Integer", "Float",
                                      "Boolean",
                                      "Date","Time", "Datetime","Timestamp"))

    types_checked <- map(cleaned_data_dict,
                         ~check_field_types(cleaned_data_dict_tbl = .x,
                                            valid_types = valid_types))

    # Checks if any fields are only contain the allowed data/variable types
    checks$types <- map(types_checked, ~{

        if(all(.x)) return(TRUE) else return(.x)

    })

    # Checks if any fields are missing display name labels
    checks$display_names <- map(cleaned_data_dict, check_display_name_labels)

    # Checks if any fields are missing descriptions
    checks$field_desc <- map(cleaned_data_dict, check_field_descriptions)

    checks$units <- map(cleaned_data_dict, check_units)

    # Check if all the values listed are a single length character vector -
    # a proxy to see if they are parse-able
    checks$values <- map(cleaned_data_dict, check_values)

    summarise_checks <- function(checklist){

        simple_checks <- checklist[-grep("units", names(checklist))]

        descriptive_checks <- checklist[grep("units", names(checklist))]

        iwalk(simple_checks, ~{

            if(all(unlist(.x) == 1)){

                message(glue::glue(crayon::green("\n{.y} ALL good!")))

            }else message(glue::glue(crayon::yellow("\n{.y} need checking!")))
        })


        unique_units <- sort(unique(unlist(descriptive_checks)))

        unique_units <- paste0("\n","\t",1:length(unique_units), "\t", unique_units)

        if(length(unique_units) >= 1){

            message(glue::glue(crayon::blue("\nunique units:")))
            message(glue::glue(crayon::blue("\t\t{unique_units}")))

        }else message(glue::glue(crayon::green("no unique units!")))

    }

    summarise_checks(checks)

    return(list(cleaned = cleaned_data_dict, checks = checks))

}

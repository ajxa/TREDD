#' Generate a formatted data dictionary

#' @param customer_name a character vector corresponding to one of the approved users
#' @param customer_fields_path a file path corresponding to a csv file which lists
#'                             all the fields present in the selected customers agreement
#' @param unformatted_dict_path a file path to an excel workbook containing one unformatted dictionary table per sheet
#' @param output_hometab_filepath the file path to the output home and reference tab
#' @param output_filepath the file path where you wish to save formatted excel workbook
#' @param overwrite_output logical should the outputfile be overwritten, if it exists (default:TRUE)
#'
#' @return A list of length 4: unformatted_dd = a list of the unformatted dictionary tables before cleaning;
#'         customer_info = a list of 3 comprising customer information and agreement specific fields;
#'         cleaned_dd = a list of cleaned cleaned dictionary tables;checks = a list of checks
#'         completed against each of the cleaned dictionary tables.
#' @export
generate_dd <- function(customer_name,
                        customer_fields_path,
                        unformatted_dict_path,
                        output_hometab_filepath,
                        output_filepath = getwd(),
                        overwrite_output = TRUE){

    dictionary <- TREDD::read_excel_sheets(
        workbook_path = unformatted_dict_path,
        filter_sheets = c("Home","Refinements", "Dictonary_Priorities")
        )

    names(dictionary) <- TREDD::clean_table_names(table_names = names(dictionary))


    customer <- TREDD::select_customer(
        customer_name = customer_name, customer_fields = customer_fields_path
        )


    # Split up mental health dataset
    split_mental_health <- split_dd_table(dictionary_tables = dictionary,
                                          split_table_name = "mhsds",
                                          customer_tables = customer$fields,
                                          dataset = "mental_health")

    if(!is.null(split_mental_health)){

        cli::cat_line(outputheader("Pre-processing"))

        cli::cat_line(cli::col_yellow(cli::symbol$info),
                      cli::col_grey(" Split mental health dataset into "),
                      cli::col_grey({length(split_mental_health)}),
                      cli::col_grey(" tables"),
                      cli::col_white(" ..."))

        dictionary <- c(dictionary, split_mental_health)

    }


    filt_dictionary <- TREDD::remove_missing_tables(dictionary = dictionary,
                                                    fields = customer$fields)

    filt_dictionary$dictionary <- clean_dictionary_tables(
        dictionary = filt_dictionary$dictionary,
        agreement_id = customer$agreement_id
        )


    cleaned <- get_common_fields(dictionary = filt_dictionary$dictionary,
                                 reference = filt_dictionary$fields,
                                 field = display_name)

    checks <- check_dictionary(dictionary = cleaned,
                               reference = filt_dictionary$fields)

    cli::cat_line(outputheader("Post-processing"))


    if(!is.null(split_mental_health)){

        cli::cat_line(cli::col_yellow(cli::symbol$info),
                      cli::col_grey(" Re-combining "),
                      cli::col_grey({length(split_mental_health)}),
                      cli::col_grey(" mental health dataset tables"),
                      cli::col_white(" ..."))

        cleaned <- combine_split_tables(cleaned, dataset = "mental_health")

    }


    names(cleaned) <- clean_table_names(names(cleaned), remove_fyear = TRUE)

    cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                  cli::col_grey({length(cleaned)}),
                  cli::col_grey(" dictionary tables successfully formatted")
                  )


    create_formatted_workbook(dictionary = cleaned,
                              hometab_filepath = output_hometab_filepath,
                              customer_name = customer$user,
                              customer_agreement = customer$agreement_id,
                              outfilepath = output_filepath,
                              overwrite_existing = overwrite_output)

    return(
        list(unformatted_dd = dictionary,
             customer_info = customer,
             cleaned_dd = cleaned,
             checks = checks)
           )

}

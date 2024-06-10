#' Generate a formatted data dictionary

#' @param customer_name a character vector corresponding to one of the approved users
#' @param customer_fields_path a file path corresponding to a csv file which lists
#'                             all the fields present in the selected customers agreement
#' @param unformatted_dict_path a file path to an excel workbook containing one unformatted dictionary table per sheet
#' @param output_hometab_filepath the file path to the output home and reference tab
#' @param output_filepath the file path where you wish to save formatted excel workbook
#' @param overwrite_output logical should the outputfile be overwritten, if it exists (default:TRUE)
#' @param tell_fortune logical should a R-based fortune be printed to the console (default:FALSE)
#'
#' @return A list of length 4: unformatted_dd = a list of the unformatted dictionary tables before cleaning;
#'         customer_info = a list of 3 comprising customer information and agreement specific fields;
#'         cleaned_dd = a list of cleaned cleaned dictionary tables;checks = a list of checks
#'         completed against each of the cleaned dictionary tables.
#' @export
generate_dd = function(
    customer_name,
    customer_fields_path,
    unformatted_dict_path,
    output_hometab_filepath,
    output_filepath = getwd(),
    overwrite_output = TRUE,
    tell_fortune = FALSE
    ){

    cli::cat_line(cli::rule(center = "SDE Data Dictionaries",
                  col = "slateblue",line_col = "white"))

    if(tell_fortune){
        cli::cli_blockquote(fortunes::fortune())
    }else{

        cli::cli_blockquote("Starting the data dictionary generator...beep bop boop")
    }

    cli::cat_line(cli::rule(left = "Customer Information",
                            col = "slateblue",line_col = "white"),
                  "\n")

    customer = TREDD::select_customer(
        customer_name = customer_name,
        customer_fields = customer_fields_path
        )

    cli::cat_line("\n",
                  cli::rule(left = "Unformatted Dictionaries",
                            col = "slateblue",line_col = "white"),
                  "\n")


    dictionary = TREDD::read_excel_sheets(
        workbook_path = unformatted_dict_path,
        filter_sheets = c("Home","Refinements", "Dictonary_Priorities")
        )

    names(dictionary) = TREDD::clean_table_names(table_names = names(dictionary))

    split_lookups = find_tables_to_split(
      customer_tables = customer$fields,
      dictionary_tables = dictionary,
      split_tables_lookup = split_tables_lookup
    )

    if(length(split_lookups) >= 1){

        cli::cat_line(
          "\n",
          cli::rule(left = "Splitting Dictionaries",
                                col = "slateblue",line_col = "white"),
          "\n"
        )
    }

    split_lookups = get_split_keys(tables_to_split = split_lookups,
                                   customer_tables = customer$fields,
                                   dictionary_tables = dictionary,
                                   split_key_field = "display_name"
                                   )

    missing_keys_found = missing_split_keys(split_lookups)


    if(!is.logical(missing_keys_found)){

        cli::cli_alert_danger("Missing fields detected in split dictionaries")

        cli::cli_inform("- Please check the output and re-run")

        return(missing_keys_found)
    }

    dictionary = split_tables(dictionary_tables = dictionary,
                              split_lookups = split_lookups,
                              split_field = "display_name")


    cli::cat_line("\n", cli::rule(left = "Checks & Balances",
                            col = "slateblue",line_col = "white"),
                  "\n")

    filt_dictionary = TREDD::remove_missing_tables(
        dictionary = dictionary,
        fields = customer$fields
        )

    filt_dictionary$dictionary = clean_dictionary_tables(
      dictionary = filt_dictionary$dictionary,
      agreement_id = customer$agreement_id
      )

    cleaned = get_common_fields(
      dictionary = filt_dictionary$dictionary,
      reference = filt_dictionary$fields,
      field = display_name
    )

    checks = check_dictionary(
      dictionary = cleaned,
      reference = filt_dictionary$fields
    )

    if(length(split_lookups) >= 1){

        cli::cat_line(
          "\n",
          cli::rule(
            left = "Combining Split Dictionaries",
            col = "slateblue",
            line_col = "white"
          ),
          "\n"
        )

        cleaned = combine_split_tables(dictionary_tables =  cleaned,
                                       split_lookups = split_lookups)

    }

    cli::cat_line("\n",
                  cli::rule(left = "Creating Formatted Dictionary",
                            col = "slateblue",line_col = "white"),
                  "\n")


    names(cleaned) = clean_table_names(
      table_names = names(cleaned),
      remove_fyear = TRUE
    )

    create_formatted_workbook(
      dictionary = cleaned,
      hometab_filepath = output_hometab_filepath,
      customer_name = customer$customer_name,
      customer_agreement = customer$agreement_id,
      outfilepath = output_filepath,
      overwrite_existing = overwrite_output
    )


    cli::cat_line(
      "\n",
      cli::rule(
        center = "end",
        col = "slateblue",
        line_col = "white"
      ),
      "\n"
    )

    return(
        list(
          unformatted_dd = dictionary,
          customer_info = customer,
          cleaned_dd = cleaned,
          checks = checks
        )
    )

}

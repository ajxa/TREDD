#' Read in an excel workbook
#'
#' This function reads in an excel workbook into R.
#'
#' @param workbook_path path to the excel workbook
#' @param filter_sheets character vector of sheet names to filter out
#' @return A list of data frames corresponding to individual excel workbook sheets
#' @export
read_excel_sheets <- function(workbook_path, filter_sheets){

    if(missing(workbook_path)) cli::cli_abort("workbook_path not supplied")

    if(!any(tools::file_ext(basename(workbook_path)) %in% c("xlsx"))){

        cli::cli_abort("workbook_path is not an .xlsx file")
    }

    all_sheets <- readxl::excel_sheets(workbook_path) %>%
        purrr::set_names() %>%
        as.list()

    sheets_found <- length(all_sheets)

    cli::cat_line(cli::col_yellow(cli::symbol$info)," ",
                  cli::col_silver({sheets_found}),
                  cli::col_grey(" workbook sheets found"))

    if(!missing(filter_sheets)){

        if(!all(filter_sheets %in% names(all_sheets))){

          missing_filter_sheets = which(!filter_sheets %in% names(all_sheets))

          missing_filter_sheets = paste0(missing_filter_sheets, collapse = "\n")

          cli::cli_abort("Some filter_sheets not found:{missing_filter_sheets}")

      }

    all_sheets <-  within(all_sheets, rm(list=filter_sheets))

    }

    bring_in_all_sheets = function(sheets){

        out_sheets = vector("list", length(sheets))

        cli::cli_progress_bar("Loading", clear = TRUE, total = 100)

        for (sheet in seq_along(sheets)) {

            out_sheets[[sheet]] = readxl::read_xlsx(path = workbook_path,
                                                    sheet = all_sheets[[sheet]],
                                                    progress = FALSE)

            names(out_sheets)[[sheet]] = names(sheets)[[sheet]]

            cli::cli_progress_update(inc = 100/length(sheets))

        }

        return(out_sheets)
    }

    out = bring_in_all_sheets(all_sheets)

    cli::cat_line(cli::col_yellow(cli::symbol$info)," ",
                  cli::col_grey({sheets_found - length(out)}),
                  cli::col_grey(" workbook sheets skipped"))

    cli::cat_line(cli::col_green(cli::symbol$tick)," ",
                  cli::col_grey({length(out)}),
                  cli::col_grey(" workbook sheets loaded"))

    return(out)

}

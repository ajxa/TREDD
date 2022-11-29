#' Read in an excel workbook
#'
#' This function reads in an excel workbook into R.
#'
#' @param workbook_path path to the excel workbook
#' @param filter_sheets character vector of sheet names to filter out
#' @return A list of data frames corresponding to individual excel workbook sheets
#' @export
read_excel_sheets <- function(workbook_path, filter_sheets){

    if(missing(workbook_path)) stop("workbook path is missing!")

    if(!any(tools::file_ext(basename(workbook_path)) %in% c("xlsx"))){

        stop("workbook path must be either .xlsx")
    }

    if(missing(workbook_path)) stop("workbook path is missing!")

    all_sheets <- readxl::excel_sheets(workbook_path) %>%
        purrr::set_names() %>%
        as.list()


    cli::cat_line(outputheader("Load dictionary"))

    cli::cat_line(cli::col_yellow(cli::symbol$info)," ",
                  cli::col_grey({length(all_sheets)}),
                  cli::col_grey(" tables found"))

    sheets_removed <- length(all_sheets)

    if(!missing(filter_sheets)){

    all_sheets <-  within(all_sheets, rm(list=filter_sheets))

    out_sheets <- purrr::map(all_sheets, ~{

        readxl::read_xlsx(path = workbook_path,
                          sheet = .x)

    })

    sheets_removed <- sheets_removed - length(out_sheets)

    cli::cat_line(cli::col_yellow(cli::symbol$info)," ",
                  cli::col_grey({sheets_removed}),
                  cli::col_grey(" workbook sheets skipped"))


    cli::cat_line(cli::col_green(cli::symbol$tick)," ",
                  cli::col_grey({length(out_sheets)}),
                  cli::col_grey(" tables successfully loaded"))

    return(out_sheets)

    } else{

        return(all_sheets)

        cli::cat_bullet({length(all_sheets)}, " tables Loaded",
                        col = "grey", bullet_col = "white")

    }
}

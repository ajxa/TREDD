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

    if(!missing(filter_sheets)){

    all_sheets <-  within(all_sheets, rm(list=filter_sheets))

    out_sheets <- purrr::map(all_sheets, ~{

        readxl::read_xlsx(path = workbook_path,
                          sheet = .x)

    })

    return(out_sheets)

    } else return(all_sheets)

}

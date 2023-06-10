#' Create a formatted excel workbook
#'
#' This function will take a list cleaned data dictionary tables and return
#' a formatted excel workbook. It will also allows functionality to add a home tab
#' to the final document.
#'
#' @param dictionary a list of cleaned data dictionary tables
#' @param hometab_filepath a file path where the home tab excel workbook is located
#' @param customer_name a character corresponding to the customers name
#' @param customer_agreement a character corresponding to the customers agreement id
#' @param outfilepath a file path where you would like to save the workbook. The "/" should be omitted in this path
#' @param overwrite_existing logical should an existing file be overwritten (default: TRUE)
#'
#' @return a formatted excel workbook saved to the outfilepath
#'
#' @export
create_formatted_workbook <- function(dictionary,
                                      hometab_filepath,
                                      customer_name,
                                      customer_agreement,
                                      outfilepath,
                                      overwrite_existing = TRUE){

    if(!is.list(dictionary)) stop("dictionary is not a list")
    if(length(dictionary) < 1) stop("dictionary must be of length >= 1")
    if(is.null(names(dictionary))) stop("dictionary names not found")
    if(missing(customer_agreement)) stop("customer agreement is missing")
    if(missing(outfilepath)) stop("outfilepath is missing")


    if(!missing(hometab_filepath)){

        home_tab_sheets <- openxlsx::getSheetNames(hometab_filepath)

        wb <- openxlsx::loadWorkbook(file = hometab_filepath)

        cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                      cli::col_grey("Read in Home tab")
                      )


    } else wb <- openxlsx::createWorkbook()

    # Workbook Styling ----

    home_tab_style <- openxlsx::createStyle(fgFill = "#ffffff")

    openxlsx::modifyBaseFont(wb,
                             fontSize = 12,
                             fontName = "Arial",
                             fontColour = "black")

    headerstyle <- openxlsx::createStyle(fontColour = "#ffffff",
                               fgFill = "#003087",           # Other NHSE blues "#005EB8" "#0072CE"
                               halign = "left",
                               valign = "top",
                               textDecoration = "bold")

    home_headerstyle <- openxlsx::createStyle(
        fontColour = "#ffffff",
        bgFill = "#003087",         # Other NHSE blues "#005EB8" "#0072CE"
        fgFill = "#003087",
        fontSize = 14,
        fontName = "Arial",
        halign = "left",
        valign = "top",
        textDecoration = "bold")

    dropdown_header_style <- openxlsx::createStyle(
        fontName = "Arial",
        fontSize = 20,
        fontColour = "white",
        bgFill = "#003087",
        fgFill = "#003087",
        borderColour = "black",
        borderStyle = "thin",
        border = "TopBottomLeftRight",
        halign = "center",
        valign = "center")

    dropdown_text_style <- openxlsx::createStyle(
        fontName = "Arial",
        fontSize = 20,
        textDecoration = "bold",
        fontColour = "black",
        borderColour = "black",
        borderStyle = "thin",
        border = "TopBottomLeftRight",
        halign = "center",
        valign = "center")


    wrap_text_style <- openxlsx::createStyle(halign = "left",
                                   valign = "top",
                                   wrapText = TRUE)

    normal_text_style <- openxlsx::createStyle(halign = "left",
                                     valign = "top")

    back_to_home_text <- openxlsx::createStyle(fontName = "Arial",
                                     fontSize = 16,
                                     textDecoration = "bold",
                                     fontColour = "black",
                                     valign = "top",
                                     halign = "left")

    # Add table lookup ----

    # Create a lookup of all the dataset tabs available
    table_list <- data.frame(data_table = names(dictionary),
                             stringsAsFactors = FALSE)

    openxlsx::addWorksheet(wb, sheetName = "table_list",
                           tabColour = "lightgreen",
                           visible = FALSE,
                           gridLines = FALSE,
                           zoom = 100)

    # Add a sheet containing a list of tabs
    openxlsx::writeDataTable(wb,
                             withFilter = FALSE,
                             sheet = "table_list",
                             x = table_list,
                             tableName = "table_list",
                             startCol = 1,
                             startRow = 1,
                             colNames = TRUE,
                             rowNames = FALSE)

    # Set the column widths
    openxlsx::setColWidths(wb, sheet = "table_list", cols = 1, widths = c(45))


    cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                  cli::col_grey("Added dictionary lookup table")
                  )


    # Add data dictionary tabs ----

    add_dd_tbl <- function(dd_tbl, tab_name, workbook, show_filter = FALSE){

        # Add the sheet to the workbook
        openxlsx::addWorksheet(wb,
                               sheetName = tab_name,
                               gridLines = FALSE,
                               # tabColour = "red",
                               zoom = 100)

        ## freeze first row of each sheet
        openxlsx::freezePane(wb, sheet = tab_name, firstActiveRow = 4)


        openxlsx::writeData(wb, sheet = tab_name, x = dd_tbl,
                            startCol = 1, startRow = 3,
                            withFilter = show_filter,
                            borders = "all",
                            borderColour = "darkgrey",
                            borderStyle = "hair",
                            colNames = TRUE, rowNames = FALSE,
                            headerStyle = headerstyle)

        # Set the column widths
        openxlsx::setColWidths(wb, sheet = tab_name,
                               cols = 1:ncol(dd_tbl),
                               widths = c(10, # 1. path
                                          15, # 2. table
                                          25, # 3. display_name
                                          25, # 4. display_name_label
                                          40, # 5. field_description
                                          15, # 6. variable_type
                                          15, # 7. data_type
                                          10, # 8. units
                                          25, # 9. values
                                          25, # 10. notes
                                          25  # 11. links
                                          )
                               )

        openxlsx::addStyle(wb, sheet = tab_name, style = normal_text_style,
                           rows = 1:(nrow(dd_tbl)*1.1),
                           cols = c(1,2,3,4,6,7),
                           gridExpand = TRUE, stack = TRUE)

        # Define the columns to wrap
        openxlsx::addStyle(wb, sheet = tab_name, style = wrap_text_style,
                           rows = 1:(nrow(dd_tbl)*1.1),
                           cols = c(5,8,9,10,11),
                           gridExpand = TRUE, stack = TRUE)


        # Add back to home Hyperlink
        openxlsx::writeFormula(wb, sheet = tab_name,
                               x = '=HYPERLINK("#Home!A2","Back to Home Tab")',
                               startCol = 1, startRow = 1)

        openxlsx::addStyle(wb, sheet = tab_name,
                           style = back_to_home_text,
                           rows = 1, cols = 1)

    }


    purrr::imap(dictionary, ~add_dd_tbl(dd_tbl=.x, tab_name = .y,
                                        workbook = wb, show_filter = TRUE))


    cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                  cli::col_grey("Added dictionary sheets")
                  )

    # Data Validation and home tab ----
    if(!missing(hometab_filepath)){

        suppressWarnings({
            openxlsx::dataValidation(wb, 1, col = 6, rows = 3,
                                     type = "list",
                                     value = "=table_list!$A$2:$A$1000")
        })

        for (tab in seq_along(home_tab_sheets)) {

            openxlsx::addStyle(wb,
                               sheet = home_tab_sheets[[tab]],
                               style = home_tab_style,
                               rows = 1:1000,
                               cols = 1:250,
                               gridExpand = TRUE,
                               stack = TRUE)
            }


        openxlsx::addStyle(wb = wb,
                           sheet = 1,
                           style = dropdown_header_style,
                           cols = 6:12,
                           rows = 2,
                           gridExpand = T,
                           stack = T)

        openxlsx::addStyle(wb = wb,
                           sheet = 1,
                           style = dropdown_text_style,
                           cols = 6:12,
                           rows = 3,
                           gridExpand = T,
                           stack = T)

        # Add heading styles for home and reference tabs
        openxlsx::addStyle(wb = wb,
                           sheet = 1,
                           style = home_headerstyle,
                           cols = 1,
                           rows = 4,
                           stack = T)

        openxlsx::addStyle(wb = wb,
                           sheet = 1,
                           style = home_headerstyle,
                           cols = 2,
                           rows = 4,
                           stack = T)


        openxlsx::addStyle(wb = wb,
                           sheet = 1,
                           style = home_headerstyle,
                           cols = 1,
                           rows = 19,
                           stack = T)

        openxlsx::addStyle(wb = wb,
                           sheet = 2,
                           style = home_headerstyle,
                           cols = 1,
                           rows = 3,
                           stack = T)

        openxlsx::addStyle(wb = wb,
                           sheet = 2,
                           style = home_headerstyle,
                           cols = 1,
                           rows = 13,
                           stack = T)


}

    # Save the created workbook ----

    outfilename <- paste0(Sys.Date(),"_SDE_DD_",customer_agreement,".xlsx")

    outdir <- file.path(outfilepath, toupper(customer_name))

    if(!dir.exists(outdir)){

        dir.create(outdir)

        if(dir.exists(outdir)){

            cli::cat_line(cli::col_yellow(cli::symbol$info), " ",
                          cli::col_grey("Created Output Directory")
                          )
            }
        }

    cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                  cli::col_grey("Set Directory as: "),
                  cli::col_grey({outdir})
                  )


    if(file.exists(file.path(outdir, outfilename))){

        if(overwrite_existing){

            cli::cat_line(cli::col_yellow(cli::symbol$info), " ",
                          cli::col_grey("Overwriting: "),
                          cli::col_grey({file.path(outfilename)})
                          )

        }
    } else{

        cli::cat_line(cli::col_yellow(cli::symbol$info), " ",
                      cli::col_grey("writing: "),
                      cli::col_grey({file.path(outfilename)})
        )

    }

    openxlsx::saveWorkbook(wb,
                           file.path(outdir, outfilename),
                           overwrite = overwrite_existing)

    if(file.exists(file.path(outdir, outfilename))){

        cli::cat_line(cli::col_green(cli::symbol$tick), " ",
                          cli::col_green("Done!")
                          )

    }else{

        cli::cat_line(cli::col_red(cli::symbol$cross), " ",
                      cli::col_red("Not Done!")
        )


    }



}

#' Clean data dictionary table names
#'
#' This function cleans and standardises the data dictionary table names to
#' include/remove the financial year components and also accounts for the maximum
#' excel tab sheet name length (n = 31)
#'
#' @param table_names a character vector of table names
#' @param remove_fyear logical indicating if the financial year components should be removed
#' @return character vector of cleaned table names
#' @export
clean_table_names <- function(table_names, remove_fyear = FALSE){

    if(!is.character(table_names)) stop("table_names must be a character vector")

    if(length(table_names) <= 1) stop("table_names must be of length > 1")

    if(remove_fyear){

        new_names <- stringr::str_remove_all(table_names, "_\\{fyear\\}$")

        # Account for maximum tab name length (31)
        new_names[nchar(new_names) > 31] <- stringr::str_sub(new_names[nchar(new_names) > 31], 1, 31)

    }else{

        new_names <- stringr::str_replace_all(table_names, "_all_years$", "_{fyear}")

        fyear_tbls <- stringr::str_which(new_names, "^lowlat_|^csds_|^iapt_v2")

        new_names[fyear_tbls] <- paste0(new_names[fyear_tbls],"_{fyear}")

        # Hard-coded due to max excel tab length restriction
        new_names[new_names == "iapt_mental_and_physical_health_{fyear}"] <- "iapt_mental_and_physical_health_conditions_{fyear}"

        new_names[new_names == "ndrs_cancer_pathway"] <- "ndrs_cancer_at_pathway_dars_enhanced"
        new_names[new_names == "ndrs_cancer_tumour"] <- "ndrs_cancer_at_tumour_dars_enhanced"
        new_names[new_names ==  "ndrs_cancer_rapid_registration"] <- "ndrs_cancer_at_rapid_registrations_dars_enhanced"


        cancer_wait_times_tbl = grep("^cwt_", new_names)

        if(length(cancer_wait_times_tbl) == 1){
            new_names[cancer_wait_times_tbl] = "cancer_wait_times"
        } else stop("mulitple cancer wait time tables detected in data dictionary")

    }

    # replace any periods for underscores
    new_names <- stringr::str_replace_all(new_names, "\\.", "_")

    return(new_names)

}

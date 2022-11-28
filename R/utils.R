outputheader <- function(header_text, length = 49){


    out_header <- paste0(rep(cli::symbol$line, 2), collapse = "")

    out_header <- paste(out_header, header_text)

    if(length - nchar(out_header) - 1 >= 1){

        out_header <- paste0(out_header,
                             " ",
                             paste0(rep(cli::symbol$line,  length - nchar(out_header) - 1),
                                    collapse = "")
        )



        return(cli::col_cyan(out_header))

    }else{

        warning("header_text is to long: please increase length or shorten header")

    }



}

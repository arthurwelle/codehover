# flipbookr:::chunk_name_return_code_sequence("a_plot") ->
#   partial_code_list

#' prepare partial code for code hover from flipbookr partial code list
#'
#' @param partial_code_list full partial code sequence
#' @param which points to element in list
#'
#' @return partial code formatted in the code hover way.
#'
#' @examples
partial_code_ch_format <- function(partial_code_list, which){

  partial_code_list[[which]] %>%
    .[stringr::str_detect(. ,".+#<<")] %>%
    stringr::str_replace("#<<", "") %>%
    stringr::str_replace("^    ", "<tab2>") %>%
    stringr::str_replace("^  ", "<tab1>") %>%
    paste0(collapse = "<br>") ->
    out

  if(length(partial_code_list) != which) {

    out %>%
      paste(., "+") ->  # this will not always be true.  for ggplot okay.
      out
  }

  out

}


#' Produces the pipeline needed for hover reveal from partial code list ()
#'
#' @param partial_code_list flipbookr partial code sequences as a list
#' @param fig_path_and_prefix paths to figures (png), minus numbering and extensions ".png"
#'
#' @return
#' @export
#'
#' @examples
partial_code_ch_int_reduce <- function(partial_code_list, fig_path_and_prefix){

  purrr::reduce(.x = c(1:length(partial_code_list)),
                .f = ~ .x %>%
                  ch_row(text = partial_code_ch_format(partial_code_list, .y),
                         img = paste0(fig_path_and_prefix, .y, ".png")),
                .init = ch_int(type = "incremental", div_tag_add = " class='column'")
  )  %>%
    ch_out(img = paste0(fig_path_and_prefix,
                        length(partial_code_list), ".png"),
           div_tag_add = " class='column'")

}




#' Title
#'
#' @param chunk_name
#' @param path
#' @param fig_prefix
#'
#' @return
#'
#'
#' @examples
chunk_prepare_assets <- function(chunk_name = "example_name",
                                 fig_path = "code_hover_assets/",
                                 fig_prefix = paste0(chunk_name, "_figure" )){

  paste0(
    '```{r ', fig_prefix, ', code = flipbookr:::chunk_code_seq_as_vector("',
    chunk_name,
    '"), fig.show="hide", fig.path="', fig_path ,'", echo = F, message = F}
```') %>%
    knitr::knit(text = ., quiet = T) %>%
    paste(collapse = "\n")

}



#' refer to chunk that only has graphical output at every pause point
#' Build code hover, figures must be built separately at this point
#'
#' @param chunk_name refer to a code chunk by name
#' @param fig_path_and_prefix paths to figures (png), minus numbering and extensions ".png"
#'
#' @return
#' @export
#'
#' @examples
chunk_code_hover <- function(chunk_name = "example",
                             fig_path = "code_hover_assets/",
                             fig_prefix = paste0(chunk_name, "_figure"),
                             fig_path_and_prefix = paste0(fig_path, fig_prefix, "-")){

chunk_prepare_assets(chunk_name = chunk_name,
                     fig_path = fig_path,
                     fig_prefix = fig_prefix)

flipbookr:::chunk_name_return_code_sequence(chunk_name = chunk_name) %>%
    partial_code_ch_int_reduce(fig_path_and_prefix = fig_path_and_prefix) %>%
    htmltools::HTML()

}



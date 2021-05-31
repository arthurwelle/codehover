#' @title CodeHover initiate Table
#'
#' @description CodeHover initiate Table
#'
#' @param type type of hover effect, options are "one_row" or "incremental", the later highlights every prior row and the row curent hovered. Default is "incremental".
#' @param css_class Pass a CSS class name here as text to style the whole table.
#' @param ... Adicional paramethers
#'
#' @return The beggining of an HTML table to be passed to the function \code{ch_row}
#'
#' @export
#'
#'#'\dontrun{
#'ch_int(type = "one_row",
#'       css_class = "my_custom_table_css_class")
#'}
ch_int <- function(
  type = "incremental", # options are "one_row" or "incremental"
  css_class = "", # custom css
  ...) {

  pipe_table_css <- "pipehover_incremental"

  if(type == "one_row"){pipe_table_css <- "pipehover_select_one_row"}

  .data <- paste0("<div> <table class = '", pipe_table_css, " ", css_class, "'>")

  return(.data)
}


#' @title CodeHover add row
#'
#' @description CodeHover add row to the table and images to be linked to each row
#'
#' @param .data CodeHover object (string of text) created by ch_int.
#' @param text Text to be display in the table row.
#' @param img Path to the image. If url = TRUE the img should be a url link to a image.
#' @param url Default FALSE, if TRUE indicates that the image is hosted somewhere else and it should not be embeded in the HTML page via base64.
#' @param ... Adicional paramethers
#'
#' @return The populated HTML table to be passed to the function \code{ch_out}
#'
#' @export
#'
#'\dontrun{
#'ch_row(text = "Some code-text in a row",
#'       img = "./IMG/image1.png")
#'}
ch_row <- function(
  .data = "" ,
  text = "", # text inside the row
  img = "", # image or url
  url = FALSE, # set as TRUE to use a url link to an image hosted somewehere else
  ...){

  if(url){
    .data <- paste0(.data,  "<tr link='", img, "'><td>",text,"</td></tr> ")}else{
      v_img <-  htmltools::img(src = knitr::image_uri(img))[["attribs"]][["src"]]
      .data <- paste0(.data,  "<tr link='", v_img, "'><td>",text,"</td></tr> ")
    }
  return(.data)
}


#' @title CodeHover output
#'
#' @description CodeHover define image holder linked to the table
#'
#' @param .data CodeHover object (string of text) created by ch_row.
#' @param img_holder Image to be show in the image holder prior to any hover.
#' @param img_holder_css_class Pass a CSS class name here as text to style the image holder.
#' @param ... Adicional paramethers
#'
#' @return A HTML table as string ready to be passed to \code{htmltools::HMTL} and be render in the page.
#'
#' @export
#'
#'\dontrun{
#'ch_out(img_holder = "./IMG/image1.png")
#'}
ch_out <- function(
  .data = "" ,
  img_holder = "",
  img_holder_css_class = "",
  ...){

  v_img <-  htmltools::img(src = knitr::image_uri(img_holder))[["attribs"]][["src"]]
  .data <- paste0(.data,  "</table></div><div> <img id = 'img_holder' class='",img_holder_css_class,"' src='", v_img, "'/></div>")
  return(.data)
}

# usethis::create_github_token()
# gitcreds::gitcreds_set()
# usethis::use_git_config(user.name = "arthurwelle",
#                         user.email = "arthurwelle@yahoo.com")
#
#
# usethis::use_github()



#' @title codehover initiate Table
#'
#' @description Codehover initiate HTML table. Here you can adjust some HTML-style properties, and choose the type of hover effect.
#'
#' @param type (string) Type of hover effect, options are "one_row" or "incremental", the later highlights every prior row and the row curent hovered. Default is "incremental".
#' @param css_class (string) Pass a CSS class name here as text to style the whole table.
#' @param table_tag_add (string) Aditional html parameter for table tag.
#' @param div_tag_add (string) Aditional html parameter for div tag (table container).
#' @param ... Adicional paramethers
#'
#' @return The beggining of an HTML table to be passed to the function \code{ch_row}
#'
#' @export
ch_int <- function(
  type = "incremental", # options are "one_row" or "incremental"
  css_class = "", # custom css
  table_tag_add = "",
  div_tag_add = "",
  ...) {

  pipe_table_css <- "pipehover_incremental"

  if(type == "one_row"){pipe_table_css <- "pipehover_select_one_row"}

  .data <- paste0("<div ",div_tag_add,"> <table ",table_tag_add," class = '", pipe_table_css, " ", css_class, "'>")

  return(.data)
}


#' @title Codehover add row
#'
#' @description Codehover add row to the table and images to be linked to each row. You can create multiple lines piping various \code{ch_row}.
#'
#' @param .data Codehover object (text string) created by ch_int.
#' @param text (string) Text to be display inside the table row.
#' @param img (string) Path to the image. If url = TRUE the img should be a url link to a image.
#' @param url (Boolean) Default FALSE, if TRUE indicates that the image is hosted somewhere else and it should not be embeded in the HTML page via base64.
#' @param ... Adicional paramethers
#'
#' @return The populated HTML table to be passed to another \code{ch_row} function or to the \code{ch_out} function to finnish the table.
#'
#' @export
ch_row <- function(
  .data = "" ,
  text = "", # text inside the row
  img = "", # image or url
  url = FALSE, # set as TRUE to use a url link to an image hosted somewehere else
  ...){

  if(url){
    .data <- paste0(.data,  "<tr link='", img, "'><td>",text,"</td></tr> ")}else{
      img_base64 <-  htmltools::img(src = knitr::image_uri(img))[["attribs"]][["src"]]
      .data <- paste0(.data,  "<tr link='", img_base64, "'><td>",text,"</td></tr> ")
    }
  return(.data)
}


#' @title codehover output
#'
#' @description codehover define image holder linked to the table and controls some HTML atributes of this element.
#'
#' @param .data Codehover object (text string) created by ch_row.
#' @param img (string) Image to be show in the image holder prior to any hover interaction.If url = TRUE the img should be a url link to a image.
#' @param css_class (string) Pass a CSS class name here as text to style the image holder.
#' @param url (string) Default FALSE, if TRUE indicates that the image is hosted somewhere else and it should not be embeded in the HTML page via base64.
#' @param img_tag_add (string) Aditional html parameter for img tag
#' @param div_tag_add (string) Aditional html parameter for div tag (container)
#' @param ... Adicional paramethers
#'
#' @return A HTML table as string ready to be passed to \code{htmltools::HMTL} and be render as a hoverale table in the page.
#'
#' @export
ch_out <- function(
  .data = "" ,
  img = "",
  css_class = "",
  url = FALSE,
  img_tag_add = "",
  div_tag_add = "",
  ...){

  if(url){
    .data <- paste0(.data,  "</table></div><div> <img id = 'img_holder' class='",css_class,"' src='", img, "'/></div>")}else{
      img_base64 <-  htmltools::img(src = knitr::image_uri(img))[["attribs"]][["src"]]
      .data <- paste0(.data,  "</table></div><div ",div_tag_add," > <img ",img_tag_add,"id = 'img_holder' class='",css_class,"' src='", img_base64,"'/></div>")
    }
  return(.data)
}




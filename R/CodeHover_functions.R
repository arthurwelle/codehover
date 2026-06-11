#' @title codehover initiate table
#'
#' @description Starts a codehover HTML table. This is the low-level
#'   building-block API: use it when you want full control over the row
#'   text and the images (any images, any pseudo-code). For automatic
#'   splitting of ggplot code, see [ch_hover()].
#'
#' @param type (string) Type of hover effect, "one_row" or "incremental";
#'   the latter highlights the hovered row and every prior row.
#'   Default "incremental".
#' @param layout (string) Placement of the image relative to the code table:
#'   "auto" (default) puts them side by side when there is room and wraps
#'   the image below otherwise (responsive); "row" forces side by side,
#'   shrinking the image if needed; "column" forces the image below the
#'   code.
#' @param css_class (string) Extra CSS class added to the container, for
#'   custom styling.
#' @param table_tag_add (string) Additional HTML attributes for the
#'   `<table>` tag.
#' @param div_tag_add (string) Additional HTML attributes for the `<div>`
#'   wrapping the table.
#' @param ... Additional parameters.
#'
#' @return The beginning of an HTML table (string), to be passed to
#'   [ch_row()].
#'
#' @export
ch_int <- function(
  type = "incremental",
  layout = "auto",
  css_class = "",
  table_tag_add = "",
  div_tag_add = "",
  ...) {

  type_class <- if (type == "one_row") "codehover-onerow" else "codehover-incremental"

  layout_class <- switch(layout,
    row    = " codehover-layout-row",
    column = " codehover-layout-column",
    ""
  )

  paste0(
    "<div class='codehover ", type_class, layout_class, " ", css_class, "'>",
    "<div class='codehover-code' ", div_tag_add, "><table ", table_tag_add, ">"
  )
}


#' @title codehover add row
#'
#' @description Adds a row to the table and links an image to it. Pipe
#'   multiple `ch_row()` calls to build the table. Inside `text` you can
#'   use `<br>` for line breaks and `<tab1>` ... `<tab16>` for indentation.
#'
#' @param .data codehover string created by [ch_int()] or a previous
#'   [ch_row()].
#' @param text (string) Text displayed inside the row.
#' @param img (string) Path to the image, or a URL if `url = TRUE`.
#' @param url (logical) Default FALSE, which embeds the image into the HTML
#'   as base64. TRUE writes the path/URL as-is.
#' @param ... Additional parameters.
#'
#' @return The growing HTML table (string), to be passed to another
#'   [ch_row()] or finished with [ch_out()].
#'
#' @export
ch_row <- function(
  .data = "",
  text = "",
  img = "",
  url = FALSE,
  ...) {

  src <- if (url) img else knitr::image_uri(img)
  paste0(.data, "<tr data-link='", src, "'><td>", text, "</td></tr>")
}


#' @title codehover output
#'
#' @description Closes the table, adds the image holder and attaches the
#'   codehover CSS/JavaScript dependency. The result renders as-is in
#'   R Markdown, Quarto and the RStudio viewer -- no template or YAML
#'   set-up needed.
#'
#' @param .data codehover string created by [ch_row()].
#' @param img (string) Image shown before any hover interaction, or a URL
#'   if `url = TRUE`.
#' @param css_class (string) Extra CSS class for the image holder.
#' @param url (logical) Default FALSE, which embeds the image into the HTML
#'   as base64. TRUE writes the path/URL as-is.
#' @param img_tag_add (string) Additional HTML attributes for the `<img>`
#'   tag.
#' @param div_tag_add (string) Additional HTML attributes for the `<div>`
#'   wrapping the image.
#' @param ... Additional parameters.
#'
#' @return An htmltools tag list, rendered automatically in R Markdown,
#'   Quarto and the RStudio viewer.
#'
#' @export
ch_out <- function(
  .data = "",
  img = "",
  css_class = "",
  url = FALSE,
  img_tag_add = "",
  div_tag_add = "",
  ...) {

  src <- if (url) img else knitr::image_uri(img)

  html <- paste0(
    .data,
    "</table></div>",
    "<div class='codehover-img ", css_class, "' ", div_tag_add, ">",
    "<img ", img_tag_add, " src='", src, "'/>",
    "</div></div>"
  )

  htmltools::tagList(htmltools::HTML(html), ch_dependency())
}

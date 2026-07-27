#' @title codehover initiate table
#'
#' @description Starts a codehover HTML table. This is the low-level
#'   building-block API: use it when you want full control over the row
#'   text and the images (any images, any pseudo-code). For automatic
#'   splitting of ggplot code, see [ch_hover()].
#'
#' @param type (string) Type of hover effect, "incremental" (default,
#'   highlights the hovered row and every prior row) or "one_row".
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
#' @examples
#' ch_int(type = "one_row", layout = "column")
#'
#' @export
ch_int <- function(
  type = c("incremental", "one_row"),
  layout = c("auto", "row", "column"),
  css_class = "",
  table_tag_add = "",
  div_tag_add = "",
  ...) {

  type <- match.arg(type)
  layout <- match.arg(layout)

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
#'   use `<br>` for line breaks and `<span class="ch-tab1">` ...
#'   `<span class="ch-tab16">` for indentation (the bare `<tab1>` ...
#'   `<tab16>` tags used by earlier versions still work).
#'
#'   Rows are focusable (`tabindex="0"`), so the table can be driven by
#'   mouse hover, tap or keyboard (Tab plus arrow keys).
#'
#' @param .data codehover string created by [ch_int()] or a previous
#'   [ch_row()].
#' @param text (string) Text displayed inside the row.
#' @param img (string) Path to the image, or a URL if `url = TRUE`.
#' @param url (logical) Default FALSE, which embeds the image into the HTML
#'   as base64. TRUE writes the path/URL as-is.
#' @param alt (string) Alternative text for this row's image, used by
#'   screen readers when the row is activated. Default NULL keeps the
#'   alternative text set by [ch_out()].
#' @param ... Additional parameters.
#'
#' @return The growing HTML table (string), to be passed to another
#'   [ch_row()] or finished with [ch_out()].
#'
#' @examples
#' ch_row(ch_int(), text = "ggplot(cars, aes(speed, dist)) +",
#'        img = "step-1.png", url = TRUE, alt = "empty plot panel")
#'
#' @export
ch_row <- function(
  .data = "",
  text = "",
  img = "",
  url = FALSE,
  alt = NULL,
  ...) {

  src <- if (url) img else knitr::image_uri(img)
  alt_attr <- if (is.null(alt)) "" else
    paste0(" data-alt='", htmltools::htmlEscape(alt, attribute = TRUE), "'")

  paste0(.data, "<tr data-link='", src, "'", alt_attr, " tabindex='0'>",
         "<td>", text, "</td></tr>")
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
#' @param alt (string) Alternative text of the image holder. Default
#'   "codehover plot"; rows can override it while they are active via the
#'   `alt` argument of [ch_row()].
#' @param aspect (numeric, length 2) Width and height used to reserve the
#'   image box (`aspect-ratio` in CSS), so the page does not reflow when a
#'   hovered image loads. Default NULL leaves it to the browser.
#' @param preload (character) Image URLs to fetch up front, so hovering a
#'   row does not flicker while the file downloads. Only meaningful when
#'   `url = TRUE` (base64 images are already in the page).
#' @param caption (string) Optional caption shown under the image.
#' @param img_tag_add (string) Additional HTML attributes for the `<img>`
#'   tag.
#' @param div_tag_add (string) Additional HTML attributes for the `<div>`
#'   wrapping the image.
#' @param ... Additional parameters.
#'
#' @return An htmltools tag list, rendered automatically in R Markdown,
#'   Quarto and the RStudio viewer.
#'
#' @examples
#' ch_out(ch_row(ch_int(), text = "geom_point()", img = "step-1.png",
#'               url = TRUE),
#'        img = "step-1.png", url = TRUE, alt = "scatter plot")
#'
#' @export
ch_out <- function(
  .data = "",
  img = "",
  css_class = "",
  url = FALSE,
  alt = "codehover plot",
  aspect = NULL,
  preload = NULL,
  caption = NULL,
  img_tag_add = "",
  div_tag_add = "",
  ...) {

  src <- if (url) img else knitr::image_uri(img)

  style <- ""
  if (!is.null(aspect)) {
    if (length(aspect) != 2 || !is.numeric(aspect)) {
      stop("`aspect` must be a numeric vector of length 2 (width, height).",
           call. = FALSE)
    }
    style <- paste0(" style='--codehover-aspect: ", aspect[1], " / ",
                    aspect[2], ";'")
  }

  preload_html <- ""
  if (length(preload) > 0) {
    preload_html <- paste0(
      "<div class='codehover-preload' aria-hidden='true'>",
      paste0("<img src='", preload, "' alt=''/>", collapse = ""),
      "</div>"
    )
  }

  caption_html <- if (is.null(caption)) "" else
    paste0("<div class='codehover-caption'>", caption, "</div>")

  html <- paste0(
    .data,
    "</table></div>",
    "<div class='codehover-img ", css_class, "'", style, " ", div_tag_add, ">",
    "<img ", img_tag_add, " src='", src,
    "' alt='", htmltools::htmlEscape(alt, attribute = TRUE), "'/>",
    caption_html,
    preload_html,
    "</div></div>"
  )

  htmltools::tagList(htmltools::HTML(html), ch_dependency())
}

#' @title codehover HTML dependency
#'
#' @description Returns the htmltools dependency (CSS + JavaScript) that
#'   makes codehover tables interactive. It is attached automatically by
#'   [ch_hover()] and [ch_out()], so you rarely need to call this yourself.
#'   Useful if you build the HTML manually and only want the assets.
#'
#' @return An [htmltools::htmlDependency()] object.
#'
#' @export
ch_dependency <- function() {
  htmltools::htmlDependency(
    name = "codehover",
    version = "1.0.0",
    src = c(file = system.file("assets", package = "codehover")),
    stylesheet = "codehover.css",
    script = "codehover.js"
  )
}

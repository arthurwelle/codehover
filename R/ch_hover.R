#' @title Automatic code hover from a ggplot expression
#'
#' @description Takes ggplot code, splits it at every top-level `+`,
#'   evaluates each cumulative step, renders one image per step and returns
#'   a self-contained hoverable HTML table (CSS and JavaScript travel with
#'   it -- no template or YAML set-up needed). Hovering a row of code shows
#'   the plot as it looks up to that step.
#'
#' @param code The plot code. Either an expression wrapped in braces, as
#'   in the example below, or a character string/vector of code lines.
#' @param type (string) Hover effect: "incremental" (default, highlights
#'   the hovered row and every prior row) or "one_row".
#' @param layout (string) Placement of the image relative to the code table:
#'   "auto" (default) puts them side by side when there is room and wraps
#'   the image below otherwise (responsive); "row" forces side by side,
#'   shrinking the image if needed; "column" forces the image below the
#'   code.
#' @param fixed_scales (logical) Default FALSE: each step shows the true
#'   output of its partial code, so axes and legends may change between
#'   steps. TRUE pins scales, axes and panel layout from the final plot so
#'   the reveal is visually stable (mechanism borrowed from the ggreveal
#'   package by Weverthon Machado).
#' @param width,height (numeric) Image size in inches. Default 7 x 5.
#' @param dpi (numeric) Image resolution. Default 96.
#' @param path (string) Default NULL: step images are written to a
#'   temporary folder, embedded into the HTML as base64 and deleted.
#'   Give a folder path (e.g. "codehover_assets/") to keep numbered PNG
#'   files on disk and reference them by relative path instead (smaller
#'   HTML, but the folder must ship with the page).
#' @param name (string) File-name prefix for the step images. Default
#'   "codehover".
#' @param css_class (string) Extra CSS class added to the container.
#' @param alt (character) Alternative text for the step images, used by
#'   screen readers. Either one string per step or a single string reused
#'   by every step. Default NULL builds "Plot after step i of n: <code>".
#' @param caption (string) Optional caption shown under the image.
#' @param initial (string or number) Which step's image is shown before any
#'   interaction: "last" (default), "first" or a step number.
#' @param env Environment in which the code is evaluated. Default
#'   `parent.frame()`.
#'
#' @return An htmltools tag list, rendered automatically in R Markdown,
#'   Quarto and the RStudio viewer.
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ch_hover({
#'     ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'       ggplot2::geom_point() +
#'       ggplot2::geom_smooth(method = "lm")
#'   })
#' }
#'
#' @export
ch_hover <- function(code,
                     type = c("incremental", "one_row"),
                     layout = c("auto", "row", "column"),
                     fixed_scales = FALSE,
                     width = 7,
                     height = 5,
                     dpi = 96,
                     path = NULL,
                     name = "codehover",
                     css_class = "",
                     alt = NULL,
                     caption = NULL,
                     initial = "last",
                     env = parent.frame()) {

  type <- match.arg(type)
  layout <- match.arg(layout)

  code_sub <- substitute(code)
  lines <- ch_resolve_code(code, code_sub)

  steps <- ch_split_code(lines)
  plots <- lapply(steps, function(s) eval(parse(text = s$code), envir = env))

  imgs <- ch_render_steps(plots, fixed_scales = fixed_scales,
                          width = width, height = height, dpi = dpi,
                          path = path, name = name)

  use_url <- !is.null(path)
  alts <- ch_step_alt(steps, alt)
  first <- ch_initial_index(initial, length(steps))

  html <- ch_int(type = type, layout = layout, css_class = css_class)
  for (i in seq_along(steps)) {
    html <- ch_row(html, text = ch_format_step(steps[[i]]$lines),
                   img = imgs[i], url = use_url, alt = alts[i])
  }
  out <- ch_out(html, img = imgs[first], url = use_url, alt = alts[first],
                aspect = c(width, height), caption = caption,
                preload = if (use_url) imgs else NULL)

  if (is.null(path)) unlink(imgs)

  out
}


# alternative text for each step's image
ch_step_alt <- function(steps, alt) {

  n <- length(steps)

  if (!is.null(alt)) {
    if (length(alt) == 1) return(rep(alt, n))
    if (length(alt) != n) {
      stop("`alt` must have one element per step (", n, ") or exactly one.",
           call. = FALSE)
    }
    return(alt)
  }

  vapply(seq_len(n), function(i) {
    last_line <- trimws(steps[[i]]$lines[length(steps[[i]]$lines)])
    paste0("Plot after step ", i, " of ", n, ": ", last_line)
  }, character(1))
}


# resolve the `initial` argument into a step index
ch_initial_index <- function(initial, n) {

  if (is.numeric(initial)) {
    idx <- as.integer(initial)
    if (length(idx) != 1 || is.na(idx) || idx < 1 || idx > n) {
      stop("`initial` must be \"first\", \"last\" or a step number between 1 and ",
           n, ".", call. = FALSE)
    }
    return(idx)
  }

  switch(initial,
    last  = n,
    first = 1L,
    stop("`initial` must be \"first\", \"last\" or a step number.",
         call. = FALSE)
  )
}


#' @title Automatic code hover from a knitr chunk
#'
#' @description Reads the code of a named knitr chunk (via the public
#'   `knitr::knit_code` API) and passes it to [ch_hover()]. This keeps the
#'   source document clean: write the plot in a normal chunk with
#'   `eval=FALSE`, then call `ch_hover_chunk("<label>")` inline or in a
#'   later chunk.
#'
#' @param label (string) The chunk label.
#' @param ... Passed on to [ch_hover()].
#'
#' @return See [ch_hover()].
#'
#' @examples
#' \dontrun{
#' # ```{r myplot, eval=FALSE}
#' # ggplot(mtcars, aes(wt, mpg)) +
#' #   geom_point()
#' # ```
#' # `r ch_hover_chunk("myplot")`
#' }
#'
#' @export
ch_hover_chunk <- function(label, ...) {
  lines <- knitr::knit_code$get(label)
  if (is.null(lines)) {
    stop("No knitr chunk named '", label, "' found.", call. = FALSE)
  }
  ch_hover(as.character(lines), name = label, env = knitr::knit_global(), ...)
}


# resolve the `code` argument of ch_hover into source lines
ch_resolve_code <- function(code_value, code_sub) {

  is_brace <- is.call(code_sub) && identical(code_sub[[1]], as.name("{"))

  if (!is_brace && !ch_is_plus_chain(code_sub)) {
    # not plot code written in place: `code` must be a character object
    # (string literal, variable holding code lines, knit_code result, ...)
    if (is.character(code_value)) {
      return(unlist(strsplit(code_value, "\n"), use.names = FALSE))
    }
    stop("Pass the plot code inside braces, ",
         "e.g. ch_hover({ ggplot(...) + ... }), ",
         "or as a character string.", call. = FALSE)
  }

  # code written in place with source refs kept: use verbatim source
  src <- attr(code_sub, "srcref")
  if (!is.null(src)) {
    # for a braced block the first srcref is the "{" token itself: drop it
    if (is_brace) src <- src[-1]
    candidate <- unlist(lapply(src, as.character), use.names = FALSE)
    # Validate: knitr's srcref column positions can be off (e.g. last_col
    # lands on an opening `"` instead of past the closing one, yielding an
    # INCOMPLETE_STRING error).  A dry parse catches that cheaply.
    ok <- tryCatch({
      parse(text = paste(candidate, collapse = "\n"))
      TRUE
    }, error = function(e) FALSE)
    if (ok) return(candidate)
  }

  # no source available (or srcref produced invalid code): rebuild from call tree
  ch_expr_to_lines(code_sub)
}


ch_is_plus_chain <- function(e) {
  is.call(e) && length(e) == 3 && identical(e[[1]], as.name("+"))
}


# render one PNG per step, return file paths
ch_render_steps <- function(plots, fixed_scales, width, height, dpi,
                            path, name) {

  n <- length(plots)

  drawables <- plots
  if (fixed_scales && n > 1) {
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("fixed_scales = TRUE requires the ggplot2 package.", call. = FALSE)
    }
    if (all(vapply(plots, inherits, logical(1), what = "ggplot"))) {
      final_build <- ggplot2::ggplot_build(plots[[n]])
      drawables <- lapply(seq_len(n), function(i) {
        if (i == n) return(plots[[i]])
        b <- ggplot2::ggplot_build(plots[[i]])
        b$layout <- final_build$layout
        b$plot$scales <- final_build$plot$scales
        ggplot2::ggplot_gtable(b)
      })
    } else {
      warning("fixed_scales = TRUE only works when every step is a ggplot; ",
              "falling back to free scales.", call. = FALSE)
    }
  }

  if (is.null(path)) {
    files <- vapply(seq_len(n), function(i) {
      tempfile(pattern = paste0(name, "-", i, "-"), fileext = ".png")
    }, character(1))
  } else {
    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    files <- file.path(path, paste0(name, "-", seq_len(n), ".png"))
  }

  has_ragg <- requireNamespace("ragg", quietly = TRUE)
  failed <- integer(0)

  for (i in seq_len(n)) {
    if (has_ragg) {
      ragg::agg_png(files[i], width = width, height = height,
                    units = "in", res = dpi)
    } else {
      grDevices::png(files[i], width = width, height = height,
                     units = "in", res = dpi)
    }
    tryCatch({
      d <- drawables[[i]]
      if (inherits(d, "gtable")) {
        grid::grid.newpage()
        grid::grid.draw(d)
      } else {
        print(d)
      }
    }, error = function(e) {
      # A step may legitimately fail on its own (e.g. after_stat() in the
      # global aes when no geom has been added yet).  Draw a blank page so
      # the table still renders; the image for that row will be empty.
      failed[[length(failed) + 1L]] <<- i
      message("codehover: step ", i, " cannot be rendered on its own (",
              conditionMessage(e), "). Its image will be blank.")
      grid::grid.newpage()
    }, finally = grDevices::dev.off())
  }

  attr(files, "failed") <- failed
  files
}

#' @title Split ggplot code into incremental steps
#'
#' @description Splits code at every top-level `+` (a `+` at the end of a
#'   line, outside any parentheses, brackets or braces). Lines ending in
#'   `%>%` or `|>` continue the current step, so a data-wrangling pipe
#'   feeding into `ggplot()` counts as a single first step.
#'
#' @param lines (character) Code as a vector of lines.
#'
#' @return A list of steps. Each step is a list with:
#'   \itemize{
#'     \item `lines`: the verbatim source lines belonging to this step.
#'     \item `code`: the cumulative code (steps 1..i) ready to be parsed
#'       and evaluated (trailing `+` removed).
#'   }
#'
#' @keywords internal
ch_split_code <- function(lines) {

  # drop leading/trailing blank lines
  non_blank <- which(trimws(lines) != "")
  if (length(non_blank) == 0) stop("No code to split.", call. = FALSE)
  lines <- lines[min(non_blank):max(non_blank)]

  # for depth counting, blank out string literals and comments
  # (naive but covers normal ggplot code)
  bare <- gsub("\\\\.", "", lines)              # escaped chars
  bare <- gsub('"[^"]*"', '""', bare)           # double-quoted strings
  bare <- gsub("'[^']*'", "''", bare)           # single-quoted strings
  bare <- sub("#.*$", "", bare)                 # comments

  opens  <- vapply(bare, function(l) sum(strsplit(l, "")[[1]] %in% c("(", "[", "{")), 0L, USE.NAMES = FALSE)
  closes <- vapply(bare, function(l) sum(strsplit(l, "")[[1]] %in% c(")", "]", "}")), 0L, USE.NAMES = FALSE)
  depth  <- cumsum(opens - closes)

  # a boundary is a line at depth 0 whose code (sans comment) ends with "+"
  boundary <- depth == 0 & grepl("\\+\\s*$", trimws(bare))

  # group lines into steps: a step ends at each boundary line;
  # everything after the last boundary is the final step
  step_id <- cumsum(c(0, utils::head(boundary, -1))) + 1
  steps_lines <- split(lines, step_id)

  lapply(seq_along(steps_lines), function(i) {
    cumulative <- unlist(steps_lines[seq_len(i)], use.names = FALSE)
    # strip the trailing "+" of this step so the cumulative code parses
    last <- length(cumulative)
    cumulative[last] <- sub("\\+\\s*$", "", sub("#.*$", "", cumulative[last]))
    list(
      lines = steps_lines[[i]],
      code  = paste(cumulative, collapse = "\n")
    )
  })
}


#' @title Split a captured expression into incremental steps
#'
#' @description Fallback used when no source text is available (e.g. inside
#'   knitr with `keep.source = FALSE`): walks the call tree of top-level
#'   `+` calls and deparses each term, producing conventionally formatted
#'   lines that [ch_split_code()] can consume.
#'
#' @param expr A captured (unevaluated) expression. A braced block is
#'   unwrapped; only its last expression is split (earlier statements are
#'   kept as a preamble of step 1).
#'
#' @return Character vector of code lines.
#'
#' @keywords internal
ch_expr_to_lines <- function(expr) {

  preamble <- character(0)
  if (is.call(expr) && identical(expr[[1]], as.name("{"))) {
    body <- as.list(expr)[-1]
    if (length(body) == 0) stop("Empty code block.", call. = FALSE)
    if (length(body) > 1) {
      preamble <- unlist(lapply(body[-length(body)], deparse), use.names = FALSE)
    }
    expr <- body[[length(body)]]
  }

  # collect terms of the top-level `+` chain (left-assoc: ((a + b) + c))
  terms <- list()
  while (is.call(expr) && identical(expr[[1]], as.name("+")) && length(expr) == 3) {
    terms <- c(list(expr[[3]]), terms)
    expr <- expr[[2]]
  }
  terms <- c(list(expr), terms)

  out <- character(0)
  for (i in seq_along(terms)) {
    d <- deparse(terms[[i]])
    if (i > 1) d <- paste0("  ", d)            # indent continuation terms
    if (i < length(terms)) d[length(d)] <- paste0(d[length(d)], " +")
    out <- c(out, d)
  }
  c(preamble, out)
}


#' @title Format one step's source lines for display in the hover table
#'
#' @description HTML-escapes the code, converts leading spaces to
#'   `<tabN>` indentation tags (one level per two spaces) and joins
#'   lines with `<br>`.
#'
#' @param lines (character) Verbatim source lines of one step.
#'
#' @return A single HTML string.
#'
#' @keywords internal
ch_format_step <- function(lines) {

  fmt <- vapply(lines, function(l) {
    n_spaces <- nchar(l) - nchar(sub("^ *", "", l))
    level <- min(n_spaces %/% 2, 16)
    txt <- htmltools::htmlEscape(trimws(l, which = "left"))
    if (level > 0) txt <- paste0("<tab", level, ">", txt, "</tab", level, ">")
    txt
  }, character(1), USE.NAMES = FALSE)

  paste(fmt, collapse = "<br>")
}

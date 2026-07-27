test_that("ch_int validates type and layout", {
  expect_match(ch_int(), "codehover-incremental")
  expect_match(ch_int(type = "one_row"), "codehover-onerow")
  expect_match(ch_int(layout = "row"), "codehover-layout-row")
  expect_match(ch_int(layout = "column"), "codehover-layout-column")
  expect_no_match(ch_int(layout = "auto"), "codehover-layout")

  # regression: typos used to fall back to the default silently
  expect_error(ch_int(type = "incrementall"), "'arg' should be one of")
  expect_error(ch_int(layout = "colunm"), "'arg' should be one of")
})

test_that("ch_row emits a focusable row with the image link", {
  html <- ch_row(ch_int(), text = "geom_point()", img = "a.png", url = TRUE)

  expect_match(html, "<tr data-link='a.png'", fixed = TRUE)
  expect_match(html, "tabindex='0'", fixed = TRUE)
  expect_match(html, "<td>geom_point()</td>", fixed = TRUE)
})

test_that("ch_row carries per-row alternative text, escaped", {
  html <- ch_row(ch_int(), img = "a.png", url = TRUE, alt = "it's a <plot>")

  expect_match(html, "data-alt='it&#39;s a &lt;plot&gt;'", fixed = TRUE)
})

test_that("ch_out closes the table and attaches the dependency", {
  out <- ch_out(ch_row(ch_int(), img = "a.png", url = TRUE),
                img = "a.png", url = TRUE)

  expect_s3_class(out, "shiny.tag.list")
  deps <- Filter(function(x) inherits(x, "html_dependency"), out)
  expect_length(deps, 1)
  expect_equal(deps[[1]]$name, "codehover")

  html <- as.character(out)
  expect_match(html, "</table></div>", fixed = TRUE)
  expect_match(html, "alt='codehover plot'", fixed = TRUE)
})

test_that("ch_out reserves the image box and preloads step images", {
  html <- as.character(
    ch_out(ch_int(), img = "a.png", url = TRUE, aspect = c(7, 5),
           preload = c("a.png", "b.png"), caption = "figure 1")
  )

  expect_match(html, "--codehover-aspect: 7 / 5;", fixed = TRUE)
  expect_match(html, "codehover-preload", fixed = TRUE)
  expect_match(html, "<img src='b.png' alt=''/>", fixed = TRUE)
  expect_match(html, "<div class='codehover-caption'>figure 1</div>",
               fixed = TRUE)
})

test_that("ch_out rejects a malformed aspect", {
  expect_error(ch_out(img = "a.png", url = TRUE, aspect = 7),
               "length 2")
})

test_that("the shipped assets are complete", {
  css <- system.file("assets", "codehover.css", package = "codehover")
  js  <- system.file("assets", "codehover.js", package = "codehover")

  expect_true(file.exists(css))
  expect_true(file.exists(js))

  css_src <- paste(readLines(css, warn = FALSE), collapse = "\n")
  # the highlight must survive Bootstrap's `.table`, which paints every
  # cell with its own background and an inset box-shadow
  expect_match(css_src, ".codehover tr.hover > td", fixed = TRUE)
  expect_match(css_src, "--codehover-highlight: #F1D95A", fixed = TRUE)

  js_src <- readLines(js, warn = FALSE)
  # hover, tap and keyboard must all be wired up
  expect_true(any(grepl('"mouseover"', js_src, fixed = TRUE)))
  expect_true(any(grepl('"click"', js_src, fixed = TRUE)))
  expect_true(any(grepl('"focusin"', js_src, fixed = TRUE)))
  expect_true(any(grepl('"keydown"', js_src, fixed = TRUE)))
})

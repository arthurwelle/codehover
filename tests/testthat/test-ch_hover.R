skip_if_not_installed("ggplot2")

suppressWarnings(library(ggplot2))

n_rows <- function(html) {
  length(regmatches(html, gregexpr("<tr data-link=", html, fixed = TRUE))[[1]])
}

# src of the image holder (the image shown before any interaction)
holder_src <- function(html) {
  holder <- sub(".*<div class='codehover-img", "", html)
  sub("^[^>]*><img[^>]*src='([^']*)'.*$", "\\1", holder)
}

test_that("ch_hover builds one row per step plus one image holder", {
  out <- ch_hover({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point() +
      theme_bw()
  })

  html <- as.character(out)
  expect_equal(n_rows(html), 3)
  expect_match(html, "codehover-img", fixed = TRUE)
  # images are embedded, nothing left behind on disk
  expect_match(html, "data:image/png;base64,", fixed = TRUE)
})

test_that("ch_hover accepts code as a character vector", {
  out <- ch_hover(c(
    "ggplot(mtcars, aes(wt, mpg)) +",
    "  geom_point()"
  ))

  expect_equal(n_rows(as.character(out)), 2)
})

test_that("ch_hover rejects code that is neither plot code nor a string", {
  expect_error(ch_hover(42), "inside braces")
})

test_that("double-quoted strings survive the srcref path", {
  # regression: knitr srcrefs could truncate at the opening quote, so the
  # cumulative code failed to parse (INCOMPLETE_STRING)
  code <- c(
    'ggplot(mtcars, aes(wt, mpg)) +',
    '  geom_point(color = "firebrick") +',
    '  labs(title = "a title")'
  )

  expect_equal(n_rows(as.character(ch_hover(code))), 3)
})

test_that("path = keeps numbered files and preloads them", {
  dir <- tempfile("codehover-assets")
  out <- ch_hover(c("ggplot(mtcars, aes(wt, mpg)) +", "  geom_point()"),
                  path = dir, name = "step")

  files <- list.files(dir)
  expect_setequal(files, c("step-1.png", "step-2.png"))

  html <- as.character(out)
  expect_match(html, "step-2.png", fixed = TRUE)
  expect_match(html, "codehover-preload", fixed = TRUE)
  expect_false(grepl("data:image/png;base64,", html, fixed = TRUE))
})

test_that("alt text is generated per step and can be overridden", {
  code <- c("ggplot(mtcars, aes(wt, mpg)) +", "  geom_point()")

  html <- as.character(ch_hover(code))
  expect_match(html, "Plot after step 1 of 2", fixed = TRUE)

  html <- as.character(ch_hover(code, alt = c("empty panel", "scatter")))
  expect_match(html, "data-alt='empty panel'", fixed = TRUE)
  expect_match(html, "data-alt='scatter'", fixed = TRUE)

  expect_error(ch_hover(code, alt = c("a", "b", "c")), "one element per step")
})

test_that("initial selects the image shown before interaction", {
  code <- c("ggplot(mtcars, aes(wt, mpg)) +", "  geom_point()")
  dir <- tempfile("codehover-assets")

  html <- as.character(ch_hover(code, path = dir, name = "s"))
  expect_equal(basename(holder_src(html)), "s-2.png")

  html <- as.character(ch_hover(code, path = dir, name = "s",
                                initial = "first"))
  expect_equal(basename(holder_src(html)), "s-1.png")

  expect_error(ch_hover(code, initial = "middle"), "must be")
  expect_error(ch_hover(code, initial = 9), "must be")
})

test_that("caption is rendered under the image", {
  out <- ch_hover(c("ggplot(mtcars, aes(wt, mpg)) +", "  geom_point()"),
                  caption = "Figure 1: cars")

  expect_match(as.character(out), "Figure 1: cars", fixed = TRUE)
})

test_that("fixed_scales pins the layout of the final plot", {
  code <- c("ggplot(mtcars, aes(wt, mpg)) +",
            "  geom_point() +",
            "  scale_x_continuous(limits = c(0, 10))")

  expect_equal(n_rows(as.character(ch_hover(code, fixed_scales = TRUE))), 3)
})

test_that("a step that cannot render alone yields a blank image and a message", {
  code <- c("ggplot(mtcars, aes(wt, after_stat(density))) +",
            "  geom_histogram()")

  expect_message(out <- ch_hover(code), "cannot be rendered on its own")
  expect_equal(n_rows(as.character(out)), 2)
})

test_that("ch_hover_chunk errors on an unknown chunk", {
  expect_error(ch_hover_chunk("no-such-chunk"), "No knitr chunk named")
})

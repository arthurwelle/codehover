test_that("code is split at every top-level +", {
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed, dist)) +",
    "  geom_point() +",
    "  theme_bw()"
  ))

  expect_length(s, 3)
  expect_equal(s[[1]]$lines, "ggplot(cars, aes(speed, dist)) +")
  expect_equal(s[[1]]$code, "ggplot(cars, aes(speed, dist)) ")
  expect_equal(s[[3]]$lines, "  theme_bw()")
})

test_that("cumulative code of every step parses", {
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed, dist)) +",
    "  geom_point(color = 'red') +",
    "  labs(title = 'a + b') +",
    "  theme_bw()"
  ))

  for (step in s) {
    expect_silent(parse(text = step$code))
  }
})

test_that("a + inside parentheses is not a boundary", {
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed +",
    "                 1, dist)) +",
    "  geom_point()"
  ))

  expect_length(s, 2)
  expect_length(s[[1]]$lines, 2)
})

test_that("hex colours are not eaten by comment stripping", {
  # regression: sub('#.*$') used to destroy '#1D8565' and leave an
  # unterminated string, so parse() failed with INCOMPLETE_STRING
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed, dist)) +",
    "  geom_point(color = \"#1D8565\") +",
    "  theme_bw()"
  ))

  expect_length(s, 3)
  expect_true(grepl("#1D8565", s[[2]]$code, fixed = TRUE))
  expect_silent(parse(text = s[[2]]$code))
})

test_that("real trailing comments are stripped from the cumulative code", {
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed, dist)) + # start here",
    "  geom_point()"
  ))

  expect_length(s, 2)
  expect_false(grepl("start here", s[[1]]$code, fixed = TRUE))
  # the displayed source keeps the comment
  expect_true(grepl("start here", s[[1]]$lines, fixed = TRUE))
  expect_silent(parse(text = s[[1]]$code))
})

test_that("a comment-only line does not start a step", {
  s <- ch_split_code(c(
    "ggplot(cars, aes(speed, dist)) +",
    "  # a comment",
    "  geom_point()"
  ))

  expect_length(s, 2)
  expect_length(s[[2]]$lines, 2)
})

test_that("pipe lines continue the current step", {
  skip_if(getRversion() < "4.1.0", "native pipe needs R >= 4.1")

  s <- ch_split_code(c(
    "cars |>",
    "  subset(speed > 5) |>",
    "  ggplot(aes(speed, dist)) +",
    "  geom_point()"
  ))

  expect_length(s, 2)
  expect_length(s[[1]]$lines, 3)
  expect_silent(parse(text = s[[1]]$code))
})

test_that("magrittr pipes behave like native pipes", {
  s <- ch_split_code(c(
    "cars %>%",
    "  ggplot(aes(speed, dist)) +",
    "  geom_point()"
  ))

  expect_length(s, 2)
  expect_length(s[[1]]$lines, 2)
})

test_that("leading and trailing blank lines are dropped", {
  s <- ch_split_code(c("", "ggplot(cars) +", "  geom_blank()", "", ""))

  expect_length(s, 2)
  expect_equal(s[[1]]$lines, "ggplot(cars) +")
})

test_that("empty input errors", {
  expect_error(ch_split_code(c("", "  ")), "No code to split")
})

test_that("ch_expr_to_lines rebuilds one line per + term", {
  e <- quote(ggplot(cars) + geom_point() + theme_bw())
  lines <- ch_expr_to_lines(e)

  expect_length(lines, 3)
  expect_match(lines[1], "\\+$")
  expect_match(lines[3], "theme_bw\\(\\)$")
  expect_silent(parse(text = paste(lines, collapse = "\n")))
})

test_that("ch_expr_to_lines keeps earlier statements as a preamble", {
  e <- quote({
    d <- cars
    ggplot(d) + geom_point()
  })
  lines <- ch_expr_to_lines(e)

  expect_equal(lines[1], "d <- cars")
  expect_length(ch_split_code(lines), 2)
})

test_that("ch_format_step escapes html and indents with span classes", {
  html <- ch_format_step(c("ggplot(d, aes(x < 1)) +", "    geom_point()"))

  expect_match(html, "&lt;", fixed = TRUE)
  expect_match(html, "<br>", fixed = TRUE)
  expect_match(html, "<span class='ch-tab2'>", fixed = TRUE)
})

test_that("indentation is capped at 16 levels", {
  html <- ch_format_step(paste0(strrep(" ", 80), "geom_point()"))

  expect_match(html, "ch-tab16", fixed = TRUE)
})

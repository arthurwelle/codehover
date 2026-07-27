# codehover 1.0.0

First stable release, and a full rewrite of the package. The previous
release on GitHub was 0.0.1.

## New automatic API

* `ch_hover()` is the new main entry point. Give it ggplot code (inside
  braces, or as a character vector) and it splits the code at every
  top-level `+`, renders one image per step and returns a self-contained
  hoverable table:

  ```r
  ch_hover({
    ggplot(mtcars, aes(wt, mpg)) +
      geom_point() +
      geom_smooth(method = "lm")
  })
  ```

* `ch_hover_chunk("label")` does the same for the code of a named knitr
  chunk, so the plot can live in a normal `eval=FALSE` chunk.

* Output is self-contained: CSS and JavaScript travel with the object as
  an `htmltools` dependency, and step images are embedded as base64. No
  template, no YAML set-up, no jQuery. Works in R Markdown, Quarto and
  the RStudio viewer.

* `fixed_scales = TRUE` pins scales, axes and panel layout from the final
  plot so the reveal is visually stable (mechanism borrowed from the
  ggreveal package by Weverthon Machado). The default, `FALSE`, shows the
  honest output of each partial step.

* `layout` controls the placement of the image: `"auto"` (responsive,
  default), `"row"` or `"column"`.

* `path =` keeps numbered PNG files on disk and links them instead of
  embedding them, for pages with many steps.

## Accessibility and interaction

* Rows now respond to **tap** and to the **keyboard**, not only to mouse
  hover: rows are focusable (`tabindex="0"`), Arrow Up/Down moves between
  them and Enter/Space activates one. Hover tables were previously
  unusable on phones and tablets.

* Images carry alternative text. `ch_hover(alt =)` sets it per step
  (default: "Plot after step i of n: <code>"), `ch_row(alt =)` does it in
  the manual API.

* `caption =` adds a caption under the image; `initial =` chooses which
  step's image is shown before any interaction (`"last"` by default).

## Appearance

* The CSS exposes custom properties for theming, e.g.

  ```css
  .codehover { --codehover-highlight: #cde7ff; --codehover-font: monospace; }
  ```

  plus `--codehover-highlight-fg`, `--codehover-font-size`,
  `--codehover-gap`, `--codehover-row-padding`, `--codehover-tab` and
  `--codehover-focus`. A dark-scheme default is applied automatically via
  `prefers-color-scheme`.

* The image box is reserved from the plot's aspect ratio, so the page no
  longer reflows when a hovered image is shown, and step images are
  preloaded when `path =` is used (no flicker on first hover).

* Indentation is emitted as `<span class="ch-tab1">` ... `<span
  class="ch-tab16">` instead of the invalid custom elements `<tab1>` ...
  `<tab16>`. The old tags are still styled, so hand-written tables from
  earlier versions keep working.

## Breaking changes

* **flipbookr is no longer used or suggested.** The old automatic mode
  depended on flipbookr internals; the package now has its own splitter.

* **`ch_out()` returns a renderable `htmltools` tag list**, not a string.
  Do not wrap it in `htmltools::HTML()` any more:

  ```r
  # before
  htmltools::HTML(ch_out(x, img = "final.png"))
  # now
  ch_out(x, img = "final.png")
  ```

* **The R Markdown templates changed.** `code-hover-with-flipbookr` and
  `quick_graphical_code_hover` were removed. There are now two templates:
  `codehover` (automatic) and `codehover-manual`. Documents no longer
  need to copy `codehoverStyle.css` / `codehoverJavascript.txt` next to
  the .Rmd -- delete those files and the `includes:` YAML entries.

* **Invalid `type` or `layout` values now raise an error** instead of
  silently falling back to the default.

* Rows are linked to their image through a `data-link` attribute (was an
  inline `onmouseover` handler), and the fixed `img_holder` id is gone,
  so several tables can live on the same page and Quarto no longer
  strips the attribute.

## Fixes

* `#` inside a string (e.g. `color = "#1D8565"`) is no longer treated as
  the start of a comment when splitting the code.
* Source references truncated by knitr (a `last_col` landing on the
  opening quote of a string) are validated with `parse()` and discarded
  in favour of a deparse fallback.
* `ch_hover()` works in interactive sessions, where the braced block
  carries a source reference for the `{` token itself.
* A step that cannot be rendered on its own (e.g. `after_stat()` in the
  global `aes()` before any geom is added) draws a blank image and emits
  a message naming the step, instead of aborting the whole table.

## Development

* Added a `testthat` suite covering the splitter, the source-reference
  resolver and the generated HTML.
* Added `R-CMD-check` and pkgdown GitHub Actions workflows.

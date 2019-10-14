thumbnail <- function(title, img, href = '#', caption = TRUE, width=6) {
  htmltools::div(
    class = sprintf("col-sm-%d", width),
    htmltools::a(
      class = "thumbnail", title = title, href = href,
      htmltools::img(src = img),
      htmltools::div(class = if (caption) "caption", if (caption) title)
    )
  )
}

column <- function(width = 12, ..., offset = 0){
  htmltools::div(
    class = sprintf("col-sm-%d%s", width, ifelse(offset == 0, '', paste0(" col-sm-offset-", offset))),
    ...
  )
}

library(tidyverse)


# arguments
title <- "k-means clustering"
author <- "Wikipedia"
date <- format(Sys.time(), "%Y년 %m월 %d일")
output <- "word_document"
toc <- "true"
style <- "../paper_template.docx"  # relative path
reference <- "../references.bib"  # relative path

rmd_dir <- "rmd/"  # absolute path
output_dir <- "doc"  # absolute path
output_file <- "__combined__"

# files to be combined
files <-
  c(
    "setup",  # This file should contain some chunks for options and libraries.
    "description",
    "history",
    "algorithms"
  )

# YAML header
yaml_header <- str_c(
  "---",
  str_c("title: \"", title, "\""),     # Title
  str_c("author: \"", author, "\""),   # Author
  str_c("date: \"", date, "\""),       # Date
  str_c("output:"),                    # Output format
  str_c("  ", output, ":"),
  str_c("    toc: ", toc),
  str_c("    reference_docx: ", style),
  str_c("bibliography: ", reference),  # References
  "---",
  sep = "\n"
)

# combine files
if (!str_detect(rmd_dir, "/$")) {
  rmd_dir <- str_c(rmd_dir, "/")
}
write_file(yaml_header, path = str_c(rmd_dir, output_file, ".Rmd"))
for (f in files) {
  newfile <- read_file(str_c(rmd_dir, f, ".Rmd"))
  # remove needless newline characters at the beginning of the file
  newfile <- newfile %>% str_replace("^\n+", "")
  # remove YAML header
  if (str_detect(newfile, "^---\n")) {
    eoh <- str_locate_all(newfile, "---")[[1]][2, 2]  # end of header
    newfile <- newfile %>% str_sub(eoh + 1, -1)
  }
  # pad with two newline characters
  newfile <- str_c("\n\n", newfile)
  # append file
  write_file(newfile, path = str_c(rmd_dir, output_file, ".Rmd"), append = TRUE)
}

# render combined file
rmarkdown::render(
  input = str_c(rmd_dir, output_file, ".Rmd"),
  output_file = str_c(output_file, ".docx"),
  output_dir = output_dir
)

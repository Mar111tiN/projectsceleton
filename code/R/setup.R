library(yaml)

#  this file contains all functionality for path setting
# several paths are hardcoded to reflect the fixed structure of your project folder
# data_path <- file.path(base_path, "data")
# out_path <- file.path(base_path, "output")
# img_path <- file.path(out_path, "img")

# # create the image folder, if it does not exist
# dir.create(img_path, showWarnings = FALSE)
# config_path <- file.path(base_path, "code/config")
# R_path <- file.path(base_path, "code/R")


# I import large static data like database files or human genome etc in static folder
# I have saved path to static data as environment variable STATIC
# this is not needed here
# static_path <- Sys.getenv("STATIC")

load_config <- function(config_file = "", ...) {
  # extract the config_file
  if (config_file != "") {
    config <- read_yaml(config_file)

    paths <- config$paths
  } 
  base_path <<- paths$base_path
  if (!startsWith(base_path, "/")) {
    base_path <<- file.path(home, base_path)
  }

  data_path <<- paths$data_path
  if (!startsWith(data_path, "/")) {
    data_path <<- file.path(base_path, data_path)
  }

  output_path <<- paths$output_path
  if (!startsWith(output_path, "/")) {
    output_path <<- file.path(base_path, output_path)
  }

  tables_path <<- paths$tables_path
  if (!startsWith(tables_path, "/")) {
    tables_path <<- file.path(base_path, tables_path)
  }

  img_path <- paths$img_path
  if (!startsWith(img_path, "/")) {
    img_path <<- file.path(base_path, img_path)
  }

  for (path in names(paths$R_paths)) {
    if (!startsWith(path, "/")) {
      R_path <<- file.path(home, path)
    } else {
      R_path <<- path
    }
    for (file in paths$R_paths[[path]]) {
      R_file <- file.path(R_path, file)
      print(str_glue("Loading data from {R_file}"))
      source(R_file)
    }
  }
  
  # get args to list
  args <- list(...)

  # update the config arguments with function arguments
  args <- modifyList(config, args)
}
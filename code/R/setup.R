# loading essential libraries
library(tidyverse)
library(readxl)
library(yaml)
library(xlsx)
#  this file contains all functionality for path setting

# # create the image folder, if it does not exist
# dir.create(img_path, showWarnings = FALSE)
# config_path <- file.path(base_path, "code/config")
# R_path <- file.path(base_path, "code/R")


# I import large static data like database files or human genome etc in static folder
# I have saved path to static data as environment variable STATIC
# this is not needed here
# static_path <- Sys.getenv("STATIC")

load_config <- function(config_file = "", ...) {
  
  ### CHECKS
  if (config_file == "") {
    # add functionality for not finding the config file
    message("You have to provide a config file")
    return(NULL)
  } 
  if (!file.exists(config_file)) {
    message(str_glue("config file {config_file} not found!"))
    return(NULL)
  }

  # load the config file
  config <- read_yaml(config_file)
  
  ### SET PATHS
  paths <- config$paths

  # create the path variables globally (<<- creates global variables)
  base_path <<- paths$base
  if (!startsWith(base_path, "/")) {
    base_path <<- file.path(home, base_path)
  }

  for (path in names(paths)) {
    if (!startsWith(paths[[path]], "/")) paths[[path]] <- if_else(
        path == "base", 
        file.path(Sys.getenv('HOME'), paths[[path]]),
        file.path(base_path, paths[[path]])
    )
    assign(str_glue("{path}_path"), paths[[path]], envir = .GlobalEnv)
  }

  ######## CREATE ALL THE PATH VARIABLES AND FOLDER (IF NOT EXISTING)
    for (path in c(
        data_path,
        results_path,
        config_path,
        tables_path,
        img_path,
        reports_path
    )) {

      if (!dir.exists(path)) {
        print(str_glue("Creating folder {path}"))
            dir.create(path)
        }
    }

  # LOAD R CODE
  cc <- config$code
  # go through R_core path list
  for (path in names(cc$R_core)) {
    if (!startsWith(path, "/")) {
      R_path <<- file.path(home, path)
    } else {
      R_path <<- path
    }
    for (file in cc$R_core[[path]]) {
      R_file <- file.path(R_path, file)
      print(str_glue("Loading data from {R_file}"))
      source(R_file)
    }
  }
  
  # set the threads
  if ("threads" %in% names(cc)) {
    library(BiocParallel)
    threads <- cc$threads
    print(str_glue("Setting {threads} cores for BiocParallel"))
    library(BiocParallel)
    register(MulticoreParam(threads))
  }

  # set java args
  if ("java" %in% names(cc)) {
    mem <- cc$java$mem
    print(str_glue("Using {mem} for java virtual machine"))
    options(java.parameters = str_glue("-Xmx{mem}"))
  }

  # get args to list
  args <- list(...)

  # update the config arguments with function arguments
  args <- modifyList(config, args)
}

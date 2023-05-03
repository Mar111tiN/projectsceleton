# loading essential libraries
library(tidyverse)
library(readxl)
library(yaml)
library(xlsx)
#  this file contains all functionality for path setting

# # create the image folder, if it does not exist
# dir.create(img_path, showWarnings = FALSE)
# config_path <- file.path(base_path, "code/config")


# I import large static data like database files or human genome etc in static folder
# I have saved path to static data as environment variable STATIC
# this is not needed here
# static_path <- Sys.getenv("STATIC")

run_setup <- function(config_file = "", ...) {
  home <- Sys.getenv('HOME')
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
  # set base_path first
    if (!startsWith(paths[['base']], "/")) paths[['base']] <- file.path(home, paths[['base']])
    assign("base_path", paths[['base']], envir = .GlobalEnv)

  for (folder in names(paths)) {
    if (folder == "base") next

    # set the folder relative to base_path
    root <- file.path(base_path, folder)

    # looking for a root path to use instead of base_path/folder
    for (file in names(paths[[folder]])) {
        if (file == "root") root <- paths[[folder]][['root']]
    }
    assign(str_glue("{tolower(folder)}_path"), root, envir = .GlobalEnv)
    for (path in names(paths[[folder]])) {
        # flatten the path list into path list
        # build paths from root
        if (!startsWith(paths[[folder]][[path]], "/")) {
            paths[[path]] <- file.path(root, paths[[folder]][[path]])
        } else paths[[path]] <- paths[[folder]][[path]]
        # create global variable
        assign(str_glue("{path}_path"), paths[[path]], envir = .GlobalEnv)
    }
    # remove the nested entries
    paths[[folder]] <- NULL
  }
  config$paths <- paths

  ######## CREATE ALL FOLDERS (IF NOT EXISTING)
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
            dir.create(path, recursive=TRUE)
        }
    }

  # LOAD R CODE
  cc <- config$code
  # R_path_save <- R_path
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
    # R_path <<- R_path_save
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
  return(config)
}


load_data <- function() {
    ### checks if RData file RData_path exits and loads it 
    # extend the file path  
    if (!endsWith(RData_path, ".RData")) RData_path <<- str_glue("{RData_path}.RData")
        if (file.exists(RData_path)) {
            load(RData_path, envir=.GlobalEnv)
            message(str_glue("Data loaded from {RData_path}"))
            return(1)
    } else return(0)
}
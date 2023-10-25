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
get_nested_path <- function(path_list, root="") {
    ## recursively building full paths from a path list
    # using list names as subfolders
    for (name in names(path_list)) {
        # check if entry is a subfolder (=list)
        if (name  %in% c('base', 'static', 'root')) next
        if (is.list(path_list[[name]])) {
            # look ahead for root in subfolder
            if ('root'  %in% names(path_list[[name]])) {
                root_set <- path_list[[name]][['root']]
                if (!startsWith(root_set, "/")) root_set <- file.path(root, root_set)
                subroot <- root_set
            } else {
                subroot <- file.path(root, name)
            }
            get_nested_path(path_list[[name]], root=subroot)
            paths[[name]] <<- subroot
            # assign(str_glue("{tolower(name)}_path"), paths[[name]], envir = .GlobalEnv)
        # entry is a path
        } else {
            paths[[name]] <<- file.path(root, path_list[[name]])
            # assign(str_glue("{name}_path"), file.path(root, path_list[[name]]), envir = .GlobalEnv)
        }
    }
  return(paths)
}


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

    ################################
    ### SET PATHS
    # paths has to be set globally for get_nested_path to have access
    paths <<- config$paths

    for (p in c("base", "static")) {
        # set base_path and static path first
        if (!(p %in% names(paths))) next
        if (!startsWith(paths[[p]], "/")) paths[[p]] <- file.path(home, paths[[p]])
        # assign(str_glue("{p}_path"), paths[[p]], envir = .GlobalEnv)
    }
    if (!("base") %in% names(paths)) paths$base <- Sys.getenv("PROJECT_DIR")
    if (paths$base == "") message("Warning - base path has not been set! (no base path in setups and no PROJECT_DIR envvariable)")


    temp_paths <- get_nested_path(paths, root=paths$base)

    ######## CREATE ALL FOLDERS (IF NOT EXISTING)
    for (p in names(temp_paths)) {
      if (!dir.exists(temp_paths[[p]])) {
        print(str_glue("Creating folder {temp_paths[[p]]}"))
            dir.create(temp_paths[[p]], recursive=TRUE)
      }
    }
    # load additional configs
    for (add_config in names(config$configs)) {
      message(str_glue("Loading additional config {add_config}"))
      add_config_file <- file.path(temp_paths$config, config$configs[[add_config]])
      if (!endsWith(add_config_file, ".yml")) add_config_file <- str_glue("{add_config_file}.yml")
      add_conf <- read_yaml(add_config_file)
      # adding the added paths to the temp_paths for global paths variable
      temp_paths <- get_nested_path(add_conf$paths, root=paths$base)
      add_conf$paths <- NULL
      config[[add_config]] <- add_conf
    } 


    # LOAD R CODE
    cc <- config$code
    paths$repo <- Sys.getenv("REPODIR")
    # R_path_save <- R_path
    # go through R_core path list
    for (path in names(cc$R_core)) {
        if (!startsWith(path, "/")) {
        if (paths$repo == "") {
            message(str_glue("Environment variable REPODIR is not set --> cannot source {path}"))
            next
        } 
        # R_path has to be loaded globally so subfiles can be loaded!
        R_path <<- file.path(paths$repo, path)
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

  # set VROOM_CONNECTION_SIZE for reading large datasets like TCGA
  Sys.setenv("VROOM_CONNECTION_SIZE" = 500000L)

  # get args to list
  args <- list(...)

  # update the config arguments with function arguments
  args <- modifyList(config, args)

  ### flush global envs and move paths to config
  config$paths <- paths
  R_path <<- NULL
  # paths <<- NULL
  return(config)
}


load_data <- function() {
    ### checks if RData file RData_path exits and loads it 
    # extend the file path
    if (!endsWith(paths$RData, ".RData")) paths$RData <<- str_glue("{paths$RData}.RData")
        if (file.exists(paths$RData)) {
            load(paths$RData, envir=.GlobalEnv)
            message(str_glue("Data loaded from {paths$RData}"))
            return(1)
    } else return(0)
}


load_packages <- function(package_file) {
  package_list <- read.table(package_file, header=FALSE)[, 1]
  BiocManager::install(package_list, update=FALSE, Ncpus=parallel::detectCores()-1)
}

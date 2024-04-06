###############################################################################
################## USE CONFIGS IN FUNCTIONS ###################################
library(yaml)

load_config <- function(    # only takes care of loading the right config
    config_file="",         # the config_file to use
    entry="",               # the entry in the config file to use
    convert_to_vector_list=c(), # which of the entries should be converted from lists to vectors
    ...
) {
    # load the config file
    if (!startsWith(config_file, "/")) {
    config_file <- file.path(config_path, config_file)
    }
    if (!file.exists(config_file)) {
        stop(str_glue("Config file {config_file} does not exist!"))
        return(NULL)
    }
    
    config <- read_yaml(config_file)

    # load the default config if existing
    if ("default"  %in% names(config)) {
        # store in default
        default_config <- config[["default"]]
        config$default <- NULL 
    } else {
        default_config <- list()
    }

    # go into the entry
    if (entry != "") {
        if (entry %in% names(config)) {
            config <- modifyList(default_config, config[[entry]])
            message(str_glue("Loading config {entry} from file {config_file}."))
        } else {
            stop(str_glue("Config file {config_file} does not contain entry for {entry}!"))
            return(NULL)
        }
    } else {
        message(str_glue("Loading config file {config_file}."))
    }

    if (length(convert_to_vector_list)) {
        for (entry_to_convert in convert_to_vector_list) {
            config[[entry_to_convert]] <- as_vector(config[[entry_to_convert]])
        }
    }
    return(config)
}


config_wrapper <- function(
    func,                   # the function to call
    data,                   # the data is always the first argument after the function
    ...
    ) {

    config <- load_config(...)
    if (is.null(config)) {
        return(NULL)
    }

    # add the function arguments to the list
    config <- modifyList(config, c(list(data=data), list(...)))
    do.call(func, config)
}


use_with_config <- function(
    f,
    config_file,         # the config_file to use
    entry="",               # the entry in the config file to use
    convert_to_vector_list=c(), # which of the entries should be converted from lists to vectors
    ...                         # additional function arguments overwriting existing ones
    ) {
    

    force(config_file)      # prevent lazy evaluation of config file if passed as variable
    fname <- as.character(substitute(f))

    # check wether f is a function
    if (!is.function(f)) {
        stop(str_glue("{fname} is not a function! --> Please pass a function as first argument!"))
        return(NULL)
    }
    if (entry == "") {
        entry <- fname  # get the name of the function to use as entry into config file
        message(str_glue("Decorating {fname} with config from {config_file}"))
    } else {
        message(str_glue("Decorating {fname} with [{entry}] from {config_file}"))
    }
    fixed_args <- list(...)
    ... <- NULL



    ######### create the function that will be implicitely returned
    function(
        data="",                   # the data is always the first argument after the function
        ...
    ) {

        ### store the function arguments
        args <- list(...)

        ####  load the config
        # if a config file ist passed to the decorated function it is used
        if ("config_file"  %in% names(args)) {
            if (args[['config_file']] != "") config_file <- args[['config_file']]
            args[['config_file']] <- NULL
        }
        # load the entry-specific config including the defaults
        config <- load_config(config_file, entry, convert_to_vector_list)
        if (is.null(config)) {
            stop(str_glue("Config file {config_file} cannot be loaded!"))
            return(NULL)
        }

        config <- modifyList(config, fixed_args)

        # overwrite config arguments with directly passed arguments and pass the data object as first argumemt
        #   data object is a requirement for all decorated functions
        config <- modifyList(config, c(list(data=data), args))
        # call the respective function
        do.call(f, config)
    }
}


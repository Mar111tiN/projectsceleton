library(yaml)


##### this is a function-specific config wrapper that
# 1) translates the arguments from a config yaml into a list
# 2) updates the arguments in the config list with directly passed arguments from the ellipsis
# ....c(list1, list2) updates duplicate entries with data from list2
# 3) creates pop.levels and pop.colors from the pops list
# 4) finally it calls the combined plot function with do.call and the list of arguments

### usually you might just need the simple yaml read and args <- list(...) but for nested and more complex configs
# you will have to add some extra logic

config_wrapper <- function(config_file = "", ...) {
  # extract the config_file
  if (config_file != "") {
    config <- read_yaml(config_file)
    config$pop.levels <- names(config$pops)
    config$pop.colors <- unlist(config$pops, use.names=FALSE)
    config$pops <- NULL
  }

  # get args to list
  args <- list(...)

  # update the config arguments with function arguments
  args <- modifyList(config, args)
  # ### call the function
  do.call(combined_plot, args)
}
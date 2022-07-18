library(yaml)


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

  # ### call the function
  do.call(combined_plot, c(config, args))
}
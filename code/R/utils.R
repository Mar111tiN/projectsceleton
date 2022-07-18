library(yaml)

wrapper1 <- function(config_file = "", ...) {
  # extract the config_file
  if (config_file != "") {
    config <-read_yaml(config_file)
    config$pop.levels <- names(config$pops)
    config$pop.colors <- unlist(config$pops, use.names=FALSE)
    config$pops <- NULL
    for (i in 1:length(config)) {
      assign(x = names(config[i]), value = config[[i]])
    }
  }

  # ### call the function
  stat.qPCR.plot(
    save.dims = save.dims,
    box.width = box.width,
    jitter.width = jitter.width,
    alpha = alpha,
    point.size = point.size,
    text.size = text.size,
    pop.colors = pop.colors,
    pop.levels = pop.levels,
    ...
  )
}

wrapper2 <- function(config_file = "", ...) {
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
  do.call(stat.qPCR.plot, c(config, args))
}
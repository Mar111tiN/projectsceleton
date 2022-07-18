############ PLAN: Include variables from config.yml
data <- yaml.load_file(str_glue("{R.path}/config.yml"))
# data is an object with attributes
data
# variables can be declared like this:
assign("box.width", 3)
# this loop does not work at all - no clue
for (i in attributes(data)$names) {
  key <- attributes(data)$names[[i]]
  value <- data$key
  print(value)
  # assign(paste0(b), data$a)
}
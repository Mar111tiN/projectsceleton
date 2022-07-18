# this file contains all functionality for path setting
# several paths are hardcoded to reflect the fixed structure of your project folder


data_path <- get_path(base_path, "data")
out_path <- get_path(base_path, "output")
img_path <- get_path(out_path, "img")
# create the image folder, if it does not exist
dir.create(img_path, showWarnings = FALSE)
config_path <- get_path(base_path, "code/config")
R_path <- get_path(base_path, "code/R")


# I import large static data like database files or human genome etc in static folder
# I have saved path to static data as environment variable STATIC
static_path <- Sys.getenv("STATIC")




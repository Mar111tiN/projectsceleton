# a helper function to make file building easier
get_path <- function(...) {
  str_replace(paste(..., sep="/"), "//", "/")
}


data_path <- get_path(base_path, "data")
out_path <- get_path(base_path, "output")
img_path <- get_path(out_path, "img")
config_path <- get_path(base_path, "code/config")
R_path <- get_path(base_path, "code/R")

# I import large static data like database files or human genome etc in static folder
# I have saved path to static data as environment variable STATIC
static_path <- Sys.getenv("STATIC")

# tmp_env <- new.env()
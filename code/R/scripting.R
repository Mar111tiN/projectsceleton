library(tidyverse)
library(patchwork)
library(readxl)

# load the home path
# Sys.getenv loads environment variables
home_path <- Sys.getenv('HOME')

# compose the base_path from path relative to home
# !!!!! you have to set this to the root path of the sceleton folder
# can also be absolute path without str_glue
base_path <- str_glue("{home_path}/Sites/tuto/sceleton")

setwd(base_path)
source("code/R/setup.R")

# load the functions and configs used for plotting the data
source(get_path(R_path, "plot.R"))
source(get_path(R_path, "utils.R"))

# setting the files for loading the data
stat.file <- get_path(data_path, "stat3.csv")
qPCR_file <- get_path(data_path, "qPCR.csv")
pdf.file <- get_path(img_path, "test_figure.pdf")
config.default <- get_path(config_path, "plot_config.yml")
config.gray <- get_path(config_path, "plot_config_gray.yml")


#### the function combined_plot is loaded from plot.R
# it has a lot of settings that you can play with
combined_plot(
  stat.file, qPCR_file,
  save.fig = pdf.file,
  save.dims = c(8, 11),
  box.width = .45,
  jitter.width = 0.03,
  alpha = 0.9,
  point.size = 1,
  text.size = 15,
  pop.colors = Tcell_colors,
  pop.label = Tcell_pop_labels,
  pop.levels = Tcell_pops,
  stat.label = "Fold increase to w/o",
  qPCR.label = "mRNA relative expression",
  qPCR.isoform = "alt",
  stim.time = 30
)

#### for easier control, the graphical settings can be placed in a 
# yaml file that controls many of these settings
# you can change these settings and restart the function
# parameters in function call overrule yaml-settings to combine defaults and current settings
# this allows 
config_wrapper(
  stat.file, qPCR_file,
  save.fig = pdf.file,
  qPCR.isoform = "alt",  # "A", "B" or "alt"
  stim.time = 30,  # 5,15, 30, 60
  config_file = config.default
)

### so you can also store several graphics settings and load them in need
# for different publications, presentations etc.
config_wrapper(
  stat.file, qPCR_file,
  save.fig = pdf.file,
  qPCR.isoform = "alt",
  stim.time = 30,  # 5,15, 30, 60
  config_file = config.gray
)

library(tidyverse)
library(patchwork)
library(readxl)

# load the path
home_path <- Sys.getenv('HOME')

base_path <- str_glue("{home_path}/Sites/tuto/sceleton")
setwd(base_path)

source("code/R/setup.R")

# load the functions
source(get_path(R_path, "plot.R"))
source(get_path(R_path, "utils.R"))


##### CONSTANTS #####################
Tcell_pops = c(
  expression(T["NAIVE"]),
  expression(T["SCM"]),
  expression(T["CM"]),
  expression(T["EM"]),
  expression(T["EMRA"])
  )


# setting the files
stat.file <- str_glue("{data_path}/stat3.csv")
qPCR_file <- str_glue("{data_path}/qPCR.csv")
pdf.file <- str_glue("{img_path}/test_figure.pdf")
config.file <- str_glue("{config_path}/plot_config.yml")
config.file2 <- str_glue("{config_path}/plot_config_gray.yml")



stat.qPCR.plot(
  stat.file, qPCR_file,
  save.fig = pdf.file,
  save.dims = c(8, 11),
  box.width = .45,
  jitter.width = 0.03,
  alpha = 0.9,
  point.size = 2.9,
  text.size = 20,
  pop.colors = TC.colors,
  pop.label = Tcell_pops,
  pop.levels = Tcell_levels,
  stat.label = "Fold increase to w/o",
  qPCR.label = "mRNA relative expression",
  qPCR.isoform = "alt",
  stim.time = 30
)


wrapper1(
  stat.file, qPCR_file,
  save.fig = pdf.file,
  pop.label = Tcell_pops,
  qPCR.label = "mRNA relative expression",
  stat.label = "Fold increase to w/o",
  qPCR.isoform = "alt",
  stim.time = 30,
  config_file = config.file
)

library(tidyverse)
library(readxl)
library(pheatmap)
library(viridis)

##################################
## PATHS ########################

base.path <- "/Users/martinszyska/Dropbox/Icke/Work/Luminex"
data.path <- str_glue("{base.path}/output")
save.path <- str_glue("{data.path}/img")

#######################################
######## FUNCS ########################
######## FUNC :: SAVE HEATMAP ###############
save_pheatmap_pdf <- function(x, filename, width=7, height=12) {
  stopifnot(!missing(x))
  stopifnot(!missing(filename))
  pdf(filename, width=width, height=height)
  grid::grid.newpage()
  grid::grid.draw(x$gtable)
  dev.off()
}

#######################################
######## EXECUTE ######################

## load the df
df <- read_tsv(str_glue("{data.path}/quick_lukas_heat.csv")) %>% 
  mutate(Patient = as.factor(Patient))

glimpse(df)

data.col <- "TvsL_sc"
(heat.mat <- df %>%
  select(c(Patient, Protein, data.col)) %>%
  pivot_wider(names_from = Protein, values_from = data.col) %>%
  column_to_rownames(var = "Patient") %>%
  as.matrix() %>%
  t())

#### draw the heatmap
heat.map <-pheatmap(
    main = "Luminex - normal scaled ratios Tumor vs Lung",
    heat.mat,
    # passing defaults
    cutree_rows = 2,
    cutree_cols = 3,
    treeheight_row = 17,
    treeheight_col = 17,
    show_colnames=T,
    cluster_cols=T,
    color = viridis(n = 256, alpha = 1, option="viridis")
  )
data.col
save_pheatmap_pdf(heat.map, str_glue("{save.path}/heatmap-{data.col}.pdf"), width=7, height=12)


######## FUNC :: CREATE HEATMAP ###############
ppheatmap <- function(
  data.filtered,
  data.col = "MFImWOscaled",
  # provide defaults
  cutree_rows = 3,
  cutree_cols = 3,
  treeheight_row = 17,
  treeheight_col = 17,
  show_colnames=F,
  row_info = c("Phospho", "Peak"),
  col_info = c("Cyto", "Pop", "Stim"),
  cyto_colors = c(
      wo = "white",
      IL2 = "blue",
      CXCL9 = "green",
      CXCL10 = "red",
      CXCL11 = "purple"
    ),
  stim_colors = c(
    unstim = "white",
    stim = "green"
  ),
  pop_colors = c(
    `Tcm+Tscm` = "green",
    `Tem+Temra` = "orange",
    `Tnaive` = "gray"
  ),
  ...
  ) {
  #########################################
  # get the annotations into a dataframe
    # extract the row.info
    row.info <- data.filtered %>% 
      select(c(Analyte, row_info)) %>% 
      unique() %>% 
      column_to_rownames(var = "Analyte")
    
    if ("Phospho" %in% row_info) {
      row.info <- row.info %>% 
        mutate(Phospho = as.factor(as.numeric(!is.na(Phospho))))
    }
    if ("Peak" %in% row_info) {
      row.info <- row.info %>% 
        mutate(Peak = as.factor(Peak))
    }
    # extract the col.info
    col.info <- data.filtered %>% 
      select(c(Sample, col_info)) %>% 
      unique() %>% 
      column_to_rownames(var = "Sample") %>% 
      data.frame()
    
    # define the colors for the annotation
    ann_colors = list(
      Cyto = cyto_colors,
      Stim = stim_colors,
      Pop = pop_colors
    )
    
    # remove WO values if "WO" is in data.col
    # which means that the data has been normalized to that column
    if (grepl("WO", data.col)) {
      data.filtered <- data.filtered %>% 
        filter(Cyto != "wo")      
    }
    heat.mat <- data.filtered %>%
      select(c(Sample, Analyte, data.col)) %>%
      pivot_wider(names_from = Analyte, values_from = data.col) %>%
      column_to_rownames(var = "Sample") %>%
      as.matrix() %>%
      t()
    print(heat.mat)
      # call the heatmap function
    heat.map <- heat.mat %>% 
      pheatmap(  
        annotation_row = row.info,
        annotation_col = col.info,
        annotation_colors = ann_colors,
        # passing defaults
        cutree_rows = cutree_rows,
        cutree_cols = cutree_cols,
        treeheight_row = treeheight_row,
        treeheight_col = treeheight_col,
        show_colnames=show_colnames,
        ...
      )     
    return(heat.map)
}
  







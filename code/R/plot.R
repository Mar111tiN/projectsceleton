library(tidyverse)
library(patchwork)

source(str_glue("{R_path}/stat.R"))

######## STAT PLOT #################
stat_plot <- function(stat_df,
  pop.label = c(),
  pop.colors = c(),
  ylabel = "",
  box.width = .65,
  jitter.width = 0.03,
  alpha = 0.9,
  point.size=0.8,
  text.size = 10
) {
  stat_df %>% 
  ggplot(aes(Pop, STAT3_MFI, fill = Pop)) +
  stat_summary(
    geom="boxplot",
    fun.data = bp_vals,
    show.legend = NA,
    width=box.width,    # set
    alpha=0.9,
    outlier.shape = NA,
    position = position_dodge(2)
  ) +
  geom_jitter(width=jitter.width, alpha=alpha, size=point.size, height=0) +
  geom_hline(yintercept = 1, size=0.5, linetype='dashed', color="darkgray") +
  labs(
    # title = "pSTAT3 in CD8+ T cell subsets after 30 min CXCL11 stimulation",
    y = ylabel
  ) +
  scale_fill_manual(values=pop.colors) +
  theme_light() +
  theme(
    title = element_blank(),
    axis.title.x = element_blank(),
    plot.title = element_text(hjust = 0.5),
    axis.text=element_text(size = text.size),
    axis.title = element_text(size = text.size)
  ) +
  guides(fill = "none") +
  scale_x_discrete(labels = pop.label)
}

######## qPCR PLOT #################
qPCR_plot <- function(qPCR.df,
  pop.colors = c(),
  ylabel = "",
  box.width = .65,
  jitter.width = 0.03,
  alpha = 0.9,
  point.size=0.8,
  text.size = 10
){
  qPCR.df %>% 
  ggplot(aes(Pop, conc, fill=Pop)) +
  geom_boxplot(
    show.legend = NA,
    width=box.width,
    alpha=alpha,
    outlier.shape = NA,
    coef = 0
  ) +
  geom_jitter(width = jitter.width, alpha=alpha, size=point.size, height=0) +
  scale_y_log10(
    breaks = c(1, 10, 100),
    minor_breaks = unique(as.numeric(1:10 %o% 10^(0:2))),
    limits = c(1, 100)
  ) +
  scale_fill_manual(values = pop.colors) +
  labs(
    # title = "CXCR3alt expression in CD8+ T cell subsets",
    y = ylabel
  ) +
  theme_light()+
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    plot.title = element_text(hjust=0.5),
    axis.text=element_text(size=text.size),
    axis.title = element_text(size=text.size)
  ) +
  guides(fill = "none")
}


############### main function
stat.qPCR.plot <- function(
  ####### ARGS ###########
  stat.file, qPCR_file,
  save.fig = "",
  save.dims = c(8, 11),
  pop.levels = c(
  "Tnaive",
  "Tscm",
  "Tcm",
  "Tem",
  "Temra",
  "CD8"
  ),
  pop.colors = c(
    "darkgray",
    "#F9837C",
    "#ADAE2C",
    "34B8F7",
    "#EB7AF4"
  ),
  pop.label = c(
  expression(T["NAIVE"]),
  expression(T["SCM"]),
  expression(T["CM"]),
  expression(T["EM"]),
  expression(T["EMRA"])
  ),
  stat.label = "STAT",
  qPCR.label = "qPCR",
  qPCR.isoform = "alt",
  stim.time = 30,
  ...
) {
  ###################### create STAT3 Plot
  # load file
  stat.plot <- read_csv(stat.file) %>%
    # wrangle and filter
    mutate(Pop = factor(Pop, levels = pop.levels)) %>%
    arrange(Pop) %>%
    filter(Pop != "CD8") %>%
    arrange(Pop) %>%
    filter(time == stim.time) %>%
  # plot
  stat_plot(
    pop.label = pop.label,
    pop.colors = pop.colors,
    ylabel = stat.label,
    ...
  )
  ###################### create qPCR Plot #######################
  # load
  q.plot <- read_csv(qPCR_file) %>%
    # wrangle and filter
    mutate(Pop = factor(Pop, levels = pop.levels)) %>%
    arrange(Pop) %>%
  filter(Isoform == qPCR.isoform) %>%
  filter(Pop != "CD8") %>% 
  mutate(conc = conc * 100) %>%
  qPCR_plot(
    ylabel = qPCR.label,
    pop.colors = pop.colors,
    ...
    )
  ############### COMBINE PLOTS ########################
  combined.plot <- (stat.plot / q.plot) + plot_layout(guides = "collect")
  if (save.fig != "") {
    ggsave(save.fig, combined.plot, width = save.dims[1], height = save.dims[2])
  }

  return(combined.plot)
}
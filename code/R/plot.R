#### plot.R does everything needed for the plot functionality:

# loads its own dependencies
library(tidyverse)
library(patchwork)


# load required code from other files
source(file.path(R_path, "stat.R"))
source(file.path(R_path, "plot_constants.R"))


### because the theme block of ggplot is used several times, I refactored it into a separate function
set_theme <- function(text.size=10, ...) {
    theme_light() +
    theme(
        axis.title.x = element_blank(),
        axis.text.x = element_text(size=text.size),
        plot.title = element_text(hjust=0.5),
        axis.text=element_text(size=text.size),
        axis.title = element_text(size=text.size)
    )
}


# splits the two plots into separate functions that are called both in the combined_plot function

######## STAT PLOT #################
stat_plot <- function(stat_df,
  pop.label = Tcell_pop_labels,
  pop.colors = Tcell_colors,
  ylabel = "",
  box.width = .65,
  jitter.width = 0.03,
  alpha = 0.9,
  point.size=0.8,
  boxplot.type=5,
  boxplot.probs=c(0.1, 0.25, 0.75, .9),
  ...
) {

    stat_df %>% 
    ggplot(aes(Pop, STAT3_MFI, fill = Pop)) +
    stat_summary(
        geom="boxplot",
        ## uses the statistics helper that returns the stat function with the appropriate arguments
        fun.data = bp_vals(type=boxplot.type, probs=boxplot.probs), 
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
    scale_x_discrete(labels = pop.label)  +
    guides(fill = "none") +
    set_theme(...)
}

######## qPCR PLOT #################
qPCR_plot <- function(qPCR.df,
    pop.colors = c(),
    pop.label = Tcell_pop_labels,
    ylabel = "",
    box.width = .65,
    jitter.width = 0.03,
    alpha = 0.9,
    point.size=0.8,
    ...
) {
    qPCR.df %>% 
    ggplot(aes(Pop, conc, fill=Pop)) +
    geom_boxplot(
        show.legend = NA,
        width=box.width,
        alpha=alpha,
        outlier.shape = NA,
        coef = 0
    ) +
    geom_jitter(
        width = jitter.width,
        alpha=alpha,
        size=point.size,
        height=0
        ) +
    scale_y_log10(
        breaks = c(1, 10, 100),
        minor_breaks = unique(as.numeric(1:10 %o% 10^(0:2))),
        limits = c(1, 100)
    ) +
    scale_x_discrete(labels = pop.label)  +
    scale_fill_manual(values = pop.colors) +
    labs(
        # title = "CXCR3alt expression in CD8+ T cell subsets",
        y = ylabel
    ) +
    guides(fill = "none") +
    set_theme(...)
}


############### main function
combined_plot <- function(
    ####### ARGS ###########
    # setting lots of default arguments here
    stat.file = "", 
    qPCR_file = "",
    save.fig = "",
    save.dims = c(8, 11),
    stat.label = "STAT",
    qPCR.label = "qPCR",
    qPCR.isoform = "alt",
    stim.time = 30,
    pop.levels = Tcell_pops,
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
        ...
        )
  ############### COMBINE PLOTS ########################
  # uses the patchwork library that allows easy setup of multiple graphs in one
  combined.plot <- (stat.plot / q.plot) + plot_layout(guides = "collect")
  if (save.fig != "") {
    ggsave(save.fig, combined.plot, width = save.dims[1], height = save.dims[2])
  }

  return(combined.plot)
}

library(tidyverse)
library(patchwork)


stat.df <- read_csv("data/stat3.csv") %>%
  # wrangle and filter
  mutate(Pop = factor(Pop, levels = c(
    "Tnaive",
    "Tscm",
    "Tcm",
    "Tem",
    "Temra",
    "CD8"
  ))) %>%
  arrange(Pop) %>%
  filter(Pop != "CD8") %>%
  arrange(Pop) %>%
  filter(time == 60)

stat.df

### this is a little statistics helper to be able to use different boxplot settings
# this is controlled by the type and probs argument that are passed to quantile()

# this is a function factory that returns a callable bp_vals function containing
# ...the type and probs arguments as a closure (they are saved at initiation)
# the callable takes the vector of values and returns a named vector that is used by the boxplot stat
bp_vals <- function(...) {
  # 
  bp_vals_func <- function(x) {
    r <- quantile(x, na.rm=TRUE, ...)
    r <- c(r[1:2], exp(mean(log(x))), r[3:4])
    names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
    return(r)
  }
  return(bp_vals_func)
}


### make the stat plot
stat.plot <- stat.df %>% 
  ggplot(aes(Pop, STAT3_MFI, fill = Pop)) +
  stat_summary(
    geom="boxplot",
    ## uses the statistics helper that returns the stat function with the appropriate arguments
    fun.data = bp_vals(type=5, probs=c(0.1, 0.25, 0.75, .9)), 
    show.legend = NA,
    width=0.5,    # set
    alpha=0.9,
    outlier.shape = NA,
    position = position_dodge(2)
  ) +
  geom_jitter(width=0.5, alpha=0.5, size=5, height=0) +
  geom_hline(yintercept = 1, size=0.5, linetype='dashed', color="darkgray") +
  labs(
    # title = "pSTAT3 in CD8+ T cell subsets after 30 min CXCL11 stimulation",
    y = "STAT3 MFI"
  ) +
  scale_fill_manual(values=c(
    "darkgray",
    "#F9837C",
    "#ADAE2C",
    "34B8F7",
    "#EB7AF4"
  )) +
  scale_x_discrete(labels = c(
    expression(T["NAIVE"]),
    expression(T["SCM"]),
    expression(T["CM"]),
    expression(T["EM"]),
    expression(T["EMRA"])
  ))  +
  guides(fill = "none") + 
  theme_light() +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_text(size=10),
    plot.title = element_text(hjust=0.5),
    axis.text=element_text(size=10),
    axis.title = element_text(size=10)
  )

stat.plot


######## qPCR data
qPCR.df <- read_csv("data/qPCR.csv") %>%
  # wrangle and filter
  mutate(Pop = factor(Pop, levels = c(
    "Tnaive",
    "Tscm",
    "Tcm",
    "Tem",
    "Temra",
    "CD8"
  ))) %>%
  arrange(Pop) %>%
  filter(Isoform == "alt") %>%
  filter(Pop != "CD8") %>% 
  mutate(conc = conc * 100)

qPCR.df

qPCR.plot <- ggplot(qPCR.df, aes(Pop, conc, fill=Pop)) +
  geom_boxplot(
    show.legend = NA,
    width=0.5,
    alpha=0.9,
    outlier.shape = NA,
    coef = 0
  ) +
  geom_jitter(
    width = 0.5,
    alpha=0.5,
    size=5,
    height=0
  ) +
  scale_y_log10(
    breaks = c(1, 10, 100),
    minor_breaks = unique(as.numeric(1:10 %o% 10^(0:2))),
    limits = c(1, 100)
  ) +
  scale_x_discrete(labels = c(
    expression(T["NAIVE"]),
    expression(T["SCM"]),
    expression(T["CM"]),
    expression(T["EM"]),
    expression(T["EMRA"])
  ))  +
  scale_fill_manual(values = c(
    "darkgray",
    "#F9837C",
    "#ADAE2C",
    "34B8F7",
    "#EB7AF4"
  )) +
  labs(
    # title = "CXCR3alt expression in CD8+ T cell subsets",
    y = "qPCR relative expression"
  ) +
  guides(fill = "none") + 
  theme_light() +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_text(size=10),
    plot.title = element_text(hjust=0.5),
    axis.text=element_text(size=10),
    axis.title = element_text(size=10)
  )

qPCR.plot

combined.plot <- (stat.plot / qPCR.plot) + plot_layout(guides = "collect")
combined.plot

ggsave("output/test.pdf", combined.plot)

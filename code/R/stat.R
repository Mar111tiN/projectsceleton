
bp_vals <- function(x, probs=c(0.1, 0.25, 0.75, .9)) {
  r <- quantile(x, probs=probs , na.rm=TRUE, type=5)
  r <- c(r[1:2], exp(mean(log(x))), r[3:4])
  names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
  r
}
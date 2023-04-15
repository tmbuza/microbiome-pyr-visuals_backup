set.seed(110912)

knitr::opts_chunk$set(
  echo = FALSE,
  message = FALSE,
  warning = FALSE,
  cache = FALSE,
  comment = NA,
  fig.path='./figures/q2-',
  fig.show='asis',
  dev = 'png',
  fig.align='center',
  out.width = "70%",
  fig.width = 7,
  fig.asp = 0.7,
  fig.show = "asis"
)


theme_cdi<- function () { 
  theme_bw(base_size=10, base_family="Helvetica") +
    theme(
      axis.line = element_blank(), strip.background = element_blank(),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      axis.text = element_text(hjust = 1, size = 12),
      axis.title=element_text(size=14),
      axis.text.x = element_text(hjust=0.5),
      plot.margin=unit(c(1,1,1.5,1.2),"cm"),
      legend.key.size = unit(5, "mm"),
      legend.position ="right",
      legend.direction = "vertical",
      legend.title = element_text(color = "blue4", size = 12),
      legend.text = element_text(color = "black", size = 10)
    )
}
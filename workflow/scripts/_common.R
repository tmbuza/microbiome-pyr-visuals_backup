# Global settings

knitr::write_bib(c(
  .packages(), 'bookdown', 'knitr', 'rmarkdown'), 'packages.bib')

knitr::opts_chunk$set(
  echo  =TRUE,
  message  =FALSE,
  warning  =FALSE,
  cache  =FALSE,
  comment  =NA,
  collapse =TRUE,
  fig.path='./figures/',
  fig.show='asis',
  dev  ='png',
  fig.align='center',
  out.width  ="70%",
  fig.width  =7,
  fig.asp  =0.7,
  fig.show  ="asis"
)

plotLDA<-function(x, group, lda = 2, pvalue = 0.05, padj = NULL, color = NULL, fontsize.x = 4, fontsize.y = 5){
    x <- subset(x, LDAscore > lda)
    if(!is.null(padj)){
        x <- subset(x,p.adj<padj)
    }else{
        x <- subset(x,p.value<pvalue)
    }
    x <- subset(x,direction%in%group)
    x<-x %>%mutate(LDA=ifelse(direction==group[1],LDAscore,-LDAscore))
    p<-ggplot(x,aes(x=reorder(tax,LDA),y=LDA,fill=direction))+
        geom_bar(stat="identity",color="white")+coord_flip()+
        theme_light()+theme(axis.text.x = element_text(size=fontsize.x),
                            axis.text.y = element_text(size=fontsize.y))
    if(is.null(color)){
        color <- distcolor[c(2:3)]
    }
    p<-p+scale_fill_manual(values=color)+xlab("")
    p
}

dfRowName <- function(x, name = "Rows", stringsAsFactors = FALSE){
  res <- data.frame(rownames(x), x, stringsAsFactors = stringsAsFactors)
  colnames(res)[1] <- name
  rownames(res) <- NULL
  return(res)
}

read_matrix <- function(file_name){
  
  file <- scan(file_name,
               what=character(),
               quiet=TRUE,
               sep="\n")
  
  n_samples <- as.numeric(file[1])
  file <- file[-1]
  
  file_split <- strsplit(file, "\t")
  
  fill_in <- function(x, length){
    c(x, rep("0", length - length(x)))
  }
  
  filled <- lapply(file_split, fill_in, length=n_samples + 1)
  
  samples_distance_matrix <- do.call(rbind, filled)
  
  samples <- samples_distance_matrix[,1]
  
  dist_matrix <- samples_distance_matrix[,-1]
  dist_matrix <- matrix(as.numeric(dist_matrix), nrow=n_samples)
  
  if(sum(dist_matrix[upper.tri(dist_matrix)]) == 0){
    dist_matrix <- dist_matrix+t(dist_matrix)
  }
  
  rownames(dist_matrix) <- samples
  colnames(dist_matrix) <- samples

  return(dist_matrix)
}

resave <- function(..., list = character(), file) {
#  add objects to existing Rdata file. Original code written by "flodel"
# on StackOverflow (http://www.linkedin.com/in/florentdelmotte)  . 
   previous  <- load(file)
   var.names <- c(list, as.character(substitute(list(...)))[-1L])
   for (var in var.names) assign(var, get(var, envir = parent.frame()))
   save(list = unique(c(previous, var.names)), file = file)
}

ord_methods <-  c("PCA", "CA", "CCA", "RDA", "DCA", "CAP", "DPCoA", "NMDS", "MDS", "PCoA" )

library(tidyverse)
library(scales)
## Axes
noxticks <- theme(axis.text.x=element_blank())
noxlabels <- theme(axis.text.x=element_blank())
noxtitle <- theme(axis.title.x=element_blank())
noyticks <- theme(axis.text.y=element_blank())
noylabels <- theme(axis.text.y=element_blank())
noytitle <- theme(axis.title.y=element_blank())

## Legend Text size
legend10 <- theme(legend.text=element_text(size=10))
legend8 <- theme(legend.text=element_text(size=8))

## Legend position
rightlegend <- theme(legend.position="right")
bottomlegend <- theme(legend.position="bottom")
leftlegend <- theme(legend.position="left")
nolegend <- theme(legend.position="none")

## Center Plot title
centertitle <- theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5)) + 
  theme(axis.title=element_text(size=14,face="bold"))

facetsize14 <- theme(strip.text.x = element_text(size = 14, colour = "black", angle = 0))
facetsize12 <- theme(strip.text.x = element_text(size = 12, colour = "black", angle = 0))
facetsize10 <- theme(strip.text.x = element_text(size = 10, colour = "black", angle = 0))
facetsize8 <- theme(strip.text.x = element_text(size = 8, colour = "black", angle = 0))

# Center Plot title
centertitle <- theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.subtitle = element_text(hjust = 0.5))

formatPlot <-
  theme(strip.text.x = element_text(size = 16))+
  theme(plot.title = element_text(size = 16, face = "bold")) +
  theme(plot.subtitle = element_text(size = 14)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(axis.text = element_text(hjust = 1, size = 10))+
  theme(axis.title=element_text(size=14,face="bold")) +
  theme(axis.text.x = element_text(hjust=0.5))

axislabel14bold <- theme(axis.title=element_text(size=14,face="bold"))

# Continuous values
xbreaks5 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=5))
xbreaks10 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=10))
xbreaks15 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=15))

ybreaks5 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=5))
ybreaks10 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=10))
ybreaks15 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=15))

## Discrete values
xbreaksdis5 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=5))
xbreaksdis10 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=10))
xbreaksdis15 <- scale_x_continuous(labels = comma, breaks=pretty_breaks(n=15))

ybreaksdis5 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=5))
ybreaksdis10 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=10))
ybreaksdis15 <- scale_y_continuous(labels = comma, breaks=pretty_breaks(n=15))

facetsize14 <- theme(strip.text.x = element_text(size = 14, colour = "black", angle = 0))
facetsize12 <- theme(strip.text.x = element_text(size = 12, colour = "black", angle = 0))
facetsize10 <- theme(strip.text.x = element_text(size = 10, colour = "black", angle = 0))
facetsize8 <- theme(strip.text.x = element_text(size = 8, colour = "black", angle = 0))

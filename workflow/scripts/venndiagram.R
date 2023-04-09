source("workflow/scripts/common.R")
source("workflow/scripts/qiime2R.R")

library(tidyverse)


metadata <- read_csv("data/metadata.csv", show_col_types = FALSE)
shannon <- read_csv("data/shannon.csv", show_col_types = FALSE)


gplots::venn(list(Metadata=metadata$sample_id, Shannon=shannon$sample_id))

library(VennDiagram)
my_venn <- venn.diagram(x=list(metadata$sample_id, shannon$sample_id),  
                        filename = NULL, 
                        fill=c("maroon", "green4"), 
                        alpha=c(0.8,0.8),
                        euler.d = FALSE,
                        scaled = FALSE,
                        cat.fontfamily = "sans",
                        cat.cex = 1,
                        lwd = c(0, 0),
                        category.names=c("Metadata", "Shannon"),
                        print.mode = c("raw", "percent"),
                        fontfamily = "sans",
                        main="Overlap of samples between Metadata and Shannon",
                        main.fontfamily = "sans",
                        main.cex = 1,
                        cex = 0.9,
                        width = 10,
                        height = 10,
                        units = "in")

# ggsave(my_venn, file="figures/venndiagram.pdf", width=6, height=6)
ggsave(my_venn, file="figures/venndiagram.png", width=6, height=6)
ggsave(my_venn, file="figures/venndiagram.svg", width=6, height=6)

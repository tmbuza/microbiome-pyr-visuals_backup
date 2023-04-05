
source("workflow/scripts/common.R")
library(tidyverse)
# library(qiime2R)
# 
# read_q2metadata("data/sample_metadata.tsv") %>% 
#   rename("sample_id"=1) %>% 
#   write_csv("data/metadata.csv")
# 
# read_qza("data/shannon_vector.qza")$data %>% 
#   tibble::rownames_to_column("sample_id") %>% 
#   write_csv("data/shannon.csv")

metadata <- read_csv("data/metadata.csv", show_col_types = FALSE)
shannon <- read_csv("data/shannon.csv", show_col_types = FALSE)

# Alpha Diversity

##  Venn diagram

# Quick glimpse

gplots::venn(list(Metadata=metadata$sample_id, Shannon=shannon$sample_id))

library(VennDiagram)
my_venn <- venn.diagram(x=list(metadata$sample_id, shannon$sample_id),  
                        filename = NULL, 
                        fill=c("red", "green"), 
                        alpha=c(0.8,0.8),
                        euler.d = TRUE,
                        scaled = TRUE,
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

ggsave(my_venn, file="figures/venn_metadata_shannon.pdf", width=6, height=6)
ggsave(my_venn, file="figures/venn_metadata_shannon.png", width=6, height=6)
ggsave(my_venn, file="figures/venn_metadata_shannon.svg", width=6, height=6)

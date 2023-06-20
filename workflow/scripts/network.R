## Sample network using `ggraph` function

# Load required packages
library(phyloseq)
library(igraph)
library(ggraph)
library(tidygraph)
set.seed(123)
source("_common.R")

load("data/bray_distances.rda")

dist <- ps_log10p_bray_dist

# Convert the distance matrix to a similarity matrix
similarity_matrix <- as.matrix(1 - dist)

# Randomly select a subset of samples
selected_samples <- sample(colnames(similarity_matrix), 10)

# Subset the similarity matrix based on the selected samples
subset_matrix <- similarity_matrix[selected_samples, selected_samples]

# Randomly sample a subset of nodes to plot
nodes_to_plot <- sample(1:nrow(similarity_matrix), size = 10)

# Filter the similarity matrix and keep only the desired nodes
filtered_similarity_matrix <- similarity_matrix[nodes_to_plot, nodes_to_plot]

# Create an 'igraph' graph object
graph_undir <- graph.adjacency(filtered_similarity_matrix, mode = "undirected", weighted = TRUE)
g <- graph.adjacency(filtered_similarity_matrix, mode = "undirected", weighted = TRUE)


layout <- layout_with_fr(g)  # Use a layout algorithm (e.g., Fruchterman-Reingold layout)
node_colors <- "steelblue"  # Customize node colors
node_sizes <- 25  # Customize node sizes

plot(g, main = "Network of 10 randomly picked nodes (package = `igraph`")


library(ggraph)
library(RColorBrewer)
# Convert 'igraph' graph to 'ggraph' graph
g <- as_tbl_graph(g)

# Customize the network visualization with 'ggraph'
ggraph(g, layout = "auto") +
  geom_edge_diagonal(color = "steelblue") +
  geom_edge_link(width = 0.2, alpha = 0.2) +
  geom_node_point(size = 4, color = "red") +
  geom_node_text(aes(label = name), repel = TRUE, segment.size = 0.2) +
  labs(title = "\nNetwork of 10 randomly picked nodes (package = ggraph)\n") +
  theme(panel.background = element_rect(fill = "white")) +
  theme(
    legend.position="none"
  )
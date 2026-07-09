#!/usr/bin/env Rscript
# STAGE 3 core: Subtyping/Clustering
# Reads normalized counts, selects top variable genes, and performs clustering.

args <- commandArgs(trailingOnly = TRUE)
counts_file  <- args[1] # Path to counts
out_file     <- args[2] # Path to output

# Load data
counts <- read.delim(counts_file, row.names = 1, check.names = FALSE)

# Preprocessing: Select top 1000 most variable genes
var_genes <- apply(counts, 1, var)
top_genes <- head(order(var_genes, decreasing = TRUE), 1000)
counts_subset <- counts[top_genes, ]

# Clustering: Hierarchical clustering
dist_matrix <- dist(t(counts_subset)) # Transpose for sample-wise clustering
hc <- hclust(dist_matrix, method = "ward.D2")
clusters <- cutree(hc, k = 3) # Default 3 clusters for demo

# Save results
res <- data.frame(sample_id = names(clusters), cluster = clusters)
write.table(res, out_file, sep = "\t", quote = FALSE, row.names = FALSE)
cat("Subtyping done: 3 clusters generated\n")

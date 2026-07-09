#!/usr/bin/env Rscript
# STAGE 5 core: Comparative/Consensus Analysis
# Integrates DE results from multiple cohorts to find consensus signatures.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    stop("Usage: run_consensus.R <output_file> <de_file1> <de_file2> ...")
}

out_file <- args[1]
de_files <- args[-1]

# Load all DE tables into a list
all_res <- lapply(de_files, function(f) {
    df <- read.delim(f, row.names = 1, check.names = FALSE)
    # Only keep significant genes
    df <- df[df$padj < 0.05, ]
    return(df[, "log2FoldChange", drop = FALSE])
})

# Merge all tables by gene name
merged <- Reduce(function(x, y) merge(x, y, by = 0, all = FALSE), all_res)
colnames(merged) <- paste0("study_", 1:length(all_res), "_lfc")

# Calculate Consensus:
# 1. Direction consistency (all must have same sign)
# 2. Significant in all studies (already filtered by padj < 0.05)
res_final <- merged[apply(merged, 1, function(row) {
    all(row > 0) || all(row < 0)
}), , drop = FALSE]

# Add meta-stats
res_final$avg_lfc <- rowMeans(res_final)
res_final$n_studies <- length(all_res)
res_final$gene <- rownames(res_final)

# Save final consensus table
write.table(res_final[, c("gene", "avg_lfc", "n_studies")],
            out_file, sep = "\t", quote = FALSE, row.names = FALSE)

cat("Consensus analysis done:", nrow(res_final), "consensus genes found.\n")

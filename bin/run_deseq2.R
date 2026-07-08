#!/usr/bin/env Rscript
# STAGE 4 core: differential expression with DESeq2.
# Reads a counts matrix (genes x samples) + a sample sheet, runs one contrast.
suppressMessages({ library(DESeq2) })

args <- commandArgs(trailingOnly = TRUE)
# Expected: --counts X --samples Y --contrast Z --out A
# Simple parser to mimic optparse
get_arg <- function(flag) {
    idx <- which(args == flag)
    if (length(idx) > 0) return(args[idx + 1])
    return(NULL)
}

counts_file  <- get_arg("--counts")
samples_file <- get_arg("--samples")
contrast_val <- get_arg("--contrast")
out_file     <- get_arg("--out")
if (is.null(out_file)) out_file <- "deseq2_results.tsv"

counts  <- as.matrix(read.delim(counts_file,  row.names = 1, check.names = FALSE))
samples <- read.delim(samples_file, row.names = 1, check.names = FALSE)
parts   <- strsplit(contrast_val, ",")[[1]]
col <- parts[1]; test <- parts[2]; ref <- parts[3]

samples[[col]] <- relevel(factor(samples[[col]]), ref = ref)
counts <- counts[, rownames(samples), drop = FALSE]     # align order

dds <- DESeqDataSetFromMatrix(round(counts), samples, as.formula(paste("~", col)))
dds <- DESeq(dds)
res <- as.data.frame(results(dds, contrast = c(col, test, ref)))
res$gene <- rownames(res)
write.table(res[order(res$padj), ], out_file, sep = "\t", quote = FALSE, row.names = FALSE)
cat("DE done:", sum(res$padj < 0.05, na.rm = TRUE), "genes at padj<0.05\n")

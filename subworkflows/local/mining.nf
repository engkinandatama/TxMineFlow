nextflow.enable.dsl=2

include { DIFFERENTIAL_EXPRESSION } from '../../modules/local/differential_expression'
include { RESULTS_TO_DUCKDB }       from '../../modules/local/results_to_duckdb'

/*
 * STAGE 4 - Mining
 * v0.1: differential expression only. Enrichment (fgsea) and survival
 * association are the next modules to add here, each as its own process.
 */
workflow MINING {
    take:
    counts      // path: gene x sample count matrix (TSV)
    samples     // path: sample sheet with the contrast column
    contrast    // val:  e.g. "condition,tumor,normal"

    main:
    DIFFERENTIAL_EXPRESSION(counts, samples, contrast)
    RESULTS_TO_DUCKDB(DIFFERENTIAL_EXPRESSION.out.de_table)

    emit:
    de_table = DIFFERENTIAL_EXPRESSION.out.de_table
    db       = RESULTS_TO_DUCKDB.out.db
}

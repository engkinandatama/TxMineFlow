#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * TxMineFlow - top-level workflow
 * Wires the five staged modules. Upstream heavy stages (1-2) are designed to
 * call nf-core subworkflows; here they are represented as clearly-marked TODOs
 * so the DAG is honest about what is real (STAGE 4) vs stubbed.
 */

include { MINING } from './subworkflows/local/mining'

workflow {

    // -------- STAGE 1: data selection (TODO) --------
    // Intended: include { FETCHNGS } from nf-core and feed accessions from the
    // project config. For v0.1 we start from a provided count matrix instead.
    // if (params.run_fetch) { FETCHNGS(ch_accessions) }

    // -------- STAGE 2: functional processing (TODO) --------
    // Intended: include { RNASEQ } from nf-core/rnaseq -> counts matrix.
    // if (params.run_quant) { RNASEQ(ch_reads) }

    // For v0.1 the counts + sample sheet come straight from the project.
    ch_counts  = Channel.fromPath(params.counts,  checkIfExists: true)
    ch_samples = Channel.fromPath(params.samples, checkIfExists: true)

    // -------- STAGE 4: mining (v0.1 - REAL) --------
    if (params.run_mining) {
        MINING(ch_counts, ch_samples, params.contrast)
    }

    // -------- STAGE 3 & 5 (STUB) --------
    // if (params.run_subtype) { SUBTYPE(ch_counts) }
    // if (params.run_compare) { COMPARE(MINING.out.de_table.collect()) }
}

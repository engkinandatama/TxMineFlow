#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { MINING } from './subworkflows/local/mining'
include { SUBTYPE } from './modules/local/subtype'
include { COMPARE } from './modules/local/compare'

workflow {

    // Fallback: gunakan file lokal
    ch_counts  = Channel.fromPath(params.counts,  checkIfExists: true)
    ch_samples = Channel.fromPath(params.samples, checkIfExists: true)

    // -------- STAGE 3: structure/subtyping --------
    if (params.run_subtype) {
        SUBTYPE(ch_counts)
    }

    // -------- STAGE 4: mining (v0.1 - REAL) --------
    if (params.run_mining) {
        MINING(ch_counts, ch_samples, params.contrast)
    }

    // -------- STAGE 5: comparative/consensus --------
    if (params.run_compare) {
        COMPARE(MINING.out.de_table.collect())
    }
}
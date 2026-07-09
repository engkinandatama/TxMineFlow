#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { MINING } from './subworkflows/local/mining'
// Stage 1 & 2 menggunakan nf-core subworkflow - dinonaktifkan sementara untuk pengujian
// Stage 3 & 5 juga dinonaktifkan untuk pengujian Mining saja

workflow {

    // Fallback: gunakan file lokal
    ch_counts  = Channel.fromPath(params.counts,  checkIfExists: true)
    ch_samples = Channel.fromPath(params.samples, checkIfExists: true)

    // -------- STAGE 4: mining (v0.1 - REAL) --------
    if (params.run_mining) {
        MINING(ch_counts, ch_samples, params.contrast)
    }
}
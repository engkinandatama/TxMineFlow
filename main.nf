#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * TxMineFlow - top-level workflow
 * Wires the five staged modules. Upstream heavy stages (1-2) are designed to
 * call nf-core subworkflows; here they are represented as clearly-marked TODOs
 * so the DAG is honest about what is real (STAGE 4) vs stubbed.
 */

include { MINING } from './subworkflows/local/mining'
// Stage 1 & 2 menggunakan nf-core subworkflow - dinonaktifkan sementara untuk pengujian
// include { FETCHNGS } from './subworkflows/nf-core/fetchngs/main.nf'
// include { RNASEQ } from './subworkflows/nf-core/rnaseq/main.nf'
include { SUBTYPE } from './modules/local/subtype'
include { COMPARE } from './modules/local/compare'

workflow {

    // Workflow logic:
    if (params.run_fetch) {
        ch_accessions = Channel.fromList(params.accessions)
        FETCHNGS(ch_accessions)

        if (params.run_quant) {
            // Hubungkan output reads DAN samplesheet dari FETCHNGS ke RNASEQ
            RNASEQ(FETCHNGS.out.reads, FETCHNGS.out.samplesheet)
            ch_counts = RNASEQ.out.counts
            ch_samples = FETCHNGS.out.samplesheet
        }
    } else {
        // Fallback: gunakan file lokal jika fetch tidak jalan
        ch_counts  = Channel.fromPath(params.counts,  checkIfExists: true)
        ch_samples = Channel.fromPath(params.samples, checkIfExists: true)
    }

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

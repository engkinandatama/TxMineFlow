process COMPARE {
    label 'process_medium'
    container 'quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_0'
    publishDir "${params.outdir}/consensus", mode: 'copy'

    input:
    path de_tables

    output:
    path "consensus.tsv", emit: consensus_table

    script:
    """
    run_consensus.R consensus.tsv ${de_tables.join(' ')}
    """
}
process SUBTYPE {
    label 'process_medium'
    container 'quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_0'
    publishDir "${params.outdir}/subtype", mode: 'copy'

    input:
    path counts

    output:
    path "clusters.tsv", emit: clusters

    script:
    """
    run_clustering.R ${counts} clusters.tsv
    """
}
process DIFFERENTIAL_EXPRESSION {
    tag "$contrast"
    label 'process_medium'
    container 'quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_0'
    publishDir "${params.outdir}/mining", mode: 'copy'

    input:
    path counts
    path samples
    val  contrast

    output:
    path "deseq2_results.tsv", emit: de_table
    path "versions.yml",       emit: versions

    script:
    """
    run_deseq2.R --counts ${counts} --samples ${samples} --contrast "${contrast}" --out deseq2_results.tsv
    cat <<-VERS > versions.yml
    "${task.process}":
        deseq2: 1.42.0
    VERS
    """
}

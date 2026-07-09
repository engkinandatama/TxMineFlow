process RESULTS_TO_DUCKDB {
    label 'process_low'
    publishDir "${params.outdir}/warehouse", mode: 'copy'

    input:
    path de_table

    output:
    path "txmineflow.duckdb", emit: db

    script:
    """
    load_results_duckdb.py --de ${de_table} --db txmineflow.duckdb
    """
}

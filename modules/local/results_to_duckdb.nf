process RESULTS_TO_DUCKDB {
    label 'process_low'
    // Menggunakan image yang berbasis Debian/Ubuntu agar apt-get bekerja dengan baik
    container 'python:3.11-slim'
    publishDir "${params.outdir}/warehouse", mode: 'copy'

    input:
    path de_table

    output:
    path "txmineflow.duckdb", emit: db

    script:
    """
    apt-get update && apt-get install -y libstdc++6
    pip install duckdb
    load_results_duckdb.py --de ${de_table} --db txmineflow.duckdb
    """
}

#!/usr/bin/env python
"""Collector step: load tidy result TSVs into the DuckDB warehouse.
Each stage appends its own table; notebooks/report query this single file."""
import argparse, duckdb

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--de", required=True, help="DESeq2 results TSV")
    p.add_argument("--db", default="txmineflow.duckdb")
    a = p.parse_args()

    con = duckdb.connect(a.db)
    con.execute(
        "CREATE OR REPLACE TABLE differential_expression AS "
        "SELECT * FROM read_csv_auto(?, delim='\t', header=true)", [a.de]
    )
    n = con.execute(
        "SELECT count(*) FROM differential_expression WHERE padj < 0.05"
    ).fetchone()[0]
    print(f"warehouse: {a.db} | {n} significant genes loaded")
    con.close()

if __name__ == "__main__":
    main()

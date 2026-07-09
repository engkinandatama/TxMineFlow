import duckdb
import os

db_path = "/home/nanda/projects/txmineflow/results/warehouse/txmineflow.duckdb"
out_path = "/home/nanda/projects/txmineflow/results/mining/de_results.csv"

print(f"Exporting {db_path} to {out_path}...")
con = duckdb.connect(db_path)
con.execute(f"COPY (SELECT * FROM differential_expression) TO '{out_path}' (HEADER, DELIMITER ',')")
con.close()
print("Export successful!")

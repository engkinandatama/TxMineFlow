# TxMineFlow architecture

Two layers, mirroring the PrimerLab pattern but with a real workflow engine.

## Layer 1 - the CLI wrapper (txmineflow/)
Thin Python/click package. Its only jobs: validate the project config, invoke
Nextflow with the right params, then drive the post-run DuckDB + report steps.
It does NOT do science - it orchestrates the orchestrator. (Same separation you
enforced in PrimerLab with "no cross-layer imports".)

- cli.py     - commands: init | run | report | db
- project.py - load + validate the project YAML schema

## Layer 2 - the Nextflow pipeline (root + modules/ + subworkflows/)
Declarative DAG. Each stage is a module or subworkflow. Reuses nf-core
subworkflows for the heavy upstream steps.

main.nf                         # top-level: wires the 5 stages
conf/base.config                # resource labels
modules/local/
    differential_expression.nf  # STAGE 4: DESeq2 (wraps bin/run_deseq2.R)
    results_to_duckdb.nf        # collector: emit tidy TSVs for the warehouse
subworkflows/local/
    mining.nf                   # STAGE 4 wiring (DE + enrichment + survival)
bin/
    run_deseq2.R                # the actual DE script (containerized)
    load_results_duckdb.py      # TSV -> DuckDB tables

## Stage map
| Stage | Purpose               | Tool(s) wrapped              | Status |
|-------|-----------------------|------------------------------|--------|
| 1     | Data selection        | nf-core/fetchngs             | TODO   |
| 2     | Functional processing | nf-core/rnaseq, limma/ComBat | TODO   |
| 3     | Structure / subtyping | own: clustering              | STUB   |
| 4     | Mining                | DESeq2, fgsea, survival      | v0.1   |
| 5     | Comparative           | own: meta-analysis           | STUB   |

## The "project" abstraction
One YAML = one dataset collection + the stages to run + contrast definitions.
`txmineflow run --project X.yaml` is the entire UX. This is BGCFlow's project
concept expressed in your config-driven style.

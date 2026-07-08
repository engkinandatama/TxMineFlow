# 🧬 TxMineFlow

**A systematic, config-driven workflow for mining molecular subtypes and expression
signatures across large collections of public tumor transcriptomes.**

TxMineFlow orchestrates existing best-in-class tools into five staged modules —
(i) data selection, (ii) functional processing, (iii) structure/subtyping,
(iv) mining, (v) comparative analysis — driven by a single *project* config,
with results collected into a DuckDB warehouse and explored via parameterized
notebooks and an HTML report.

Engine: **Nextflow (DSL2)** · UX: **`txmineflow` Python CLI** · Warehouse: **DuckDB**

> Status: v0.1 skeleton. Stages 1, 2 and 4 are the initial target.
> Stages 3 and 5 are stubbed with clear TODOs.

## Why

`nf-core/rnaseq` stops at the count matrix (no statistical comparison). Public
data repositories give you data but no systematic mining layer. TxMineFlow fills
that gap: point it at a *collection* of public studies, get back subtypes,
signatures, and cross-cohort consensus — reproducibly, one command.

## Quickstart

```bash
# 1. install the CLI (editable, dev mode)
pip install -e .

# 2. scaffold a new project config
txmineflow init --name brca --outdir projects/

# 3. edit projects/brca.yaml to list your public accessions + stages

# 4. run the pipeline (Nextflow does the DAG + distribution)
txmineflow run --project projects/brca.yaml -profile docker

# 5. load results into DuckDB and open the exploration notebook
txmineflow db build --project projects/brca.yaml
txmineflow report --project projects/brca.yaml
```

## Architecture

See [docs/STRUCTURE.md](docs/STRUCTURE.md).

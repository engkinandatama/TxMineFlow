"""txmineflow CLI - the thin orchestration wrapper (PrimerLab pattern).
Validates the project, then shells out to Nextflow; drives db + report after."""
from __future__ import annotations
import subprocess, sys, json, shutil
from pathlib import Path
import click
from .project import Project
from . import __version__

def _nf_args(params: dict) -> list[str]:
    out = []
    for k, v in params.items():
        if v is None:
            continue
        out += [f"--{k}", str(v)]
    return out

@click.group()
@click.version_option(__version__)
def cli():
    """Mine molecular subtypes & signatures across public transcriptomes."""

@cli.command()
@click.option("--name", required=True)
@click.option("--outdir", default="projects", type=click.Path())
def init(name, outdir):
    """Scaffold a new project config from the template."""
    tmpl = Path(__file__).parent.parent / "projects" / "example_brca.yaml"
    dest = Path(outdir) / f"{name}.yaml"
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(tmpl, dest)
    click.echo(f"created {dest} - edit it, then: txmineflow run --project {dest}")

@cli.command(context_settings=dict(ignore_unknown_options=True))
@click.option("--project", "project_path", required=True, type=click.Path(exists=True))
@click.argument("nextflow_args", nargs=-1, type=click.UNPROCESSED)
def run(project_path, nextflow_args):
    """Validate the project and launch the Nextflow DAG."""
    proj = Project.load(project_path)
    click.echo(f"project '{proj.name}' OK - launching Nextflow")
    cmd = ["nextflow", "run", "main.nf", *_nf_args(proj.nextflow_params()), *nextflow_args]
    click.echo(" ".join(cmd))
    sys.exit(subprocess.call(cmd))

@cli.command(name="db")
@click.argument("action", type=click.Choice(["build", "query"]))
@click.option("--project", "project_path", required=True, type=click.Path(exists=True))
@click.option("--sql", default="SELECT * FROM differential_expression LIMIT 10")
def db_cmd(action, project_path, sql):
    """Inspect the DuckDB warehouse produced by a run."""
    import duckdb
    proj = Project.load(project_path)
    dbp = Path("results/warehouse/txmineflow.duckdb")
    if not dbp.exists():
        raise click.ClickException(f"no warehouse at {dbp} - run the pipeline first")
    con = duckdb.connect(str(dbp))
    if action == "query":
        click.echo(con.execute(sql).df().to_string())
    else:
        tbls = con.execute("SHOW TABLES").fetchall()
        click.echo(f"tables: {[t[0] for t in tbls]}")

@cli.command()
@click.option("--project", "project_path", required=True, type=click.Path(exists=True))
def report(project_path):
    """Execute the parameterized exploration notebook -> HTML report."""
    proj = Project.load(project_path)
    cmd = ["jupyter", "nbconvert", "--to", "html", "--execute",
           "notebooks/01_explore.ipynb",
           "--output", f"report_{proj.name}.html"]
    click.echo(" ".join(cmd))
    sys.exit(subprocess.call(cmd))

if __name__ == "__main__":
    cli()

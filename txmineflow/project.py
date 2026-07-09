"""Project config: load + validate. Kept dependency-light and pure - no side
effects, no Nextflow calls (that separation is the point)."""
from __future__ import annotations
from dataclasses import dataclass, field
from pathlib import Path
import yaml

REQUIRED = {"name", "contrast"}

@dataclass
class Project:
    name: str
    contrast: str
    counts: str | None = None
    samples: str | None = None
    accessions: list[str] = field(default_factory=list)
    stages: dict = field(default_factory=dict)
    raw: dict = field(default_factory=dict)

    @classmethod
    def load(cls, path: str | Path) -> "Project":
        data = yaml.safe_load(Path(path).read_text())
        missing = REQUIRED - data.keys()
        if missing:
            raise ValueError(f"project missing required keys: {sorted(missing)}")
        return cls(
            name=data["name"], contrast=data["contrast"],
            counts=data.get("counts"), samples=data.get("samples"),
            accessions=data.get("accessions", []),
            stages=data.get("stages", {}), raw=data,
        )

    def nextflow_params(self) -> dict:
        s = self.stages
        return {
            "counts": self.counts, "samples": self.samples,
            "contrast": self.contrast,
            "accessions": self.accessions,
            "run_fetch":   s.get("fetch",   False),
            "run_quant":   s.get("quant",   False),
            "run_mining":  s.get("mining",  True),
            "run_subtype": s.get("subtype", False),
            "run_compare": s.get("compare", False),
        }

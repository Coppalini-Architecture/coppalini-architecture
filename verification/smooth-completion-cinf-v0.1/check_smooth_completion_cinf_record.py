#!/usr/bin/env python3
"""Check the published smooth-completion receipt's declared structure.

This is a record-integrity check.  It verifies names, boundaries, and source
addresses in the public receipt; it does not re-derive the C-infinity field
calculus.
"""
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RECORD = ROOT / "research/smooth-completion-cinf-t3-v0.1.json"
PREMISES = [
    "hDensityCovariance",
    "gaugeHamiltonianVariationZero",
    "gaussSmearingCovariance",
    "boundaryH",
    "sourceNormalGradient",
    "sourceMomentumAddress",
    "boundaryNormal",
]
HANDLES = ["Φ", "Ψ", "i", "g", "e", "θ", "Λ"]


def main() -> int:
    record = json.loads(RECORD.read_text(encoding="utf-8"))
    assert record["record_type"] == "CoppaliniArchitectureSmoothFieldCompletion"
    assert record["version"] == "0.1"
    assert record["status"] == "source-documented classical mathematics"
    assert record["reader_handles"]["sequence"] == HANDLES
    assert "retain their own names" in record["reader_handles"]["typing_boundary"]
    assert [premise["name"] for premise in record["premises"]] == PREMISES
    for premise in record["premises"]:
        assert premise["classical_counterpart"]
        assert premise["condition"]
        assert premise["source"]
    assert len(record["six_secondary_brackets"]) == 6
    assert "Conditional Lean theorem" in record["lean_boundary"]["theorem_status"]
    assert "open" in record["lean_boundary"]["open"].lower()
    assert "P14" in record["separate_open_obligation"]
    print("PASS: 7/7 named smooth-premise roles, 6 bracket relations, reader handles, and retained Lean/P14 boundaries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

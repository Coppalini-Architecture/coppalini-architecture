#!/usr/bin/env python3
"""Check the current cross-carrier closure-status amendment.

This checker is intentionally local and deterministic.  It confirms the
successor record's exact status split and that the historical records named by
the amendment remain byte-identical to their recorded digests.  External
source commits and CI receipts remain directly linked evidence, not silently
replayed by this checker.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RECORD = ROOT / "research/closure-status-v0.1.json"

EXPECTED_SEGMENTS = {
    "finite_prime_address_interface": "CLOSED_FINITE_PRIME_RATIONAL_FLOOR",
    "classical_t3_field_scope": "CLOSED_CLASSICAL_FIELD_SCOPE",
    "functional_closure_010o": "CONDITIONAL_LEAN_THEOREM",
    "regular_gc_to_suture_segment": "CERTIFIED_REGULAR_GC_TO_SUTURE_SEGMENT",
    "jurisdiction_generic_interface": "LEAN_CHECKED_GENERIC_INTERFACE",
    "archival_tt_local_reader": "SOURCE_REPORTED_ARCHIVAL_SCOPE",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    record = json.loads(RECORD.read_text(encoding="utf-8"))
    require(record.get("record_type") == "CoppaliniArchitecture.CrossCarrierClosureStatus", "record type")
    require(record.get("version") == "0.1", "record version")
    segments = {item.get("id"): item for item in record.get("segments", [])}
    require({key: value.get("status") for key, value in segments.items()} == EXPECTED_SEGMENTS, "segment status split")

    finite = segments["finite_prime_address_interface"]
    require("prime-word address interface" in finite.get("correction", ""), "finite carrier correction")
    require(any("C-infinity" in boundary for boundary in finite.get("does_not_establish", [])), "finite/field separation")

    theorem = segments["functional_closure_010o"]
    require(len(theorem.get("conditions", [])) == 7, "010o premise count")

    bridge = segments["regular_gc_to_suture_segment"]
    bridge_sources = bridge.get("evidence", [])
    require([source.get("commit") for source in bridge_sources[:3]] == [
        "ce044a915108da2bcdd33766efd71765c12d6824",
        "7235356c867ca5469dea607131b762083e74b127",
        "9121e1b468e26566b1ed7ebcd197fa9e373b7e4c",
    ], "bridge source pins")
    require(all(source.get("ci_url", "").startswith("https://github.com/") for source in bridge_sources[:3]), "bridge CI links")
    require(any("whole-root" in boundary for boundary in bridge.get("does_not_establish", [])), "whole-root tail retained")

    tt = segments["archival_tt_local_reader"]
    require("fixed-packet finite-helicity overlap" in tt.get("claim", ""), "TT retained overlap")

    for subject in record.get("historical_subjects", []):
        path = ROOT / subject["path"]
        require(path.is_file(), "historical subject missing: " + subject["path"])
        require(digest(path) == subject["sha256"], "historical digest mismatch: " + subject["path"])

    suture_current = (ROOT / "research/suture-field/residual_ledger_v0_3.md").read_text(encoding="utf-8")
    for marker in ("R-1 resolved", "R-2 resolved", "R-3 resolved"):
        require(marker in suture_current, "Suture v0.3 closure missing: " + marker)

    print("PASS: closure-status v0.1 status split and preserved historical subjects")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, TypeError, json.JSONDecodeError) as error:
        print("FAIL:", error)
        raise SystemExit(1)

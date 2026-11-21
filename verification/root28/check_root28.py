#!/usr/bin/env python3
"""Deterministic checker for Root28 v0.1.

The check has two offices:
  * exact finite arithmetic and the K8 / Z28 scan;
  * retention of the card manifest's source-status and boundary fields.

It does not replay continuous source derivations, instantiate SmoothCompletion,
or make a claim about an external formalization.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from itertools import combinations
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "research" / "metric-minimum-root28-v0.1.json"
LEAN_PATH = ROOT / "proofs" / "Root28Reader.lean"

ROWS = ["Q", "J_rot", "Omega_root", "G_root", "H", "L_s", "F_esc_Lambda_ax"]
SLOTS = ["carrier", "relation", "read", "boundary"]
KINDS = {"EXACT_FINITE", "EXACT_DERIVED", "DECLARED_CARRIER", "OPEN_BOUNDARY"}

# Exact v0.1 status typing by card address.  This makes a promotion or a
# dropped boundary fail deterministically rather than become editorial drift.
EXPECTED_KIND = {
    0: "EXACT_FINITE", 1: "EXACT_FINITE", 2: "EXACT_FINITE", 3: "OPEN_BOUNDARY",
    4: "EXACT_DERIVED", 5: "EXACT_DERIVED", 6: "EXACT_DERIVED", 7: "OPEN_BOUNDARY",
    8: "EXACT_FINITE", 9: "EXACT_FINITE", 10: "EXACT_DERIVED", 11: "OPEN_BOUNDARY",
    12: "EXACT_DERIVED", 13: "EXACT_FINITE", 14: "EXACT_DERIVED", 15: "OPEN_BOUNDARY",
    16: "EXACT_FINITE", 17: "EXACT_FINITE", 18: "EXACT_DERIVED", 19: "OPEN_BOUNDARY",
    20: "DECLARED_CARRIER", 21: "EXACT_FINITE", 22: "EXACT_FINITE", 23: "OPEN_BOUNDARY",
    24: "EXACT_FINITE", 25: "EXACT_DERIVED", 26: "EXACT_DERIVED", 27: "OPEN_BOUNDARY",
}


def canonical_json(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def load_manifest(path: Path = MANIFEST_PATH) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def edge(a: int, b: int) -> tuple[int, int]:
    return tuple(sorted((a, b)))


def matching(r: int) -> set[tuple[int, int]]:
    return {edge(7, r)} | {edge((r + k) % 7, (r - k) % 7) for k in (1, 2, 3)}


def mat_mul(u: tuple[int, int, int, int], v: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    a, b, c, d = u
    e, f, g, h = v
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def mat_add(u: tuple[int, int, int, int], v: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    return tuple(x + y for x, y in zip(u, v))  # type: ignore[return-value]


def mat_neg(u: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    return tuple(-x for x in u)  # type: ignore[return-value]


def mat_scale(k: int, u: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    return tuple(k * x for x in u)  # type: ignore[return-value]


def mat_t(u: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    a, b, c, d = u
    return (a, c, b, d)


def mat_det(u: tuple[int, int, int, int]) -> int:
    a, b, c, d = u
    return a * d - b * c


def check_exact_algebra() -> None:
    I = (1, 0, 0, 1)
    Q = (1, 1, 1, 0)
    J = (0, -1, 1, 0)
    O = (0, 1, -1, 0)
    G = (-2, 1, 1, 2)
    A = mat_add(Q, mat_scale(2, I))  # sqrt(5) * L_ax

    assert mat_mul(Q, Q) == mat_add(Q, I)
    assert mat_det(Q) == -1
    assert J == mat_neg(O)
    assert mat_mul(J, J) == mat_neg(I)
    assert mat_mul(mat_t(J), J) == I
    assert mat_t(O) == mat_neg(O)
    assert mat_mul(O, O) == mat_neg(I)
    assert mat_mul(mat_mul(mat_t(Q), O), Q) == mat_neg(O)
    assert mat_add(mat_mul(Q, O), mat_neg(mat_mul(O, Q))) == G
    assert mat_t(G) == G
    assert mat_mul(G, G) == mat_scale(5, I)
    assert mat_det(G) == -5
    assert mat_mul(mat_mul(mat_t(Q), G), Q) == mat_neg(G)
    assert mat_mul(mat_mul(mat_t(J), G), J) == mat_neg(G)
    assert mat_mul(mat_mul(mat_t(A), G), A) == mat_scale(5, G)
    assert mat_mul(mat_mul(G, A), G) == (10, -5, -5, 15)


def validate_manifest(manifest: dict[str, Any], manifest_digest: str, *, check_lean_binding: bool = True) -> None:
    assert manifest["schema"] == "CoppaliniArchitecture.Root28/v0.1"
    assert manifest["version"] == "0.1"
    assert manifest["scan"]["rows"] == ROWS
    assert manifest["scan"]["slots"] == SLOTS
    assert manifest["scan"]["row_count"] == 7
    assert manifest["scan"]["slot_count"] == 4

    projection = manifest["display_projection"]
    assert projection["id"] == "pi_color"
    assert projection["status"] == "DECLARED_DISPLAY"
    assert len(projection["codomain"]) == 7
    assert len(set(projection["codomain"])) == 7

    sources = manifest["sources"]
    for record in sources.values():
        assert (ROOT / record["path"]).is_file(), record["path"]

    if check_lean_binding:
        lean_source = LEAN_PATH.read_text(encoding="utf-8")
        bound_digest = re.search(r'def manifestSha256 : String :=\s*\n\s*"([0-9a-f]{64})"', lean_source)
        assert bound_digest is not None, "Root28Reader.lean has no manifest digest"
        assert bound_digest.group(1) == manifest_digest, "manifest and Lean digest differ"

    cards = manifest["cards"]
    assert len(cards) == 28
    assert {card["q"] for card in cards} == set(range(28))
    assert {card["id"] for card in cards} == {f"ROOT28-A{a}-B{b}" for a in range(7) for b in range(4)}

    for card in cards:
        q, a, b = card["q"], card["a"], card["b"]
        assert 0 <= q < 28
        assert a == q % 7 and b == q % 4
        assert (8 * a + 21 * b) % 28 == q
        assert card["row"] == ROWS[a]
        assert card["slot"] == SLOTS[b]
        assert card["status"] in KINDS
        assert card["status"] == EXPECTED_KIND[q]
        assert card["source"] in sources
        assert card["sentence"].strip()
        assert card["boundary"].strip()

    boundary_cards = [card for card in cards if card["status"] == "OPEN_BOUNDARY"]
    assert sorted(card["q"] for card in boundary_cards) == [3, 7, 11, 15, 19, 23, 27]
    assert "P14" in next(card for card in cards if card["q"] == 7)["boundary"]
    assert "H = K_C" in next(card for card in cards if card["q"] == 11)["sentence"]
    assert "distinct from the axial coordinate Lambda_ax" in next(card for card in cards if card["q"] == 19)["sentence"]
    assert "no synchronization" in next(card for card in cards if card["q"] == 27)["sentence"]
    assert any("no claim about zeta" in entry.lower() for entry in manifest["global_boundaries"])


def check_k8_scan() -> None:
    vertices = set(range(8))
    all_edges = {edge(a, b) for a, b in combinations(range(8), 2)}
    factorization = [matching(r) for r in range(7)]
    assert len(all_edges) == 28
    assert all(len(m) == 4 for m in factorization)
    assert all({v for pair in m for v in pair} == vertices for m in factorization)
    assert set().union(*factorization) == all_edges
    assert sum(len(m) for m in factorization) == 28


def run_checks(manifest: dict[str, Any]) -> list[str]:
    digest = hashlib.sha256(canonical_json(manifest)).hexdigest()
    validate_manifest(manifest, digest)
    check_k8_scan()
    check_exact_algebra()
    return [
        "ROOT28.1 manifest schema, source paths, and 28 cards",
        "ROOT28.2 scanner q <-> (a,b) and inverse address",
        "ROOT28.3 K8 has 28 edges and seven four-edge matchings",
        "ROOT28.4 card row/slot and status partition",
        "ROOT28.5 finite Q, J_rot, Omega_root, and G_root identities",
        "ROOT28.6 scaled axial transport identities",
        "ROOT28.7 declared display legend and retained boundaries",
    ]


def refusal_controls(manifest: dict[str, Any]) -> list[str]:
    controls: list[tuple[str, dict[str, Any], bool]] = []

    bad = copy.deepcopy(manifest)
    bad["cards"].pop()
    controls.append(("missing card", bad, False))

    bad = copy.deepcopy(manifest)
    bad["cards"][1]["q"] = 0
    controls.append(("duplicate q address", bad, False))

    bad = copy.deepcopy(manifest)
    bad["cards"][0]["a"] = 1
    controls.append(("broken scanner residue", bad, False))

    bad = copy.deepcopy(manifest)
    bad["cards"][3]["status"] = "EXACT_FINITE"
    controls.append(("boundary promoted to exact", bad, False))

    bad = copy.deepcopy(manifest)
    bad["cards"][19]["sentence"] = "L_ax and Lambda_ax are the same object."
    controls.append(("transport-coordinate collapse", bad, False))

    bad = copy.deepcopy(manifest)
    bad["global_boundaries"][-1] = "Root28 claims the external RH formalization."
    controls.append(("external-claim promotion", bad, False))

    bad = copy.deepcopy(manifest)
    bad["display_projection"]["codomain"][6] = "red"
    controls.append(("non-bijective display legend", bad, False))

    bad = copy.deepcopy(manifest)
    bad["title"] = "Altered without a fresh Lean binding"
    controls.append(("manifest drift from Lean binding", bad, True))

    passed: list[str] = []
    for label, altered, require_binding in controls:
        try:
            digest = hashlib.sha256(canonical_json(altered)).hexdigest()
            validate_manifest(altered, digest, check_lean_binding=require_binding)
        except AssertionError:
            passed.append(label)
        else:
            raise AssertionError(f"control was accepted: {label}")
    return passed


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true", help="run refusal controls")
    parser.add_argument("--json", action="store_true", help="emit a compact receipt")
    args = parser.parse_args(argv)

    manifest = load_manifest()
    checks = run_checks(manifest)
    controls = refusal_controls(manifest) if args.self_test else []
    digest = hashlib.sha256(canonical_json(manifest)).hexdigest()
    receipt = {
        "schema": "CoppaliniArchitecture.Root28Receipt/v0.1",
        "manifest": str(MANIFEST_PATH.relative_to(ROOT)),
        "manifest_sha256": digest,
        "reader_result": "28/28 reader obligations passed",
        "scope": "Finite card geometry, integer algebra, source/status retention, and declared boundaries only; not an external-formalization replay.",
        "checks": checks,
        "refusal_controls": controls,
    }
    if args.json:
        print(json.dumps(receipt, indent=2, ensure_ascii=False))
    else:
        print("Root28 deterministic reader check")
        for check in checks:
            print(f"PASS {check}")
        if args.self_test:
            for control in controls:
                print(f"REFUSED {control}")
            print(f"PASS {len(controls)}/{len(controls)} refusal controls")
        print("PASS 28/28 reader obligations passed")
        print("SCOPE finite reader only; not an external-formalization replay")
        print(f"manifest_sha256 {digest}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, TypeError, ValueError) as exc:
        print(f"FAIL Root28 check: {exc}", file=sys.stderr)
        raise SystemExit(1)

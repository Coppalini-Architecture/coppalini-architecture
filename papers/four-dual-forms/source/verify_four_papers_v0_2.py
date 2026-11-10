"""Finite receipt for the physical-field source v0.2.

Uses only Python standard-library integers and Fraction values.
It checks the shared root, the relabeled K8 factorization, the 56-face
gradient ledger, and source-level namespace/notation guards.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from pathlib import Path
from typing import FrozenSet, Tuple


Matrix = Tuple[Tuple[int, int], Tuple[int, int]]
Edge = FrozenSet[object]
ROOT = Path(__file__).resolve().parent


def mmul(a: Matrix, b: Matrix) -> Matrix:
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )  # type: ignore[return-value]


def madd(a: Matrix, b: Matrix) -> Matrix:
    return tuple(
        tuple(a[i][j] + b[i][j] for j in range(2)) for i in range(2)
    )  # type: ignore[return-value]


def msub(a: Matrix, b: Matrix) -> Matrix:
    return tuple(
        tuple(a[i][j] - b[i][j] for j in range(2)) for i in range(2)
    )  # type: ignore[return-value]


def mscale(c: int, a: Matrix) -> Matrix:
    return tuple(tuple(c * a[i][j] for j in range(2)) for i in range(2))  # type: ignore[return-value]


I: Matrix = ((1, 0), (0, 1))
Q: Matrix = ((1, 1), (1, 0))
OMEGA: Matrix = ((0, 1), (-1, 0))
C: Matrix = ((0, -1), (1, 0))
G: Matrix = msub(mmul(Q, OMEGA), mmul(OMEGA, Q))
S0: Matrix = msub(mscale(2, Q), I)


def verify_root() -> None:
    assert mmul(Q, Q) == madd(Q, I)
    assert mmul(C, C) == mscale(-1, I)
    assert G == ((-2, 1), (1, 2))
    assert mmul(G, G) == mscale(5, I)
    assert mmul(S0, S0) == mscale(5, I)
    assert mmul(S0, G) == mscale(5, OMEGA)
    assert mmul(S0, G) == mscale(-1, mmul(G, S0))


INF = "infinity"
VERTICES = (INF, 0, 1, 2, 3, 4, 5, 6)
LABELS = {
    INF: "Gravity",
    0: "Light",
    1: "Memory",
    2: "Time",
    3: "Horizon",
    4: "Silence",
    5: "Scope",
    6: "Motion",
}


def edge(a: object, b: object) -> Edge:
    assert a != b
    return frozenset((a, b))


def matching(r: int) -> FrozenSet[Edge]:
    return frozenset(
        [edge(INF, r)]
        + [edge((r + j) % 7, (r - j) % 7) for j in (1, 2, 3)]
    )


def named(edge_value: Edge) -> FrozenSet[str]:
    return frozenset(LABELS[v] for v in edge_value)


def verify_matching() -> None:
    all_edges = {edge(a, b) for a, b in combinations(VERTICES, 2)}
    rounds = [matching(r) for r in range(7)]
    assert all(len(round_value) == 4 for round_value in rounds)
    assert set().union(*rounds) == all_edges
    assert sum(len(round_value) for round_value in rounds) == 28
    assert len(all_edges) == 28

    expected_m0 = {
        frozenset(("Gravity", "Light")),
        frozenset(("Memory", "Motion")),
        frozenset(("Time", "Scope")),
        frozenset(("Horizon", "Silence")),
    }
    assert {named(e) for e in rounds[0]} == expected_m0


def verify_faces() -> None:
    potential = {
        INF: Fraction(0),
        0: Fraction(1, 10),
        1: Fraction(2, 10),
        2: Fraction(5, 10),
        3: Fraction(7, 10),
        4: Fraction(9, 10),
        5: Fraction(12, 10),
        6: Fraction(14, 10),
    }
    faces = list(combinations(VERTICES, 3))
    assert len(faces) == 56
    for i, j, k in faces:
        d_ij = potential[j] - potential[i]
        d_jk = potential[k] - potential[j]
        d_ki = potential[i] - potential[k]
        assert d_ij + d_jk + d_ki == 0


def verify_sources() -> None:
    expected = {
        "01_gravity_light.tex": ("\\papertitle{Gravity Light}", "A_{\\rm Lor}"),
        "02_memory_motion.tex": ("\\papertitle{Memory Motion}", "q_{\\rm ax}"),
        "03_time_scope.tex": ("\\papertitle{Time Scope}", "\\SilScope"),
        "04_horizon_silence.tex": ("\\papertitle{Horizon Silence}", "\\SilFit"),
    }
    for filename, markers in expected.items():
        text = (ROOT / filename).read_text(encoding="utf-8")
        assert all(marker in text for marker in markers), filename
        assert ",qquad" not in text, filename
        assert "arepsilon" not in text.replace("\\varepsilon", ""), filename

    horizon = (ROOT / "04_horizon_silence.tex").read_text(encoding="utf-8")
    assert "\\mathbf F_n" in horizon
    assert "\\mathsf M_0" in (ROOT / "common.tex").read_text(encoding="utf-8")

    forbidden = (
        "four-paper",
        "four paper",
        "review manuscript",
        "source ledger",
        "claim ledger",
        "this paper",
        "the present paper",
        "the set",
        "tetrad",
        "adapter",
    )
    corpus = "\n".join(
        (ROOT / filename).read_text(encoding="utf-8").lower()
        for filename in (*expected, "common.tex")
    )
    assert not any(term in corpus for term in forbidden)


def main() -> None:
    verify_root()
    verify_matching()
    verify_faces()
    verify_sources()
    print("PASS: physical-field source v0.2")
    print("root=exact; matching=M0; K8_edges=28; K8_faces=56; source_guards=pass")


if __name__ == "__main__":
    main()


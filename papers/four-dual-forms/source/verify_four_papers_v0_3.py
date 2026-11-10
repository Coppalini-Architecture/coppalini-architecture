"""Exact receipt for the physical-field source v0.3.

The verifier uses Python integers and Fraction values only.  It checks the
shared root, the K8 one-factorization, cyclic transport, potential
reconstruction rank, and the repaired source-level typing boundaries.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import combinations
from pathlib import Path
import re
from typing import FrozenSet, Iterable, Sequence, Tuple

import verify_z7_lorentz_extension_v0_2 as z7


ROOT = Path(__file__).resolve().parent
Matrix = Tuple[Tuple[int, int], Tuple[int, int]]
Edge = FrozenSet[object]


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
    lax_numerator = madd(Q, mscale(2, I))
    assert mmul(Q, Q) == madd(Q, I)
    assert mmul(C, C) == mscale(-1, I)
    assert G == ((-2, 1), (1, 2))
    assert mmul(G, G) == mscale(5, I)
    assert mmul(S0, S0) == mscale(5, I)
    assert mmul(C, S0) == G  # H = C S after normalization.
    assert mmul(S0, G) == mscale(5, OMEGA)
    assert mmul(S0, G) == mscale(-1, mmul(G, S0))
    assert mmul(S0, lax_numerator) == mscale(5, Q)  # Q = S L_ax.


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


def tau_vertex(v: object) -> object:
    return INF if v == INF else (int(v) + 1) % 7


def tau_edge(e: Edge) -> Edge:
    a, b = tuple(e)
    return edge(tau_vertex(a), tau_vertex(b))


def verify_matching_and_transport() -> None:
    all_edges = {edge(a, b) for a, b in combinations(VERTICES, 2)}
    layers = [matching(r) for r in range(7)]
    assert all(len(layer) == 4 for layer in layers)
    assert set().union(*layers) == all_edges
    assert sum(len(layer) for layer in layers) == 28

    expected_m0 = {
        frozenset(("Gravity", "Light")),
        frozenset(("Memory", "Motion")),
        frozenset(("Time", "Scope")),
        frozenset(("Horizon", "Silence")),
    }
    assert {
        frozenset(LABELS[v] for v in e) for e in layers[0]
    } == expected_m0

    for r in range(7):
        transported = frozenset(tau_edge(e) for e in layers[r])
        assert transported == layers[(r + 1) % 7]
    for v in VERTICES:
        current = v
        for _ in range(7):
            current = tau_vertex(current)
        assert current == v


def oriented_row(i: object, j: object, k: object, columns: dict[Tuple[object, object], int]) -> list[Fraction]:
    """The row for d_ij + d_jk + d_ki in canonical edge coordinates."""
    row = [Fraction(0) for _ in columns]

    def add(a: object, b: object) -> None:
        ia, ib = sorted((a, b), key=VERTICES.index)
        row[columns[(ia, ib)]] += Fraction(1 if (a, b) == (ia, ib) else -1)

    add(i, j)
    add(j, k)
    add(k, i)
    return row


def fraction_rank(rows: Sequence[Sequence[Fraction]]) -> int:
    work = [list(row) for row in rows]
    if not work:
        return 0
    rank = 0
    width = len(work[0])
    for col in range(width):
        pivot = next((r for r in range(rank, len(work)) if work[r][col]), None)
        if pivot is None:
            continue
        work[rank], work[pivot] = work[pivot], work[rank]
        scale = work[rank][col]
        work[rank] = [entry / scale for entry in work[rank]]
        for r in range(len(work)):
            if r != rank and work[r][col]:
                factor = work[r][col]
                work[r] = [x - factor * y for x, y in zip(work[r], work[rank])]
        rank += 1
        if rank == len(work):
            break
    return rank


def verify_potential_reconstruction() -> None:
    columns = {pair: index for index, pair in enumerate(combinations(VERTICES, 2))}
    face_rows = [oriented_row(i, j, k, columns) for i, j, k in combinations(VERTICES, 3)]
    star_rows = [oriented_row(INF, i, j, columns) for i, j in combinations(range(7), 2)]
    assert len(face_rows) == 56
    assert len(star_rows) == 21
    assert fraction_rank(face_rows) == 21
    assert fraction_rank(star_rows) == 21

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

    def d(a: object, b: object) -> Fraction:
        return potential[b] - potential[a]

    for i, j, k in combinations(VERTICES, 3):
        assert d(i, j) + d(j, k) + d(k, i) == 0

    reconstructed = {INF: Fraction(0)}
    reconstructed.update({v: d(INF, v) for v in range(7)})
    for i, j in combinations(VERTICES, 2):
        assert d(i, j) == reconstructed[j] - reconstructed[i]


def verify_sources() -> None:
    filenames = (
        "01_gravity_light.tex",
        "02_memory_motion.tex",
        "03_time_scope.tex",
        "04_horizon_silence.tex",
    )
    sources = {name: (ROOT / name).read_text(encoding="utf-8") for name in filenames}
    common = (ROOT / "common.tex").read_text(encoding="utf-8")

    assert "\\sharedoccurrence" in common
    assert all("\\sharedoccurrence" in source for source in sources.values())
    assert "\\varrho(\\tau^r)" in sources["01_gravity_light.tex"]
    assert "\\varrho(\\tau^r)" in sources["04_horizon_silence.tex"]
    assert "\\mathcal H_{\\rm pp}" in sources["01_gravity_light.tex"]
    assert "\\xi_{\\rm lift}" in sources["02_memory_motion.tex"]
    assert "\\lambda" not in sources["02_memory_motion.tex"]
    assert "\\lambda_{\\rm wave}" in sources["03_time_scope.tex"]
    assert "\\delta_{\\rm traj}" in sources["03_time_scope.tex"]
    assert "\\kappa_{\\rm traj}" not in sources["03_time_scope.tex"]
    assert "\\Phi:\\RR/2\\pi\\ZZ\\longrightarrow\\mathcal P(V^\\times)" in sources["03_time_scope.tex"]

    horizon = sources["04_horizon_silence.tex"]
    required_horizon = (
        "\\mathcal H_{\\rm hor}",
        "\\sum_aY_a\\,dX_a",
        "\\mathscr L_{n+1}",
        "\\land\\mathsf{Complete}(p)",
        "\\boldsymbol\\varepsilon(p):=",
        "\\boldsymbol\\varepsilon_n=\\boldsymbol\\varepsilon(p)",
        "\\operatorname{rank}\\mathbf h=21",
        "\\sharedoccurrence{HS.9}{HS.10}",
    )
    assert all(token in horizon for token in required_horizon)
    forbidden_horizon = (
        "\\delta W_{\\rm other}",
        "\\mathcal H_n^{\\rm hist}",
        "\\tag{HS.0a}",
        "\\tag{HS.0b}",
        "\\tag{HS.0c}",
        "\\tag{HS.0d}",
    )
    assert not any(token in horizon for token in forbidden_horizon)

    tag_numbers = [int(value) for value in re.findall(r"\\tag\{HS\.(\d+)\}", horizon)]
    for first, second in re.findall(
        r"\\sharedoccurrence\{HS\.(\d+)\}\{HS\.(\d+)\}", horizon
    ):
        tag_numbers.extend((int(first), int(second)))
    assert Counter(tag_numbers) == Counter(range(30))

    forbidden_meta = (
        "four-paper",
        "four paper",
        "review manuscript",
        "source ledger",
        "claim ledger",
        "this paper",
        "the present paper",
        "tetrad",
        "adapter",
    )
    corpus = "\n".join((*sources.values(), common)).lower()
    assert not any(term in corpus for term in forbidden_meta)


def main() -> None:
    verify_root()
    verify_matching_and_transport()
    verify_potential_reconstruction()
    z7.verify_cyclotomic_phase()
    z7.verify_mirror_and_block_constraints()
    verify_sources()
    print("PASS: physical-field source v0.3")
    print(
        "root=exact; K8_edges=28; M0=four_cards; tau^7=I; "
        "triangle_rank=21; potential_reconstruction=exact; source_guards=pass"
    )


if __name__ == "__main__":
    main()

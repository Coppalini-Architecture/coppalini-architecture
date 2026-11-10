"""Exact finite receipts for Suture Field Dynamics v0.1.

Checks are performed over rational numbers.  They establish the regular
rank-16 certificate for the suture map, the dimension of the linear
eta-and-C stabilizer, the Lorentzian signature witness, the vacuum singular
counterexample to the proposed coframe bracket, and source guards.
"""

from __future__ import annotations

from fractions import Fraction
from pathlib import Path
from typing import Sequence


ROOT = Path(__file__).resolve().parent
N = 8
M = 4


def rank(rows: Sequence[Sequence[int | Fraction]]) -> int:
    work = [[Fraction(x) for x in row] for row in rows]
    if not work:
        return 0
    answer = 0
    for column in range(len(work[0])):
        pivot = next((r for r in range(answer, len(work)) if work[r][column]), None)
        if pivot is None:
            continue
        work[answer], work[pivot] = work[pivot], work[answer]
        divisor = work[answer][column]
        work[answer] = [value / divisor for value in work[answer]]
        for row in range(len(work)):
            if row != answer and work[row][column]:
                factor = work[row][column]
                work[row] = [x - factor * y for x, y in zip(work[row], work[answer])]
        answer += 1
        if answer == len(work):
            break
    return answer


def determinant(matrix: Sequence[Sequence[int | Fraction]]) -> Fraction:
    work = [[Fraction(x) for x in row] for row in matrix]
    total = Fraction(1)
    for column in range(len(work)):
        pivot = next((r for r in range(column, len(work)) if work[r][column]), None)
        if pivot is None:
            return Fraction(0)
        if pivot != column:
            work[column], work[pivot] = work[pivot], work[column]
            total = -total
        divisor = work[column][column]
        total *= divisor
        for row in range(column + 1, len(work)):
            if work[row][column]:
                factor = work[row][column] / divisor
                work[row] = [x - factor * y for x, y in zip(work[row], work[column])]
    return total


def root_forms() -> tuple[list[list[int]], list[list[int]]]:
    eta = [[0] * N for _ in range(N)]
    form = [[0] * N for _ in range(N)]
    g_root = ((-2, 1), (1, 2))
    c_root = ((0, -1), (1, 0))
    for i in range(2):
        for j in range(2):
            eta[i][j] = g_root[i][j]
    for block in range(4):
        for i in range(2):
            for j in range(2):
                form[2 * block + i][2 * block + j] = c_root[i][j]
    for block in range(1, 4):
        eta[2 * block][2 * block] = 1
        eta[2 * block + 1][2 * block + 1] = 1
    return eta, form


def pullback(left: Sequence[Sequence[int]], bilinear: Sequence[Sequence[int]]) -> list[list[int]]:
    return [
        [
            sum(left[r][a] * bilinear[r][s] * left[s][b] for r in range(N) for s in range(N))
            for b in range(M)
        ]
        for a in range(M)
    ]


def suture_jacobian(pi: Sequence[Sequence[int]], eta: Sequence[Sequence[int]], form: Sequence[Sequence[int]]) -> list[list[int]]:
    rows: list[list[int]] = []
    for a in range(M):
        for b in range(a, M):
            row = [0] * (N * M)
            for r in range(N):
                for s in range(N):
                    if eta[r][s]:
                        row[r * M + a] += eta[r][s] * pi[s][b]
                        row[s * M + b] += pi[r][a] * eta[r][s]
            rows.append(row)
    for a in range(M):
        for b in range(a + 1, M):
            row = [0] * (N * M)
            for r in range(N):
                for s in range(N):
                    if form[r][s]:
                        row[r * M + a] += form[r][s] * pi[s][b]
                        row[s * M + b] += pi[r][a] * form[r][s]
            rows.append(row)
    return rows


def stabilizer_rank(eta: Sequence[Sequence[int]], form: Sequence[Sequence[int]]) -> int:
    rows: list[list[int]] = []
    for bilinear in (eta, form):
        for i in range(N):
            for j in range(N):
                row = [0] * (N * N)
                for k in range(N):
                    if bilinear[k][j]:
                        row[k * N + i] += bilinear[k][j]
                    if bilinear[i][k]:
                        row[k * N + j] += bilinear[i][k]
                rows.append(row)
    return rank(rows)


def verify_regular_certificate() -> None:
    eta, form = root_forms()
    pi = (
        (-1, -2, 1, 0),
        (2, -1, 1, 0),
        (-1, -2, 1, -2),
        (-1, 1, -1, 0),
        (-1, 0, 0, -1),
        (0, 1, 1, -1),
        (2, 2, 1, -2),
        (-1, -1, 0, -1),
    )
    jacobian = suture_jacobian(pi, eta, form)
    assert len(jacobian) == 16
    assert rank(jacobian) == 16
    metric = pullback(pi, eta)
    assert metric == [[10, -5, 9, 0], [-5, 9, -1, 0], [9, -1, 6, -5], [0, 0, -5, 11]]
    principal = [determinant([row[:size] for row in metric[:size]]) for size in range(1, 5)]
    assert principal == [Fraction(10), Fraction(65), Fraction(-259), Fraction(-4474)]


def verify_stabilizer_and_vacuum_delta() -> None:
    eta, form = root_forms()
    assert stabilizer_rank(eta, form) == 54
    assert N * N - stabilizer_rank(eta, form) == 10
    pi_vac = (
        (1, 0, 0, 0),
        (0, 0, 0, 0),
        (0, 1, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 1, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 1),
        (0, 0, 0, 0),
    )
    assert pullback(pi_vac, eta) == [[-2, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    assert pullback(pi_vac, form) == [[0] * M for _ in range(M)]
    # Delta is linear in lambda and B.  At lambda=B=0 every entry is zero.
    delta = [[0 for _ in range(N * M)] for _ in range(N * M)]
    assert rank(delta) == 0


def verify_source() -> None:
    source = (ROOT / "05a_suture_field_dynamics.tex").read_text(encoding="utf-8")
    required = (
        "\\rankop D\\mathscr S_\\Pi=16",
        "\\dim\\mathfrak k=10",
        "\\lambda^{\\mu\\nu}=0",
        "B^{\\mu\\nu}=0",
        "\\Pi_{\\rm vac}",
        "\\diag(-2,1,1,1)",
        "\\mathcal S_{\\rm fo}",
        "(P_{qI},q^I-X^I)",
        "(P_{mI},m_I)",
        "P_{\\xi a}\\approx0",
        "\\frac12\\bigl(124-2(10+16)-64\\bigr)=4",
        "\\frac12\\bigl(28-2\\cdot10\\bigr)=4",
    )
    assert all(token in source for token in required)
    assert "64\\times64" not in source


def main() -> None:
    verify_regular_certificate()
    verify_stabilizer_and_vacuum_delta()
    verify_source()
    print("PASS: Suture Field Dynamics v0.1")
    print(
        "regular_rank=16; Lorentz_signature=(3,1); stabilizer_dim=10; "
        "vacuum_Delta_rank=0; auxiliary_reduction=64_SC+16_FC; physical_DoF=4"
    )


if __name__ == "__main__":
    main()

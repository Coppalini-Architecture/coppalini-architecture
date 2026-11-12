#!/usr/bin/env python3
"""Exact receipt for the finite witness in The Condition Of Trust.

The script uses only Python's standard library.  It checks the displayed
integer matrix identities, derives the characteristic polynomial, checks the
Fibonacci power law through a substantial finite range, and verifies a finite
same-read/different-decision collision plus its sufficient supplement.
"""

from fractions import Fraction
from pathlib import Path
import re


def matmul(a, b):
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )


def transpose(a):
    return tuple(tuple(a[j][i] for j in range(2)) for i in range(2))


def matscale(c, a):
    return tuple(tuple(c * a[i][j] for j in range(2)) for i in range(2))


def matadd(a, b):
    return tuple(tuple(a[i][j] + b[i][j] for j in range(2)) for i in range(2))


def matpow(a, n):
    out = I
    for _ in range(n):
        out = matmul(out, a)
    return out


def det(a):
    return a[0][0] * a[1][1] - a[0][1] * a[1][0]


def fib(n):
    x, y = 0, 1
    for _ in range(n):
        x, y = y, x + y
    return x


def check(label, condition):
    assert condition, label
    print(f"PASS  {label}")


I = ((1, 0), (0, 1))
Q = ((1, 1), (1, 0))
OMEGA = ((0, 1), (-1, 0))
G = ((-2, 1), (1, 2))
B = ((2, 1), (1, 1))
B_INV = ((1, -1), (-1, 2))


def main():
    source_path = Path(__file__).with_name("The_Condition_Of_Trust.tex")
    source_text = source_path.read_text(encoding="utf-8")
    office_markers = (
        "Memory carries the prior comparison.",
        "Return keeps the relation.",
        "Recognition states the fit.",
        r"\boxed{\rho(T_\gamma x)=\rho(x),\qquad T_\gamma x\ne x.}",
        r"\mathsf R_{n+1}=\snoc(\mathsf R_n,o_{n+1})",
    )
    forbidden_stem = "re" + "tain"
    check(
        "diction gate rejects the former compressed word family",
        re.search(rf"\b{forbidden_stem}\w*\b", source_text, flags=re.IGNORECASE) is None,
    )
    check(
        "paper keeps memory, return, receipt, and recognition as separate offices",
        all(marker in source_text for marker in office_markers),
    )

    check("commutator G = [Q, Omega]", matadd(matmul(Q, OMEGA), matscale(-1, matmul(OMEGA, Q))) == G)
    check("B = Q^2", matmul(Q, Q) == B)
    check("G^2 = 5I", matmul(G, G) == matscale(5, I))
    check("det(G) = -5", det(G) == -5)
    check("B preserves G", matmul(matmul(transpose(B), G), B) == G)
    check("B inverse is displayed correctly", matmul(B, B_INV) == I and matmul(B_INV, B) == I)
    check("characteristic relation B^2 - 3B + I = 0", matadd(matadd(matmul(B, B), matscale(-3, B)), I) == ((0, 0), (0, 0)))
    check("trace(B) = 3 and det(B) = 1", B[0][0] + B[1][1] == 3 and det(B) == 1)

    fibonacci_power_law = True
    infinite_order_witness = True
    for n in range(1, 501):
        expected = ((fib(2 * n + 1), fib(2 * n)), (fib(2 * n), fib(2 * n - 1)))
        power = matpow(B, n)
        fibonacci_power_law &= power == expected
        infinite_order_witness &= power != I
    check("Fibonacci power law n=1..500", fibonacci_power_law)
    check("infinite-order witness B^n != I for n=1..500", infinite_order_witness)

    # The mirror H = G/sqrt(5) is handled through HG relations after clearing
    # the scalar denominator: G B G = 5 B^-1 and H^2 = I.
    check("G B G = 5 B^-1", matmul(matmul(G, B), G) == matscale(5, B_INV))

    # Finite form of the fibre theorem.
    states = ("a", "b", "c")
    read = {"a": 0, "b": 0, "c": 1}
    decision = {"a": 0, "b": 1, "c": 0}
    supplement = {"a": 0, "b": 1, "c": 0}
    collision = any(read[x] == read[y] and decision[x] != decision[y] for x in states for y in states)
    joint_sufficient = all(
        (read[x] != read[y] or supplement[x] != supplement[y] or decision[x] == decision[y])
        for x in states for y in states
    )
    check("same-read / different-decision collision exists", collision)
    check("supplement separates every required decision difference", joint_sufficient)
    check("supplement separates the collided pair", supplement["a"] != supplement["b"])

    # Exact rational check of H^2=I in Q(sqrt(5)) using numerator G^2/5.
    half = Fraction(1, 5)
    check("H^2 = I after exact denominator clearing", matscale(half, matmul(G, G)) == I)
    check("det(H) = -1 after exact denominator clearing", Fraction(det(G), 5) == -1)
    print("\nAll exact finite checks passed.")


if __name__ == "__main__":
    main()

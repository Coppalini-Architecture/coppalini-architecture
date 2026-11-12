"""Exact audit for the scalar-supersymmetry and K8 carrier in The Theory Of Everything.

Uses SymPy exact integers and algebraic numbers only.  It checks the root
grading, the 1|1 oscillator, the seven K8 matchings, and the su(3) adjoint
carrier on Lambda^2(R^8).
"""

from itertools import product
import sympy as sp


M = sp.Matrix
I2 = sp.eye(2)
Q = M([[1, 1], [1, 0]])
Omega = M([[0, 1], [-1, 0]])
G = Q * Omega - Omega * Q
S = 2 * Q - I2
j = -Omega
root5 = sp.sqrt(5)


def bracket(a, pa, b, pb):
    return a * b - (-1) ** (pa * pb) * b * a


def parity(a):
    if G * a * G == 5 * a:
        return 0
    if G * a * G == -5 * a:
        return 1
    return None


def set_f(table, i, j_, k, value):
    cycles = ((i, j_, k, 1), (j_, k, i, 1), (k, i, j_, 1),
              (j_, i, k, -1), (i, k, j_, -1), (k, j_, i, -1))
    for a, b, c, sign in cycles:
        table[a, b, c] = sign * value


def exterior_square(matrix):
    pairs = [(p, q) for p in range(8) for q in range(p + 1, 8)]
    index = {pair: n for n, pair in enumerate(pairs)}
    result = sp.zeros(28)
    for (p, q), column in index.items():
        for r in range(8):
            for u, v, coefficient in ((r, q, matrix[r, p]), (p, r, matrix[r, q])):
                if coefficient == 0 or u == v:
                    continue
                sign = 1
                if u > v:
                    u, v, sign = v, u, -1
                result[index[u, v], column] += sign * coefficient
    return result


def check_root_and_grading():
    assert Q * Q == Q + I2
    assert Omega * Omega == -I2
    assert G == M([[-2, 1], [1, 2]])
    assert G * G == 5 * I2
    assert S * S == 5 * I2
    assert j * j == -I2
    assert S * j + j * S == sp.zeros(2)
    assert S * j == -G
    even = [I2, G]
    odd = [S, j]
    assert all(parity(a) == 0 for a in even)
    assert all(parity(a) == 1 for a in odd)
    assert M([list(a) for a in even + odd]).rank() == 4
    assert Q == (I2 + S) / 2
    for (a, pa), (b, pb) in product(zip(even + odd, [0, 0, 1, 1]), repeat=2):
        assert parity(a * b) == (pa + pb) % 2 or a * b == sp.zeros(2)
    for (a, pa), (b, pb), (c, pc) in product(zip(even + odd, [0, 0, 1, 1]), repeat=3):
        bc = bracket(b, pb, c, pc)
        ab = bracket(a, pa, b, pb)
        ac = bracket(a, pa, c, pc)
        assert bracket(a, pa, bc, (pb + pc) % 2) == (
            bracket(ab, (pa + pb) % 2, c, pc)
            + (-1) ** (pa * pb) * bracket(b, pb, ac, (pa + pc) % 2)
        )


def check_scalar_oscillator():
    plus = S + root5 * j
    minus = S - root5 * j
    assert plus.T == minus
    assert (G * plus * G + 5 * plus).applyfunc(sp.simplify) == sp.zeros(2)
    assert (G * minus * G + 5 * minus).applyfunc(sp.simplify) == sp.zeros(2)
    assert (plus * plus).applyfunc(sp.simplify) == sp.zeros(2)
    assert (minus * minus).applyfunc(sp.simplify) == sp.zeros(2)
    assert (plus * minus + minus * plus).applyfunc(sp.simplify) == 20 * I2


def check_k8_matching_ledger():
    vertices = list(range(7)) + ["infinity"]
    edges = {tuple(sorted((a, b), key=str)) for i, a in enumerate(vertices) for b in vertices[i + 1:]}
    matchings = []
    for r in range(7):
        matching = {tuple(sorted(("infinity", r), key=str))}
        for step in (1, 2, 3):
            matching.add(tuple(sorted(((r + step) % 7, (r - step) % 7), key=str)))
        assert len(matching) == 4
        matchings.append(matching)
    assert set().union(*matchings) == edges
    assert sum(len(matching) for matching in matchings) == 28
    assert all(a.isdisjoint(b) for i, a in enumerate(matchings) for b in matchings[i + 1:])


def check_su3_adjoint_carrier():
    r3 = sp.sqrt(3)
    f = {}
    set_f(f, 1, 2, 3, 1)
    set_f(f, 1, 4, 7, sp.Rational(1, 2))
    set_f(f, 1, 5, 6, -sp.Rational(1, 2))
    set_f(f, 2, 4, 6, sp.Rational(1, 2))
    set_f(f, 2, 5, 7, sp.Rational(1, 2))
    set_f(f, 3, 4, 5, sp.Rational(1, 2))
    set_f(f, 3, 6, 7, -sp.Rational(1, 2))
    set_f(f, 4, 5, 8, r3 / 2)
    set_f(f, 6, 7, 8, r3 / 2)
    ad = [M(8, 8, lambda b, c, a=a: -f.get((a, b + 1, c + 1), 0)) for a in range(1, 9)]
    assert all(a.T == -a for a in ad)
    for a in range(1, 9):
        for b in range(1, 9):
            expected = sum((f.get((a, b, c), 0) * ad[c - 1] for c in range(1, 9)), sp.zeros(8))
            assert ad[a - 1] * ad[b - 1] - ad[b - 1] * ad[a - 1] == expected
    induced = [exterior_square(a) for a in ad]
    casimir = sum((a * a for a in induced), sp.zeros(28))
    assert (casimir + 3 * sp.eye(28)) * (casimir + 6 * sp.eye(28)) == sp.zeros(28)
    assert casimir.trace() == -144


if __name__ == "__main__":
    check_root_and_grading()
    check_scalar_oscillator()
    check_k8_matching_ledger()
    check_su3_adjoint_carrier()
    print("PASS root grading, gl(1|1) super-Jacobi, scalar oscillator, K8 ledger, su(3) exterior-square carrier")

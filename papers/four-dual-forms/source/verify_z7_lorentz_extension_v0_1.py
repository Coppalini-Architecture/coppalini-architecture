"""Exact receipt for the Z7 transport and its Lorentzian block extension.

The calculation uses Python integers and Fraction values only.  The order-seven
phase is represented in Q[zeta_7], with zeta_7^6 + ... + zeta_7 + 1 = 0.
The real transverse rotation is the realification of multiplication by zeta_7.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Iterable, Tuple, Union


Vertex = Union[str, int]
Edge = FrozenSet[Vertex]
Matrix = Tuple[Tuple[int, int], Tuple[int, int]]
INF = "infinity"
VERTICES: Tuple[Vertex, ...] = (INF, 0, 1, 2, 3, 4, 5, 6)
LABEL = {
    INF: "Gravity",
    0: "Light",
    1: "Memory",
    2: "Time",
    3: "Horizon",
    4: "Silence",
    5: "Scope",
    6: "Motion",
}


def edge(a: Vertex, b: Vertex) -> Edge:
    assert a != b
    return frozenset((a, b))


def matching(r: int) -> FrozenSet[Edge]:
    return frozenset(
        [edge(INF, r)]
        + [edge((r + j) % 7, (r - j) % 7) for j in (1, 2, 3)]
    )


def tau_vertex(v: Vertex) -> Vertex:
    return INF if v == INF else (v + 1) % 7


def tau_edge(e: Edge) -> Edge:
    a, b = tuple(e)
    return edge(tau_vertex(a), tau_vertex(b))


def tau_matching(m: Iterable[Edge]) -> FrozenSet[Edge]:
    return frozenset(tau_edge(e) for e in m)


def mmul(a: Matrix, b: Matrix) -> Matrix:
    return tuple(
        tuple(sum(a[i][k] * b[k][j] for k in range(2)) for j in range(2))
        for i in range(2)
    )  # type: ignore[return-value]


def mscale(s: int, a: Matrix) -> Matrix:
    return tuple(tuple(s * a[i][j] for j in range(2)) for i in range(2))  # type: ignore[return-value]


I2: Matrix = ((1, 0), (0, 1))
C: Matrix = ((0, -1), (1, 0))
D: Matrix = ((1, 0), (0, -1))
G_ROOT: Matrix = ((-2, 1), (1, 2))


def verify_factorization_and_transport() -> None:
    layers = [matching(r) for r in range(7)]
    all_edges = {edge(a, b) for a, b in combinations(VERTICES, 2)}
    assert all(len(layer) == 4 for layer in layers)
    assert set().union(*layers) == all_edges
    assert sum(len(layer) for layer in layers) == 28

    for r in range(7):
        assert tau_matching(layers[r]) == layers[(r + 1) % 7]

    for v in VERTICES:
        image = v
        for _ in range(7):
            image = tau_vertex(image)
        assert image == v


def _reduce(coefficients: Tuple[Fraction, ...]) -> Tuple[Fraction, ...]:
    """Reduce modulo z^6+z^5+z^4+z^3+z^2+z+1."""
    values = list(coefficients) + [Fraction(0)] * max(0, 11 - len(coefficients))
    for degree in range(len(values) - 1, 5, -1):
        coefficient = values[degree]
        if coefficient:
            values[degree] = Fraction(0)
            for lower in range(6):
                values[degree - 6 + lower] -= coefficient
    return tuple(values[:6])


@dataclass(frozen=True)
class Zeta7:
    """An exact element of Q[zeta_7], in the basis 1,zeta,...,zeta^5."""

    coefficients: Tuple[Fraction, Fraction, Fraction, Fraction, Fraction, Fraction]

    @classmethod
    def from_values(cls, values: Tuple[Fraction, ...]) -> "Zeta7":
        reduced = _reduce(values)
        return cls(reduced)  # type: ignore[arg-type]

    @classmethod
    def one(cls) -> "Zeta7":
        return cls.from_values((Fraction(1),))

    @classmethod
    def zero(cls) -> "Zeta7":
        return cls.from_values(())

    def __add__(self, other: "Zeta7") -> "Zeta7":
        return Zeta7.from_values(
            tuple(a + b for a, b in zip(self.coefficients, other.coefficients))
        )

    def __neg__(self) -> "Zeta7":
        return Zeta7.from_values(tuple(-a for a in self.coefficients))

    def __sub__(self, other: "Zeta7") -> "Zeta7":
        return self + (-other)

    def scale(self, scalar: Fraction) -> "Zeta7":
        return Zeta7.from_values(tuple(scalar * a for a in self.coefficients))

    def __mul__(self, other: "Zeta7") -> "Zeta7":
        values = [Fraction(0)] * 11
        for i, a in enumerate(self.coefficients):
            for j, b in enumerate(other.coefficients):
                values[i + j] += a * b
        return Zeta7.from_values(tuple(values))

    def power(self, n: int) -> "Zeta7":
        assert n >= 0
        result = Zeta7.one()
        base = self
        exponent = n
        while exponent:
            if exponent & 1:
                result = result * base
            base = base * base
            exponent >>= 1
        return result


ZETA = Zeta7.from_values((Fraction(0), Fraction(1)))


def phase(r: int) -> Zeta7:
    return ZETA.power(r % 7)


@dataclass(frozen=True)
class CyclotomicI:
    """Elements a+b i with a,b in Q[zeta_7] and i^2=-1."""

    real: Zeta7
    imag: Zeta7

    @classmethod
    def zero(cls) -> "CyclotomicI":
        return cls(Zeta7.zero(), Zeta7.zero())

    @classmethod
    def one(cls) -> "CyclotomicI":
        return cls(Zeta7.one(), Zeta7.zero())

    @classmethod
    def integer(cls, value: int) -> "CyclotomicI":
        return cls(Zeta7.one().scale(Fraction(value)), Zeta7.zero())

    @classmethod
    def from_zeta(cls, value: Zeta7) -> "CyclotomicI":
        return cls(value, Zeta7.zero())

    def __add__(self, other: "CyclotomicI") -> "CyclotomicI":
        return CyclotomicI(self.real + other.real, self.imag + other.imag)

    def __neg__(self) -> "CyclotomicI":
        return CyclotomicI(-self.real, -self.imag)

    def __sub__(self, other: "CyclotomicI") -> "CyclotomicI":
        return self + (-other)

    def __mul__(self, other: "CyclotomicI") -> "CyclotomicI":
        return CyclotomicI(
            self.real * other.real - self.imag * other.imag,
            self.real * other.imag + self.imag * other.real,
        )


CEntry = CyclotomicI
CMatrix = Tuple[Tuple[CEntry, ...], ...]


def cidentity(size: int) -> CMatrix:
    return tuple(
        tuple(CEntry.one() if i == j else CEntry.zero() for j in range(size))
        for i in range(size)
    )


def cmatrix_mul(a: CMatrix, b: CMatrix) -> CMatrix:
    assert len(a[0]) == len(b)
    return tuple(
        tuple(
            sum((a[i][k] * b[k][j] for k in range(len(b))), CEntry.zero())
            for j in range(len(b[0]))
        )
        for i in range(len(a))
    )


def ctranspose(a: CMatrix) -> CMatrix:
    return tuple(tuple(a[i][j] for i in range(len(a))) for j in range(len(a[0])))


def cblock_diag(a: CMatrix, b: CMatrix) -> CMatrix:
    n, m = len(a), len(b)
    zero = CEntry.zero()
    return tuple(
        tuple(
            a[i][j]
            if i < n and j < n
            else b[i - n][j - n]
            if i >= n and j >= n
            else zero
            for j in range(n + m)
        )
        for i in range(n + m)
    )


def cfrom_int_matrix(a: Matrix) -> CMatrix:
    return tuple(tuple(CEntry.integer(value) for value in row) for row in a)


def transverse_rotation(r: int) -> CMatrix:
    """The real 2x2 rotation written exactly in Q[zeta_7,i]."""
    z = phase(r)
    z_inverse = phase(-r)
    cosine = CEntry.from_zeta((z + z_inverse).scale(Fraction(1, 2)))
    sine = CEntry(Zeta7.zero(), (z_inverse - z).scale(Fraction(1, 2)))
    return ((cosine, -sine), (sine, cosine))


def verify_cyclotomic_phase() -> None:
    one = Zeta7.one()
    assert ZETA.power(7) == one
    assert all(ZETA.power(r) != one for r in range(1, 7))

    for r in range(7):
        for s in range(7):
            assert phase(r) * phase(s) == phase(r + s)
        assert phase(r) * phase(-r) == one


def verify_mirror_and_block_constraints() -> None:
    # D C D = -C is the transverse mirror identity.
    assert mmul(mmul(D, C), D) == mscale(-1, C)

    i2 = cidentity(2)
    d = cfrom_int_matrix(D)
    c = cfrom_int_matrix(C)
    metric = cblock_diag(cfrom_int_matrix(G_ROOT), i2)
    phase_generator = cblock_diag(c, c)

    # R_r is the realification of multiplication by zeta_7^r.  The entries
    # are represented exactly in Q[zeta_7,i], so all following identities are
    # algebraic equalities rather than floating-point checks.
    for r in range(7):
        rotation = transverse_rotation(r)
        inverse = transverse_rotation(-r)
        rho = cblock_diag(i2, rotation)
        rho_inverse = cblock_diag(i2, inverse)
        assert phase(r) * phase(-r) == Zeta7.one()
        assert cmatrix_mul(ctranspose(rotation), rotation) == i2
        assert cmatrix_mul(cmatrix_mul(d, rotation), d) == inverse
        assert cmatrix_mul(cmatrix_mul(ctranspose(rho), metric), rho) == metric
        assert cmatrix_mul(cmatrix_mul(rho_inverse, phase_generator), rho) == phase_generator
        # The root factor obeys H^2=I by G_ROOT^2=5I; the transverse factor
        # above proves D R_r D=R_{-r}.  Together they give H~ rho H~=rho^-1.
        assert mmul(G_ROOT, G_ROOT) == mscale(5, I2)
        for s in range(7):
            assert cmatrix_mul(rotation, transverse_rotation(s)) == transverse_rotation(r + s)


def main() -> None:
    verify_factorization_and_transport()
    verify_cyclotomic_phase()
    verify_mirror_and_block_constraints()
    print("PASS: Z7 Lorentz extension kernel v0.1")
    print(
        "K8=28 edges; tau^7=I; zeta_7^7=1; "
        "orthogonal_block=exact; metric_phase_mirror=exact"
    )


if __name__ == "__main__":
    main()

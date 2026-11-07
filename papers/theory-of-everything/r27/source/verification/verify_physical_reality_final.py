#!/usr/bin/env python3
"""Deterministic exact verifier for Physical Reality Inside Constraint.

Revision v2 (3 Nov 2026): every PASS line is now backed by an assertion that
checks what the line states. Added: V3 Q(x)Q = kron(Q,Q), factored charpoly,
Descartes-rule inertia from the charpoly, G spectrum; V6 generator inverses;
V8 Ev, alpha, and non-identity assertions; V9 sign law over the 12 fixed words.

No third-party packages, floating-point arithmetic, or random samples are
used. All pass/fail assertions and emitted diagnostics use exact data. The
checks are finite witnesses for the displayed formulas; they do not test the
declared physical interface.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from functools import reduce
from itertools import permutations
from operator import mul
from typing import Dict, Iterable, Tuple


def frac(x: int | Fraction) -> Fraction:
    return x if isinstance(x, Fraction) else Fraction(x)


@dataclass(frozen=True)
class Q5:
    """a + b*sqrt(5), with rational a,b."""

    a: Fraction = Fraction(0)
    b: Fraction = Fraction(0)

    @staticmethod
    def coerce(x: int | Fraction | "Q5") -> "Q5":
        return x if isinstance(x, Q5) else Q5(frac(x), Fraction(0))

    def __add__(self, other):
        other = Q5.coerce(other)
        return Q5(self.a + other.a, self.b + other.b)

    __radd__ = __add__

    def __neg__(self):
        return Q5(-self.a, -self.b)

    def __sub__(self, other):
        return self + (-Q5.coerce(other))

    def __rsub__(self, other):
        return Q5.coerce(other) - self

    def __mul__(self, other):
        other = Q5.coerce(other)
        return Q5(self.a * other.a + 5 * self.b * other.b,
                  self.a * other.b + self.b * other.a)

    __rmul__ = __mul__

    def inverse(self):
        n = self.a * self.a - 5 * self.b * self.b
        if n == 0:
            raise ZeroDivisionError("zero in Q(sqrt(5))")
        return Q5(self.a / n, -self.b / n)

    def __truediv__(self, other):
        return self * Q5.coerce(other).inverse()

    def __rtruediv__(self, other):
        return Q5.coerce(other) / self

    def __pow__(self, n: int):
        if n < 0:
            return self.inverse() ** (-n)
        answer, base = Q5.coerce(1), self
        while n:
            if n & 1:
                answer = answer * base
            base = base * base
            n >>= 1
        return answer

    def __eq__(self, other):
        if isinstance(other, Q5):
            return self.a == other.a and self.b == other.b
        if isinstance(other, (int, Fraction)):
            return self.a == other and self.b == 0
        return NotImplemented

    def sign(self) -> int:
        """Exact sign test, using irrationality of sqrt(5)."""
        if self.b == 0:
            return (self.a > 0) - (self.a < 0)
        if self.b > 0:
            if self.a >= 0:
                return 1
            delta = 5 * self.b * self.b - self.a * self.a
            return (delta > 0) - (delta < 0)
        if self.a <= 0:
            return -1
        delta = self.a * self.a - 5 * self.b * self.b
        return (delta > 0) - (delta < 0)

    def abs(self):
        return self if self.sign() >= 0 else -self

ROOT5 = Q5(0, 1)
PHI = (1 + ROOT5) / 2
PSI = (1 - ROOT5) / 2


def zero_like(x):
    return x - x


def one_like(x):
    return zero_like(x) + 1


def transpose(a):
    return [list(row) for row in zip(*a)]


def matmul(a, b):
    z = zero_like(a[0][0])
    return [[sum((a[i][k] * b[k][j] for k in range(len(b))), z)
             for j in range(len(b[0]))] for i in range(len(a))]


def matsub(a, b):
    return [[a[i][j] - b[i][j] for j in range(len(a[0]))] for i in range(len(a))]


def determinant(a):
    n = len(a)
    z = zero_like(a[0][0])
    answer = z
    for p in permutations(range(n)):
        inversions = sum(p[i] > p[j] for i in range(n) for j in range(i + 1, n))
        term = one_like(a[0][0])
        for i in range(n):
            term = term * a[i][p[i]]
        answer = answer - term if inversions % 2 else answer + term
    return answer


@dataclass(frozen=True)
class Poly:
    """Integer polynomial in lambda, represented by (degree, coefficient)."""

    terms: Tuple[Tuple[int, int], ...] = ()

    @staticmethod
    def make(x: int | Dict[int, int] | "Poly") -> "Poly":
        if isinstance(x, Poly):
            return x
        if isinstance(x, int):
            x = {0: x}
        return Poly(tuple(sorted((d, c) for d, c in x.items() if c)))

    def data(self):
        return dict(self.terms)

    def __add__(self, other):
        d = self.data()
        for degree, coefficient in Poly.make(other).terms:
            d[degree] = d.get(degree, 0) + coefficient
        return Poly.make(d)

    __radd__ = __add__

    def __neg__(self):
        return Poly(tuple((d, -c) for d, c in self.terms))

    def __sub__(self, other):
        return self + (-Poly.make(other))

    def __rsub__(self, other):
        return Poly.make(other) - self

    def __mul__(self, other):
        d: Dict[int, int] = {}
        for d1, c1 in self.terms:
            for d2, c2 in Poly.make(other).terms:
                d[d1 + d2] = d.get(d1 + d2, 0) + c1 * c2
        return Poly.make(d)

    __rmul__ = __mul__


LAMBDA = Poly.make({1: 1})


@dataclass(frozen=True)
class UV:
    """Polynomial in formal u,H with Q(sqrt(5)) coefficients."""

    terms: Tuple[Tuple[Tuple[int, int], Q5], ...] = ()

    @staticmethod
    def make(x: int | Q5 | Dict[Tuple[int, int], int | Q5] | "UV") -> "UV":
        if isinstance(x, UV):
            return x
        if isinstance(x, (int, Q5)):
            x = {(0, 0): Q5.coerce(x)}
        d: Dict[Tuple[int, int], Q5] = {}
        for degree, coefficient in x.items():
            c = Q5.coerce(coefficient)
            d[degree] = d.get(degree, Q5.coerce(0)) + c
        return UV(tuple(sorted((degree, c) for degree, c in d.items() if c != 0)))

    @staticmethod
    def monomial(u_power: int, h_power: int, coefficient: int | Q5 = 1):
        return UV.make({(u_power, h_power): coefficient})

    def data(self):
        return dict(self.terms)

    def __add__(self, other):
        d = self.data()
        for degree, c in UV.make(other).terms:
            d[degree] = d.get(degree, Q5.coerce(0)) + c
        return UV.make(d)

    __radd__ = __add__

    def __neg__(self):
        return UV(tuple((degree, -c) for degree, c in self.terms))

    def __sub__(self, other):
        return self + (-UV.make(other))

    def __rsub__(self, other):
        return UV.make(other) - self

    def __mul__(self, other):
        d: Dict[Tuple[int, int], Q5] = {}
        for (u1, h1), c1 in self.terms:
            for (u2, h2), c2 in UV.make(other).terms:
                degree = (u1 + u2, h1 + h2)
                d[degree] = d.get(degree, Q5.coerce(0)) + c1 * c2
        return UV.make(d)

    __rmul__ = __mul__


Monomial = Tuple[Tuple[Tuple[int, int, int], int], ...]


@dataclass(frozen=True)
class Jet:
    """Polynomial jet algebra for a formal H(u,x,y), independent of v."""

    terms: Tuple[Tuple[Monomial, Fraction], ...] = ()

    @staticmethod
    def make(x: int | Dict[Monomial, int | Fraction] | "Jet") -> "Jet":
        if isinstance(x, Jet):
            return x
        if isinstance(x, int):
            x = {(): Fraction(x)}
        d: Dict[Monomial, Fraction] = {}
        for monomial, coefficient in x.items():
            c = frac(coefficient)
            d[monomial] = d.get(monomial, Fraction(0)) + c
        return Jet(tuple(sorted((m, c) for m, c in d.items() if c)))

    @staticmethod
    def var():
        return Jet.make({(((0, 0, 0), 1),): 1})

    def data(self):
        return dict(self.terms)

    def __add__(self, other):
        d = self.data()
        for monomial, coefficient in Jet.make(other).terms:
            d[monomial] = d.get(monomial, Fraction(0)) + coefficient
        return Jet.make(d)

    __radd__ = __add__

    def __neg__(self):
        return Jet(tuple((m, -c) for m, c in self.terms))

    def __sub__(self, other):
        return self + (-Jet.make(other))

    def __rsub__(self, other):
        return Jet.make(other) - self

    def __mul__(self, other):
        d: Dict[Monomial, Fraction] = {}
        for left, lc in self.terms:
            for right, rc in Jet.make(other).terms:
                powers: Dict[Tuple[int, int, int], int] = {}
                for index, exponent in left + right:
                    powers[index] = powers.get(index, 0) + exponent
                monomial = tuple(sorted((index, exponent) for index, exponent in powers.items() if exponent))
                d[monomial] = d.get(monomial, Fraction(0)) + lc * rc
        return Jet.make(d)

    __rmul__ = __mul__

    def __truediv__(self, other: int | Fraction):
        return Jet(tuple((m, c / frac(other)) for m, c in self.terms))

    def diff(self, coordinate: int):
        if coordinate == 1:  # v
            return Jet.make(0)
        increment = {0: (1, 0, 0), 2: (0, 1, 0), 3: (0, 0, 1)}[coordinate]
        d: Dict[Monomial, Fraction] = {}
        for monomial, coefficient in self.terms:
            for index, exponent in monomial:
                new_index = tuple(index[i] + increment[i] for i in range(3))
                powers = dict(monomial)
                powers[index] -= 1
                if powers[index] == 0:
                    del powers[index]
                powers[new_index] = powers.get(new_index, 0) + 1
                new_monomial = tuple(sorted(powers.items()))
                d[new_monomial] = d.get(new_monomial, Fraction(0)) + coefficient * exponent
        return Jet.make(d)


@dataclass(frozen=True)
class Laurent:
    """Integer Laurent polynomial in t."""

    terms: Tuple[Tuple[int, int], ...] = ()

    @staticmethod
    def make(x: int | Dict[int, int] | "Laurent") -> "Laurent":
        if isinstance(x, Laurent):
            return x
        if isinstance(x, int):
            x = {0: x}
        d: Dict[int, int] = {}
        for exponent, coefficient in x.items():
            d[exponent] = d.get(exponent, 0) + coefficient
        return Laurent(tuple(sorted((e, c) for e, c in d.items() if c)))

    @staticmethod
    def mono(exponent: int, coefficient: int = 1):
        return Laurent.make({exponent: coefficient})

    def data(self):
        return dict(self.terms)

    def __add__(self, other):
        d = self.data()
        for exponent, coefficient in Laurent.make(other).terms:
            d[exponent] = d.get(exponent, 0) + coefficient
        return Laurent.make(d)

    __radd__ = __add__

    def __neg__(self):
        return Laurent(tuple((e, -c) for e, c in self.terms))

    def __sub__(self, other):
        return self + (-Laurent.make(other))

    def __rsub__(self, other):
        return Laurent.make(other) - self

    def __mul__(self, other):
        d: Dict[int, int] = {}
        for e1, c1 in self.terms:
            for e2, c2 in Laurent.make(other).terms:
                d[e1 + e2] = d.get(e1 + e2, 0) + c1 * c2
        return Laurent.make(d)

    __rmul__ = __mul__


T = Laurent.mono(1)


@dataclass(frozen=True)
class ZPhi:
    """a+b*Phi with integral coordinates and Phi^2=Phi+1."""

    a: int = 0
    b: int = 0

    def __add__(self, other):
        other = zcoerce(other)
        return ZPhi(self.a + other.a, self.b + other.b)

    __radd__ = __add__

    def __neg__(self):
        return ZPhi(-self.a, -self.b)

    def __sub__(self, other):
        return self + (-zcoerce(other))

    def __rsub__(self, other):
        return zcoerce(other) - self

    def __mul__(self, other):
        other = zcoerce(other)
        return ZPhi(self.a * other.a + self.b * other.b,
                    self.a * other.b + self.b * other.a + self.b * other.b)

    __rmul__ = __mul__

    def sign(self):
        return Q5(Fraction(2 * self.a + self.b, 2), Fraction(self.b, 2)).sign()


def zcoerce(x: int | ZPhi) -> ZPhi:
    return x if isinstance(x, ZPhi) else ZPhi(x, 0)


ZT = ZPhi(1, 1)       # Phi^2
ZTI = ZPhi(2, -1)     # Phi^-2


def fibonacci(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def inertia(values: Iterable[Q5]) -> Tuple[int, int, int]:
    signs = [x.sign() for x in values]
    return signs.count(1), signs.count(-1), signs.count(0)


def main() -> None:
    print("== V1 root carrier")
    q = [[1, 1], [1, 0]]
    omega = [[0, 1], [-1, 0]]
    g = matsub(matmul(q, omega), matmul(omega, q))
    assert g == [[-2, 1], [1, 2]]
    assert matmul(g, g) == [[5, 0], [0, 5]] and determinant(g) == -5
    print("PASS V1 G = [[-2, 1], [1, 2]], G^2 = 5I, det G = -5")

    print("\n== V2 null-coordinate congruence")
    gq = [[Q5.coerce(x) for x in row] for row in g]
    n_plus, n_minus = [[Q5.coerce(1)], [-PSI]], [[Q5.coerce(1)], [-PHI]]
    assert matmul(transpose(n_plus), matmul(gq, n_plus))[0][0] == 0
    assert matmul(transpose(n_minus), matmul(gq, n_minus))[0][0] == 0
    assert matmul(transpose(n_plus), matmul(gq, n_minus))[0][0] == -5
    m = [[Q5.coerce(1), Q5(Fraction(-1, 5))], [-PSI, PHI / 5]]
    assert matmul(transpose(m), matmul(gq, m)) == [[0, 1], [1, 0]]
    assert determinant(m) == ROOT5 / 5
    print("PASS V2 M^T G M = [[0, 1], [1, 0]], det M = sqrt(5)/5")

    print("\n== V3 tensor spectrum and signatures")
    qq = [[1, 1, 1, 1], [1, 0, 1, 0], [1, 1, 0, 0], [1, 0, 0, 0]]
    characteristic = [[LAMBDA - qq[i][j] if i == j else Poly.make(-qq[i][j])
                       for j in range(4)] for i in range(4)]
    assert determinant(characteristic) == Poly.make({4: 1, 3: -1, 2: -4, 1: -1, 0: 1})
    kron = [[q[i // 2][j // 2] * q[i % 2][j % 2] for j in range(4)] for i in range(4)]
    assert qq == kron and qq == transpose(qq)
    assert PHI**2 + PSI**2 == 3 and PHI**2 * PSI**2 == 1
    char = Poly.make({4: 1, 3: -1, 2: -4, 1: -1, 0: 1})
    assert (LAMBDA + 1) * (LAMBDA + 1) * (LAMBDA * LAMBDA - 3 * LAMBDA + 1) == char

    def sign_changes(p):
        coeffs = [c for _, c in sorted(p.terms, reverse=True)]
        return sum(1 for a, b in zip(coeffs, coeffs[1:]) if a * b < 0)

    char_neg = Poly.make({d: c * (-1) ** d for d, c in char.terms})
    # symmetric => all roots real; no zero root; Descartes bounds (2,2) sum to 4 => exactly (2,2,0)
    assert char.data()[0] != 0 and (sign_changes(char), sign_changes(char_neg)) == (2, 2)
    g_char = [[LAMBDA - g[0][0], Poly.make(-g[0][1])], [Poly.make(-g[1][0]), LAMBDA - g[1][1]]]
    assert determinant(g_char) == Poly.make({2: 1, 0: -5})
    assert inertia([Q5.coerce(-1), Q5.coerce(-1), PHI**2, PSI**2]) == (2, 2, 0)
    assert inertia([ROOT5, -ROOT5, Q5.coerce(1), Q5.coerce(1)]) == (3, 1, 0)
    print("PASS V3 charpoly = (lambda+1)^2(lambda-Phi^2)(lambda-Psi^2)")
    print("PASS V3 inertia Q(x)Q = (2,2,0); inertia G(+)I2 = (3,1,0)")

    print("\n== V4 rejected diagonal transition")
    inv_root = ROOT5 / 5
    diagonal = [UV.monomial(1, 0, inv_root), UV.monomial(0, 1, inv_root),
                UV.monomial(0, 0, PHI * inv_root), UV.monomial(0, 0, PSI * inv_root)]
    pulled = [[UV.make(qq[i][j]) * diagonal[i] * diagonal[j] for j in range(4)] for i in range(4)]
    assert pulled[2][2] == UV.make(0) and pulled[3][3] == UV.make(0)
    assert pulled[0][1] == UV.monomial(1, 1, Fraction(1, 5))
    assert determinant(pulled) == UV.monomial(2, 2, Fraction(1, 625))
    print("PASS V4 g_xx=g_yy=0, g_uv=uH/5, det g=u^2H^2/625")

    print("\n== V5 pp-wave Ricci")
    h, zero, one = Jet.var(), Jet.make(0), Jet.make(1)
    gm = [[h, one, zero, zero], [one, zero, zero, zero], [zero, zero, one, zero], [zero, zero, zero, one]]
    gi = [[zero, one, zero, zero], [one, -h, zero, zero], [zero, zero, one, zero], [zero, zero, zero, one]]
    assert matmul(gm, gi) == [[one, zero, zero, zero], [zero, one, zero, zero], [zero, zero, one, zero], [zero, zero, zero, one]]

    def gamma(a: int, b: int, c: int) -> Jet:
        return sum((gi[a][d] * (gm[d][b].diff(c) + gm[d][c].diff(b) - gm[b][c].diff(d)) / 2
                    for d in range(4)), zero)

    christoffel = [[[gamma(a, b, c) for c in range(4)] for b in range(4)] for a in range(4)]

    def ricci(b: int, c: int) -> Jet:
        return sum((christoffel[a][b][c].diff(a) - christoffel[a][b][a].diff(c) +
                    sum((christoffel[a][a][d] * christoffel[d][b][c] -
                         christoffel[a][c][d] * christoffel[d][b][a]
                         for d in range(4)), zero)
                    for a in range(4)), zero)

    ric = [[ricci(i, j) for j in range(4)] for i in range(4)]
    expected = -(h.diff(2).diff(2) + h.diff(3).diff(3)) / 2
    assert ric[0][0] == expected
    assert all(ric[i][j] == zero for i in range(4) for j in range(4) if (i, j) != (0, 0))
    assert sum((gi[i][j] * ric[i][j] for i in range(4) for j in range(4)), zero) == zero
    assert determinant(gm) == Jet.make(-1)
    print("PASS V5 det g=-1, R_uu=-(H_xx+H_yy)/2, scalar R=0")

    print("\n== V6 generic reduced Burau")
    s1 = [[-T, Laurent.make(1)], [Laurent.make(0), Laurent.make(1)]]
    s2 = [[Laurent.make(1), Laurent.make(0)], [T, -T]]
    triple_l = matmul(matmul(s1, s2), s1)
    triple_r = matmul(matmul(s2, s1), s2)
    expected_triple = [[Laurent.make(0), -T], [-(T * T), Laurent.make(0)]]
    assert triple_l == triple_r == expected_triple and determinant(triple_l) == Laurent.mono(3, -1)
    s1_inv = [[Laurent.mono(-1, -1), Laurent.mono(-1)], [Laurent.make(0), Laurent.make(1)]]
    s2_inv = [[Laurent.make(1), Laurent.make(0)], [Laurent.make(1), Laurent.mono(-1, -1)]]
    ident2 = [[Laurent.make(1), Laurent.make(0)], [Laurent.make(0), Laurent.make(1)]]
    assert matmul(s1, s1_inv) == ident2 == matmul(s1_inv, s1)
    assert matmul(s2, s2_inv) == ident2 == matmul(s2_inv, s2)
    generators = {1: s1, -1: s1_inv, 2: s2, -2: s2_inv}
    fixed_words = [(), (1,), (-1,), (2,), (-2,), (1, 2, 1), (2, 1, 2),
                   (1, -2, 1, 2), (-1, -2, 2, 1), (1, 1, -2, -2),
                   (2, -1, -1, 2, 1), (-2, 1, 2, -1, -2)]
    for word in fixed_words:
        product = [[Laurent.make(1), Laurent.make(0)], [Laurent.make(0), Laurent.make(1)]]
        for generator in word:
            product = matmul(product, generators[generator])
        alpha = sum(1 if generator > 0 else -1 for generator in word)
        assert determinant(product) == Laurent.mono(alpha, -1 if alpha % 2 else 1)
    print("PASS V6 braid product and det psi(w)=(-t)^alpha(w) over 12 fixed words")

    print("\n== V7 Fibonacci correction")
    for n in range(1, 25):
        fn = fibonacci(n)
        assert fibonacci(n + 1) - PHI * fn == PSI**n
        error = (PHI - Q5.coerce(Fraction(fibonacci(n + 1), fn))).abs()
        correction = 1 - ((-1) ** n) * PHI ** (-2 * n)
        assert error == (PSI**n).abs() / fn == correction / (ROOT5 * fn * fn)
    print("PASS V7 exact Fibonacci identity, n=1..24")
    print("PASS V7 correction factor is retained in Q(sqrt(5)) for every checked n")

    print("\n== V8 words versus winding")
    word = (2, 3, 5)
    swap_twice = tuple(reversed(word[:2])) + word[2:]
    swap_twice = tuple(reversed(swap_twice[:2])) + swap_twice[2:]
    assert swap_twice == word and Fraction(3**12, 2**19) == Fraction(531441, 524288)
    assert tuple(reversed(word[:2])) + word[2:] != word   # one swap does not fix the word
    assert sum(1 if g > 0 else -1 for g in (1, 1)) == 2   # alpha(sigma1^2)
    ev = lambda w: reduce(mul, w, 1)
    assert ev((2, 3)) == ev((3, 2)) == 6 and (2, 3) != (3, 2)
    assert ev(word) == ev(swap_twice) == 30
    assert Fraction(3**12, 2**19) != 1
    print("PASS V8 sigma1^2 fixes (2,3,5), while alpha(sigma1^2)=2")
    print("PASS V8 Ev(2,3)=Ev(3,2)=6; 3^12/2^19=531441/524288 != 1")

    print("\n== V9 Z[Phi] and orientation parity")
    assert ZT * ZTI == ZPhi(1, 0)
    assert ZT * ZT == ZPhi(2, 3) and ZPhi(0, 1) * ZPhi(0, 1) == ZT
    assert ZPhi(0, 1).sign() == 1 and ZPhi(0, -1).sign() == -1 and ZTI.sign() == 1
    zs1 = [[-ZT, ZPhi(1, 0)], [ZPhi(0, 0), ZPhi(1, 0)]]
    zs2 = [[ZPhi(1, 0), ZPhi(0, 0)], [ZT, -ZT]]
    square = matmul(zs1, zs1)
    assert square == [[ZT * ZT, ZPhi(0, -1)], [ZPhi(0, 0), ZPhi(1, 0)]]
    assert determinant(zs1).sign() == -1 and determinant(square).sign() == 1
    assert matmul(matmul(zs1, zs2), zs1) == matmul(matmul(zs2, zs1), zs2)
    zid = [[ZPhi(1, 0), ZPhi(0, 0)], [ZPhi(0, 0), ZPhi(1, 0)]]
    zi1 = [[-ZTI, ZTI], [ZPhi(0, 0), ZPhi(1, 0)]]
    zi2 = [[ZPhi(1, 0), ZPhi(0, 0)], [ZPhi(1, 0), -ZTI]]
    assert matmul(zs1, zi1) == zid == matmul(zi1, zs1)
    assert matmul(zs2, zi2) == zid == matmul(zi2, zs2)
    zgen = {1: zs1, -1: zi1, 2: zs2, -2: zi2}
    for w_ in fixed_words:
        prod_ = zid
        for g_ in w_:
            prod_ = matmul(prod_, zgen[g_])
        assert determinant(prod_).sign() == (-1) ** sum(1 if g_ > 0 else -1 for g_ in w_)
    print("PASS V9 Phi^2=1+Phi, Phi^4=2+3Phi, psi(s1)^2=[[Phi^4,-Phi],[0,1]]")
    print("PASS V9 sign det psi(w)|t=Phi^2 = (-1)^alpha(w)")

    print("\n== V10 receipt-state implementation")
    faces = ("Color", "Meaning", "Memory", "Motion")
    registry = []

    def admit(face: str) -> bool:
        want = faces[len(registry) % len(faces)]
        if face != want:
            return False
        registry.append((face, len(registry)))
        return True

    assert admit("Color") and admit("Meaning")
    assert not admit("Motion") and len(registry) == 2
    assert admit("Memory") and admit("Motion") and admit("Color")
    assert registry[-1] == ("Color", 4) and len(registry) == 5
    print("PASS V10 cyclic state machine rejects out-of-order Motion and appends only admitted receipts")

    print("\nALL DETERMINISTIC EXACT CHECKS PASSED")


if __name__ == "__main__":
    main()

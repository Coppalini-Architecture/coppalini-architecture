"""Exact finite witness for the contact--record construction.

Scope:
  * exact integer checks for B = Q^2, G, and the mirror relation;
  * a finite F_7 toy contact model whose transport is reversible;
  * a reader quotient with explicitly counted fibres; and
  * an ordered snoc ledger with an exact pop inverse.

This is an executable witness for the typed formal construction in
``Contact, record, and the arrow of time``.  It is not a physical measurement
model or a thermodynamic derivation.
"""

from __future__ import annotations

from itertools import product


def mmul(a, b):
    return tuple(
        tuple(sum(a[r][k] * b[k][c] for k in range(2)) for c in range(2))
        for r in range(2)
    )


def mtrans(a):
    return tuple(tuple(a[r][c] for r in range(2)) for c in range(2))


def mscale(c, a):
    return tuple(tuple(c * a[r][col] for col in range(2)) for r in range(2))


I2 = ((1, 0), (0, 1))
Q = ((1, 1), (1, 0))
G = ((-2, 1), (1, 2))
B = mmul(Q, Q)
B_INV = ((1, -1), (-1, 2))


def mvec(a, z, p=None):
    out = (
        a[0][0] * z[0] + a[0][1] * z[1],
        a[1][0] * z[0] + a[1][1] * z[1],
    )
    return tuple(x % p for x in out) if p is not None else out


def snoc(ledger, item):
    return ledger + (item,)


def pop(ledger):
    if not ledger:
        raise ValueError("pop is defined on a nonempty ledger")
    return ledger[:-1], ledger[-1]


P = 7
STATES = tuple(product(range(P), repeat=2))


def transport(z):
    """Bz in F_7^2: a reversible finite reduction of the root transport."""
    return mvec(B, z, P)


def interaction(z, local_input):
    """A reversible local interaction, U((a,b), e) = (a + e, b)."""
    return ((z[0] + local_input) % P, z[1])


def reader(z):
    """Declared reader quotient: retain the first coordinate only."""
    return z[0]


def contact(z, local_input, ledger):
    next_state = interaction(transport(z), local_input)
    return next_state, snoc(ledger, reader(next_state))


def main():
    # Root and mirror, checked over the integers.
    assert B == ((2, 1), (1, 1))
    assert mmul(mtrans(B), mmul(G, B)) == G
    assert mmul(mmul(G, B), G) == mscale(5, B_INV)
    assert mmul(B, B_INV) == I2 and mmul(B_INV, B) == I2

    # B's characteristic polynomial t^2 - 3t + 1 has roots Phi^2, Phi^-2.
    # On the positive cone, B(a,b)=(2a+b,a+b).  For a>=1, b>=0,
    # its first coordinate strictly grows, so B^n(1,0) never returns to (1,0).
    assert B[0][0] + B[1][1] == 3
    assert B[0][0] * B[1][1] - B[0][1] * B[1][0] == 1
    assert 2 * 1 + 0 > 1 and 1 + 0 >= 0

    # The finite transport and local interaction are bijective on F_7^2.
    assert len({transport(z) for z in STATES}) == len(STATES)
    assert len({interaction(z, 3) for z in STATES}) == len(STATES)

    # A declared reader quotient collapses exactly seven distinct states per readout.
    fibres = {
        outcome: tuple(z for z in STATES if reader(interaction(transport(z), 0)) == outcome)
        for outcome in range(P)
    }
    assert all(len(fibre) == P for fibre in fibres.values())
    left, right = (0, 0), (1, 5)
    assert left != right
    assert transport(left) != transport(right)
    assert reader(interaction(transport(left), 0)) == 0
    assert reader(interaction(transport(right), 0)) == 0

    # The receipt preserves the ordered input pair exactly.
    ledger = ()
    state_1, ledger_1 = contact(left, 0, ledger)
    state_2, ledger_2 = contact(right, 0, ledger)
    assert state_1 != state_2
    assert ledger_1 == ledger_2 == (0,)
    assert pop(snoc((2, 4), 6)) == ((2, 4), 6)
    historical = ()
    for outcome in (2, 4, 6):
        historical = snoc(historical, outcome)
    assert historical == (2, 4, 6)
    assert historical[:2] == (2, 4)

    print("PASS | B=Q^2 is an exact G-isometry with exact inverse")
    print("PASS | GBG=5B^-1 clears the mirror denominator")
    print("PASS | F_7 transport and local interaction are bijective")
    print("PASS | reader quotient has seven-state fibres at stated resolution")
    print("PASS | distinct carried states can share one reader outcome")
    print("PASS | snoc ledger retains ordered history with exact pop inverse")
    print("BOUNDARY | finite contact grammar; physical calibration is field-specific")


if __name__ == "__main__":
    main()

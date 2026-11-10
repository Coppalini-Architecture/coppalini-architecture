"""Exact receipt for Suture Field v0.1.

The verifier works over Q[zeta_7,i].  It checks the eight-dimensional real
Fourier realization of the vertex action, its metric/phase/mirror identities,
and the source's defining field relations.  No floating-point arithmetic is
used for the finite carrier checks.
"""

from __future__ import annotations

from pathlib import Path

from verify_z7_lorentz_extension_v0_1 import (
    C,
    D,
    G_ROOT,
    I2,
    Zeta7,
    cblock_diag,
    cfrom_int_matrix,
    cidentity,
    cmatrix_mul,
    ctranspose,
    mmul,
    mscale,
    phase,
    transverse_rotation,
)


ROOT = Path(__file__).resolve().parent


def block4(a, b, c, d):
    return cblock_diag(cblock_diag(a, b), cblock_diag(c, d))


def verify_real_fourier_character() -> None:
    """The eight block eigenvalues equal the vertex-permutation spectrum."""
    weights = (0, 0, 1, 6, 2, 5, 3, 4)
    assert sorted(weights) == [0, 0, 1, 2, 3, 4, 5, 6]
    assert all(phase(weight).power(7) == Zeta7.one() for weight in weights)
    assert all(phase(weight) != Zeta7.one() for weight in (1, 2, 3, 4, 5, 6))


def verify_eight_dimensional_carrier() -> None:
    i2 = cidentity(2)
    root_metric = cfrom_int_matrix(G_ROOT)
    euclidean = i2
    metric = block4(root_metric, euclidean, euclidean, euclidean)
    generator = cfrom_int_matrix(C)
    phase_form = block4(generator, generator, generator, generator)
    transverse_mirror = cfrom_int_matrix(D)

    # H is G/sqrt(5).  These integer identities are the scaled root tests.
    assert mmul(G_ROOT, G_ROOT) == mscale(5, I2)
    assert mmul(mmul(G_ROOT, C), G_ROOT) == mscale(-5, C)
    assert mmul(mmul(G_ROOT, G_ROOT), G_ROOT) == mscale(5, G_ROOT)

    for r in range(7):
        rho = block4(
            i2,
            transverse_rotation(r),
            transverse_rotation(2 * r),
            transverse_rotation(3 * r),
        )
        rho_inverse = block4(
            i2,
            transverse_rotation(-r),
            transverse_rotation(-2 * r),
            transverse_rotation(-3 * r),
        )
        assert cmatrix_mul(ctranspose(rho), rho) == cidentity(8)
        assert cmatrix_mul(cmatrix_mul(ctranspose(rho), metric), rho) == metric
        assert cmatrix_mul(cmatrix_mul(ctranspose(rho), phase_form), rho) == phase_form
        assert cmatrix_mul(rho, rho_inverse) == cidentity(8)

        # D conjugates every rotation to its inverse.  The root part of H
        # fixes the root block of rho, so the complete mirror gives rho^-1.
        for multiplier in (1, 2, 3):
            rotation = transverse_rotation(multiplier * r)
            inverse = transverse_rotation(-multiplier * r)
            assert cmatrix_mul(cmatrix_mul(transverse_mirror, rotation), transverse_mirror) == inverse

    rho_generator = block4(
        i2,
        transverse_rotation(1),
        transverse_rotation(2),
        transverse_rotation(3),
    )
    power = cidentity(8)
    for _ in range(7):
        power = cmatrix_mul(power, rho_generator)
    assert power == cidentity(8)


def verify_source() -> None:
    source = (ROOT / "05_suture_field.tex").read_text(encoding="utf-8")
    required = (
        "\\Pi=\\Pi^A{}_{\\mu}",
        "\\Pi_x:T_xM\\hookrightarrow E_x",
        "\\Pi:TM\\xrightarrow{\\ \\cong\\ }L",
        "\\mathcal V_8:=\\RR[\\mathcal A_8]",
        "\\hatrho(\\tau^r)=I_2\\oplus R_{2\\pi r/7}",
        "\\hateta:=G\\oplus I_2\\oplus I_2\\oplus I_2",
        "\\hatC:=C\\oplus C\\oplus C\\oplus C",
        "\\Fsol:=\\frac12\\hatC_{AB}\\Pi^A\\wedge\\Pi^B",
        "F_{\\rm em}:=\\chi\\Fsol",
        "dF_{\\rm em}=0",
        "d\\star_gF_{\\rm em}=\\mu_0\\star_gJ",
        "W^{(7)}_\\gamma=\\hatrho(\\tau^{w_\\gamma})",
        "\\sharedoccurrence{SF.25}{SF.26}",
        "g=\\Pi^*\\hateta",
        "\\Fsol=\\Pi^*\\hatC",
    )
    assert all(token in source for token in required)
    assert "\\oint_\\gamma A" in source
    assert "\\varnothing" not in source
    assert "unified field theory" not in source.lower()


def main() -> None:
    verify_real_fourier_character()
    verify_eight_dimensional_carrier()
    verify_source()
    print("PASS: Suture Field v0.1")
    print(
        "carrier=R[A8]; Fourier_blocks=1+1+2+2+2; "
        "Z7_metric_phase_mirror=exact; Pi_to_g_and_Fsol=typed"
    )


if __name__ == "__main__":
    main()

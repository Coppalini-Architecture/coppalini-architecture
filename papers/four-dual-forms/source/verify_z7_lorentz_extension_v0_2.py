"""Versioned receipt entry point for the exact Z7 Lorentz extension."""

from __future__ import annotations

from verify_z7_lorentz_extension_v0_1 import (
    verify_cyclotomic_phase,
    verify_factorization_and_transport,
    verify_mirror_and_block_constraints,
)


def main() -> None:
    verify_factorization_and_transport()
    verify_cyclotomic_phase()
    verify_mirror_and_block_constraints()
    print("PASS: Z7 Lorentz extension v0.2")
    print(
        "K8=28 edges; tau^7=I; zeta_7^7=1; "
        "orthogonal_block=exact; metric_phase_mirror=exact"
    )


if __name__ == "__main__":
    main()

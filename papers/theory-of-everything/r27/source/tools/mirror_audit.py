"""MIRROR_AUDIT: exact finite checks for the active root and MoneyRoot kernel.

This is a deterministic Python receipt.  It verifies only the declared finite
carrier, finite reader examples, and translator cases below.  It deliberately
does not promote those checks into an empirical economic or physical claim.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
from enum import Enum
import json
from typing import Callable, Hashable, Iterable, TypeVar

from condition_constraint_can_translator import (
    G,
    I,
    L_PHI_RAW,
    PHASE_I,
    Q,
    S_RAW,
    Mat2,
    root_exact,
    self_test,
)


T = TypeVar("T", bound=Hashable)
U = TypeVar("U", bound=Hashable)
V = TypeVar("V", bound=Hashable)


@dataclass(frozen=True)
class AuditCheck:
    gate: str
    status: str
    receipt: str


def fiber_refines(states: Iterable[T], reader: Callable[[T], U], decision: Callable[[T], V]) -> bool:
    states = tuple(states)
    return all(
        reader(x) != reader(y) or decision(x) == decision(y)
        for x in states
        for y in states
    )


def decision_collision(
    states: Iterable[T], reader: Callable[[T], U], decision: Callable[[T], V]
) -> tuple[T, T] | None:
    states = tuple(states)
    for x in states:
        for y in states:
            if reader(x) == reader(y) and decision(x) != decision(y):
                return x, y
    return None


def factor_through_read(
    states: Iterable[T], reader: Callable[[T], U], decision: Callable[[T], V]
) -> dict[U, V] | None:
    """Build the decoder on the actual reader image, or return None on a collision."""
    decoder: dict[U, V] = {}
    for state in states:
        coordinate = reader(state)
        value = decision(state)
        if coordinate in decoder and decoder[coordinate] != value:
            return None
        decoder[coordinate] = value
    return decoder


def mirror_root_checks() -> AuditCheck:
    l_phi_inverse_raw = Mat2(2, -1, -1, 3)
    d2 = I.scale(2)
    passed = (
        root_exact()
        and G @ S_RAW @ G == S_RAW.scale(-5)  # H S H = -S, cleared
        and G @ L_PHI_RAW @ G == l_phi_inverse_raw.scale(5)  # H L H = L^-1
        and L_PHI_RAW @ l_phi_inverse_raw == I.scale(5)
        and G @ PHASE_I @ G == PHASE_I.scale(-5)  # H i H = -i, cleared
        and G @ d2 @ G == d2.scale(5)  # H D_2 H = D_2, cleared
    )
    assert passed
    return AuditCheck(
        "Condition",
        "PASS",
        "Q, Omega, G, scalar, lift, and phase identities hold exactly after clearing irrational denominators.",
    )


def translator_checks() -> AuditCheck:
    cases = self_test()
    observed = {(case["name"], case["gate"], case["reason"]) for case in cases}
    required = {
        ("scalar<2>", "can", ""),
        ("scalar<0>", "fold", "constraint"),
        ("golden_lift", "can", ""),
        ("phase_i_sqrt7", "can", ""),
        ("phase_as_scalar", "fold", "constraint"),
        ("untyped", "fold", "untyped"),
    }
    assert observed == required
    return AuditCheck(
        "Type",
        "PASS",
        "Typed -> Condition -> Constraint -> Can|Fold is exercised on six deterministic paths.",
    )


class PriceCase(str, Enum):
    NEED_A = "need_a"
    NEED_B = "need_b"


def price(case: PriceCase) -> int:
    return 100


def access(case: PriceCase) -> bool:
    return case is PriceCase.NEED_A


class AbundanceCase(str, Enum):
    USEFUL_A = "useful_a"
    USEFUL_B = "useful_b"


def zero_price(case: AbundanceCase) -> int:
    return 0


def use_read(case: AbundanceCase) -> int:
    return 1 if case is AbundanceCase.USEFUL_A else 9


class LivingCase(str, Enum):
    VIABLE_A = "viable_a"
    VIABLE_B = "viable_b"


def money_read(case: LivingCase) -> int:
    return 0


def continuation(case: LivingCase) -> bool:
    return case is LivingCase.VIABLE_A


@dataclass(frozen=True)
class SettlementState:
    gross_in: int
    gross_out: int


def net(state: SettlementState) -> int:
    return state.gross_in - state.gross_out


def gross_total(state: SettlementState) -> int:
    return state.gross_in + state.gross_out


def moneyroot_witness_checks() -> list[AuditCheck]:
    price_states = tuple(PriceCase)
    abundance_states = tuple(AbundanceCase)
    living_states = tuple(LivingCase)
    settlements = (SettlementState(1, 1), SettlementState(2, 2))

    assert decision_collision(price_states, price, access) is not None
    assert factor_through_read(price_states, price, access) is None
    assert decision_collision(abundance_states, zero_price, use_read) is not None
    assert factor_through_read(abundance_states, zero_price, use_read) is None
    assert decision_collision(living_states, money_read, continuation) is not None
    assert factor_through_read(living_states, money_read, continuation) is None
    assert decision_collision(settlements, net, gross_total) is not None
    assert factor_through_read(settlements, net, gross_total) is None

    return [
        AuditCheck(
            "Constraint",
            "PASS",
            "Every finite MoneyRoot collision blocks a reader-only factorization on its declared reader fiber.",
        ),
        AuditCheck(
            "Witness",
            "PASS",
            "Price/access, price/use, money/continuation, and net/gross finite witnesses are explicit.",
        ),
        AuditCheck(
            "Falsifier",
            "PASS",
            "A same-read/different-decision pair deterministically falsifies the proposed coordinate-only rule.",
        ),
    ]


def transport_and_return_checks() -> list[AuditCheck]:
    def reader(x: int) -> int:
        return x % 2

    def policy(coordinate: int) -> int:
        return coordinate + 1

    def plant(state: int, action: int) -> int:
        return state + action

    def closed_loop(state: int) -> int:
        return plant(state, policy(reader(state)))

    assert closed_loop(3) == plant(3, policy(reader(3)))

    states = (0, 1, 2, 3)
    assert fiber_refines(states, reader, reader)
    decoder = factor_through_read(states, reader, reader)
    assert decoder == {0: 0, 1: 1}

    phase = lambda n: n % 4
    assert phase(11 + 4) == phase(11)
    assert 11 + 4 != 11

    return [
        AuditCheck(
            "Transport",
            "PASS",
            "The closed loop is explicitly T(x, kappa(R(x))); no causal action is assigned to the read alone.",
        ),
        AuditCheck(
            "Preservation",
            "PASS",
            "A decision equal to the declared read descends exactly to the reader image.",
        ),
        AuditCheck(
            "Return",
            "PASS",
            "The finite phase reader returns after four ticks while the occurrence index advances.",
        ),
    ]


def run_audit() -> dict[str, object]:
    checks = [mirror_root_checks(), translator_checks()]
    checks.extend(moneyroot_witness_checks())
    checks.extend(transport_and_return_checks())
    checks.append(
        AuditCheck(
            "Receipt",
            "PASS",
            "This script executed all declared finite checks with exact integer arithmetic and finite witnesses.",
        )
    )
    return {
        "audit": "MIRROR_AUDIT MoneyRoot + root carrier",
        "status": "PASS",
        "checks": [asdict(check) for check in checks],
        "boundary": (
            "The receipt establishes only the declared finite algebra and toy-reader schemas; "
            "economic, legal, physical, and clinical adapters require their own evidence."
        ),
    }


if __name__ == "__main__":
    print(json.dumps(run_audit(), indent=2, sort_keys=True))

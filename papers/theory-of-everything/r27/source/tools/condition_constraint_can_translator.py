"""Condition & Constraint can Translator.

An executable Python counterpart to the C++20 compile-time receipt.
The carrier is deliberately finite and exact: all matrix entries are integers,
and the sqrt(5) / i*sqrt(7) relations are checked after clearing denominators.

Admission order:
    typed candidate -> exact condition -> owning constraint -> can | fold
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Protocol, Union


@dataclass(frozen=True)
class Mat2:
    a: int
    b: int
    c: int
    d: int

    def __add__(self, other: "Mat2") -> "Mat2":
        return Mat2(self.a + other.a, self.b + other.b, self.c + other.c, self.d + other.d)

    def scale(self, k: int) -> "Mat2":
        return Mat2(k * self.a, k * self.b, k * self.c, k * self.d)

    def __matmul__(self, other: "Mat2") -> "Mat2":
        return Mat2(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def transpose(self) -> "Mat2":
        return Mat2(self.a, self.c, self.b, self.d)


ZERO = Mat2(0, 0, 0, 0)
I = Mat2(1, 0, 0, 1)
Q = Mat2(1, 1, 1, 0)
OMEGA = Mat2(0, 1, -1, 0)
PHASE_I = OMEGA.scale(-1)  # i = -Omega
G = (Q @ OMEGA) + (OMEGA @ Q).scale(-1)
S_RAW = Q.scale(2) + I.scale(-1)  # sqrt(5) S
L_PHI_RAW = Q + I.scale(2)  # sqrt(5) L_log(Phi)


def commutator(left: Mat2, right: Mat2) -> Mat2:
    return (left @ right) + (right @ left).scale(-1)


def root_exact() -> bool:
    """Exact integer / cleared-denominator root receipt."""
    return (
        Q @ Q == Q + I
        and OMEGA @ OMEGA == I.scale(-1)
        and PHASE_I @ PHASE_I == I.scale(-1)
        and G @ G == I.scale(5)
        and Q.transpose() @ G @ Q == G.scale(-1)
        and S_RAW @ S_RAW == I.scale(5)
        and S_RAW.transpose() @ G + G @ S_RAW == ZERO
        and L_PHI_RAW @ L_PHI_RAW == (Q @ Q).scale(5)
        and G @ PHASE_I @ G == PHASE_I.scale(-5)
        and commutator(Q, PHASE_I) == G.scale(-1)
    )


class Gate(str, Enum):
    CAN = "can"
    FOLD = "fold"


class FoldReason(str, Enum):
    UNTYPED = "untyped"
    CONDITION = "condition"
    CONSTRAINT = "constraint"


@dataclass(frozen=True)
class Can:
    candidate: object
    gate: Gate = Gate.CAN


@dataclass(frozen=True)
class Fold:
    candidate: object
    reason: FoldReason
    gate: Gate = Gate.FOLD


@dataclass(frozen=True)
class Scalar:
    amplitude: int

    @property
    def matrix(self) -> Mat2:
        return I.scale(self.amplitude)


@dataclass(frozen=True)
class GoldenLift:
    matrix: Mat2 = L_PHI_RAW


@dataclass(frozen=True)
class PhaseISqrt7:
    matrix: Mat2 = PHASE_I


@dataclass(frozen=True)
class UntypedSignal:
    payload: str = "untyped"


Candidate = Union[Scalar, GoldenLift, PhaseISqrt7, UntypedSignal]


@dataclass(frozen=True)
class CandidateTraits:
    typed: bool
    exact_root: bool
    nonzero: bool = False
    central: bool = False
    mirror_fixed: bool = False
    conformal: bool = False
    lift: bool = False
    phase: bool = False


def traits_for(candidate: Candidate) -> CandidateTraits:
    if isinstance(candidate, Scalar):
        d = candidate.matrix
        a = candidate.amplitude
        return CandidateTraits(
            typed=True,
            exact_root=root_exact(),
            nonzero=a != 0,
            central=all(
                d @ operator == operator @ d
                for operator in (Q, OMEGA, G, S_RAW, PHASE_I)
            ),
            # H D H = D, multiplied through by 5 because H = G / sqrt(5).
            mirror_fixed=G @ d @ G == d.scale(5),
            conformal=d.transpose() @ G @ d == G.scale(a * a),
        )
    if isinstance(candidate, GoldenLift):
        return CandidateTraits(
            typed=True,
            exact_root=root_exact(),
            nonzero=True,
            lift=candidate.matrix @ candidate.matrix == (Q @ Q).scale(5),
        )
    if isinstance(candidate, PhaseISqrt7):
        phase_square = (PHASE_I @ PHASE_I).scale(7) == I.scale(-7)
        mirror_reverses = G @ PHASE_I @ G == PHASE_I.scale(-5)
        return CandidateTraits(
            typed=True,
            exact_root=root_exact(),
            nonzero=True,
            phase=phase_square and mirror_reverses,
        )
    return CandidateTraits(typed=False, exact_root=False)


class Condition(Protocol):
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool: ...


class Constraint(Protocol):
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool: ...


@dataclass(frozen=True)
class ExactRootCondition:
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool:
        return traits.exact_root


@dataclass(frozen=True)
class ScalarSymmetryConstraint:
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool:
        return traits.nonzero and traits.central and traits.mirror_fixed and traits.conformal


@dataclass(frozen=True)
class GoldenLiftConstraint:
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool:
        return traits.lift


@dataclass(frozen=True)
class PhaseClosureConstraint:
    def holds(self, candidate: Candidate, traits: CandidateTraits) -> bool:
        return traits.phase


Translation = Union[Can, Fold]


def translate(candidate: Candidate, condition: Condition, constraint: Constraint) -> Translation:
    """Translate a candidate only after typing, then condition, then constraint."""
    traits = traits_for(candidate)
    if not traits.typed:
        return Fold(candidate, FoldReason.UNTYPED)
    if not condition.holds(candidate, traits):
        return Fold(candidate, FoldReason.CONDITION)
    if not constraint.holds(candidate, traits):
        return Fold(candidate, FoldReason.CONSTRAINT)
    return Can(candidate)


def _case(name: str, result: Translation, expected_gate: Gate, expected_reason: FoldReason | None = None) -> dict[str, str]:
    assert result.gate is expected_gate, (name, result)
    if expected_reason is not None:
        assert isinstance(result, Fold), (name, result)
        assert result.reason is expected_reason, (name, result)
    return {
        "name": name,
        "gate": result.gate.value,
        "reason": result.reason.value if isinstance(result, Fold) else "",
    }


def self_test() -> list[dict[str, str]]:
    """Deterministic exact receipt used by mirror_audit.py."""
    assert root_exact()
    root = ExactRootCondition()
    scalar = ScalarSymmetryConstraint()
    lift = GoldenLiftConstraint()
    phase = PhaseClosureConstraint()
    return [
        _case("scalar<2>", translate(Scalar(2), root, scalar), Gate.CAN),
        _case("scalar<0>", translate(Scalar(0), root, scalar), Gate.FOLD, FoldReason.CONSTRAINT),
        _case("golden_lift", translate(GoldenLift(), root, lift), Gate.CAN),
        _case("phase_i_sqrt7", translate(PhaseISqrt7(), root, phase), Gate.CAN),
        _case("phase_as_scalar", translate(PhaseISqrt7(), root, scalar), Gate.FOLD, FoldReason.CONSTRAINT),
        _case("untyped", translate(UntypedSignal(), root, scalar), Gate.FOLD, FoldReason.UNTYPED),
    ]


if __name__ == "__main__":
    import json

    print(json.dumps({"root_exact": root_exact(), "cases": self_test()}, indent=2))

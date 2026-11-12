# Condition & Constraint phase repair R1

## Fixed predicate

`PhaseISqrt7` now evaluates the submitted `candidate.matrix` in both phase
closure predicates.  The root matrices remain declared reference data; the
phase predicate is candidate-derived.

## Regression receipt

| submission | expected result | observed result |
| --- | --- | --- |
| `PHASE_I` | `Can` | `Can` |
| `ZERO` | `Fold(constraint)` | `Fold(constraint)` |
| `I` | `Fold(constraint)` | `Fold(constraint)` |

Phase repair R1 introduced eight deterministic `Can|Fold` paths.  The current
integer-carrier repair expands the Type gate to twelve paths; its own receipt
appears in [integer-carrier repair R1](condition-constraint-integer-carrier-repair-r1.md).

## Boundary

The Python change repairs the runtime submitted-matrix path.  The C++ receipt
is a closed type-level form whose `PhaseISqrt7::matrix` is statically `i`; it
requires no runtime-path change.

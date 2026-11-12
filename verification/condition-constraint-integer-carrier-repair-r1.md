# Condition & Constraint integer-carrier repair R1

## Fixed predicate

The Python dataclass annotation `amplitude: int` did not constrain submitted
runtime values: Python treats `bool` as a subclass of `int`, and admits a
`float` unless the carrier checks its exact type.  The translator now admits a
scalar amplitude only when `type(amplitude) is int`.

The same exact-integer predicate now protects submitted `GoldenLift` and
`PhaseISqrt7` matrices before their algebraic predicates run.  The C++
companion remains a statically typed receipt.

## Regression receipt

| submission | expected result | observed result |
| --- | --- | --- |
| `Scalar(2)` | `Can` | `Can` |
| `Scalar(0.5)` | `Fold(untyped)` | `Fold(untyped)` |
| `Scalar(True)` | `Fold(untyped)` | `Fold(untyped)` |
| exact-valued float lift matrix | `Fold(untyped)` | `Fold(untyped)` |
| exact-valued bool phase matrix | `Fold(untyped)` | `Fold(untyped)` |

The canonical phase remains `Can`; zero and identity phase submissions remain
`Fold(constraint)`.  The translator and mirror audit exercise twelve declared
paths.

## Boundary

This receipt establishes exact typing for the finite Python carrier.  It does
not extend the finite algebra into a physical, economic, legal, or clinical
adapter.
